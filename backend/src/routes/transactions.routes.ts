import { Router } from "express";
import { prisma } from "../lib/prisma";
import { requireAuth, AuthedRequest } from "../middleware/auth";

export const transactionsRouter = Router();

// Lista as trocas do usuário logado (como solicitante ou como prestador)
transactionsRouter.get("/", requireAuth, async (req: AuthedRequest, res) => {
  const transactions = await prisma.transaction.findMany({
    where: { OR: [{ requesterId: req.userId }, { providerId: req.userId }] },
    include: { skill: true, requester: true, provider: true, dispute: true },
    orderBy: { createdAt: "desc" },
  });
  res.json(transactions);
});

// Propor uma troca (equivalente ao botão "Propor troca" na busca)
transactionsRouter.post("/", requireAuth, async (req: AuthedRequest, res) => {
  const { skillId } = req.body;

  const skill = await prisma.skill.findUnique({ where: { id: skillId } });
  if (!skill) return res.status(404).json({ error: "Oferta não encontrada" });
  if (skill.userId === req.userId) {
    return res.status(400).json({ error: "Você não pode propor uma troca com sua própria oferta" });
  }

  const transaction = await prisma.transaction.create({
    data: {
      requesterId: req.userId!,
      providerId: skill.userId,
      skillId: skill.id,
      creditsAgreed: skill.creditsPerHour,
      status: "PROPOSTA",
    },
  });

  res.status(201).json(transaction);
});

// Confirmação de conclusão (uma parte por vez). Quando as duas confirmarem,
// o crédito é lançado no ledger e os saldos são atualizados atomicamente.
transactionsRouter.post("/:id/confirm", requireAuth, async (req: AuthedRequest, res) => {
  const { id } = req.params;

  const transaction = await prisma.transaction.findUnique({ where: { id } });
  if (!transaction) return res.status(404).json({ error: "Troca não encontrada" });
  if (transaction.status === "DISPUTA") {
    return res.status(409).json({ error: "Troca em disputa não pode ser confirmada" });
  }

  const isRequester = transaction.requesterId === req.userId;
  const isProvider = transaction.providerId === req.userId;
  if (!isRequester && !isProvider) {
    return res.status(403).json({ error: "Você não faz parte dessa troca" });
  }

  const data: Record<string, unknown> = {};
  if (isRequester) data.requesterConfirmedAt = new Date();
  if (isProvider) data.providerConfirmedAt = new Date();

  const willComplete =
    (isRequester || transaction.requesterConfirmedAt) &&
    (isProvider || transaction.providerConfirmedAt);

  const result = await prisma.$transaction(async (tx) => {
    const updated = await tx.transaction.update({
      where: { id },
      data: {
        ...data,
        status: willComplete ? "CONCLUIDA" : "EM_ANDAMENTO",
      },
    });

    if (willComplete) {
      // Débito de quem recebeu o favor, crédito de quem prestou.
      await tx.creditLedger.create({
        data: {
          userId: updated.requesterId,
          transactionId: updated.id,
          amount: -updated.creditsAgreed,
          reason: "TROCA_CONCLUIDA",
        },
      });
      await tx.creditLedger.create({
        data: {
          userId: updated.providerId,
          transactionId: updated.id,
          amount: updated.creditsAgreed,
          reason: "TROCA_CONCLUIDA",
        },
      });
      await tx.user.update({
        where: { id: updated.requesterId },
        data: { creditBalance: { decrement: updated.creditsAgreed } },
      });
      await tx.user.update({
        where: { id: updated.providerId },
        data: { creditBalance: { increment: updated.creditsAgreed } },
      });
    }

    return updated;
  });

  res.json(result);
});
