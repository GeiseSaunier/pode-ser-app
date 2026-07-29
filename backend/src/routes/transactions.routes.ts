import { Router } from "express";
import { prisma } from "../lib/prisma";
import { requireAuth, AuthedRequest } from "../middleware/auth";
import { asyncHandler } from "../lib/asyncHandler";

export const transactionsRouter = Router();

transactionsRouter.get("/", requireAuth, asyncHandler(async (req: AuthedRequest, res) => {
  const transactions = await prisma.transaction.findMany({
    where: { OR: [{ requesterId: req.userId }, { providerId: req.userId }] },
    include: {
      skill: true,
      requester: true,
      provider: true,
      dispute: true,
      review: { select: { id: true } },
    },
    orderBy: { createdAt: "desc" },
  });
  res.json(transactions);
}));

transactionsRouter.post("/", requireAuth, asyncHandler(async (req: AuthedRequest, res) => {
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
}));

transactionsRouter.patch("/:id/accept", requireAuth, asyncHandler(async (req: AuthedRequest, res) => {
  const { id } = req.params;
  const transaction = await prisma.transaction.findUnique({ where: { id } });
  if (!transaction) return res.status(404).json({ error: "Troca não encontrada" });
  if (transaction.providerId !== req.userId) {
    return res.status(403).json({ error: "Apenas o prestador pode aceitar a proposta" });
  }
  if (transaction.status !== "PROPOSTA") {
    return res.status(400).json({ error: "Apenas propostas pendentes podem ser aceitas" });
  }
  const updated = await prisma.transaction.update({ where: { id }, data: { status: "ACEITA" } });
  res.json(updated);
}));

transactionsRouter.patch("/:id/refuse", requireAuth, asyncHandler(async (req: AuthedRequest, res) => {
  const { id } = req.params;
  const transaction = await prisma.transaction.findUnique({ where: { id } });
  if (!transaction) return res.status(404).json({ error: "Troca não encontrada" });
  if (transaction.providerId !== req.userId) {
    return res.status(403).json({ error: "Apenas o prestador pode recusar a proposta" });
  }
  if (transaction.status !== "PROPOSTA") {
    return res.status(400).json({ error: "Apenas propostas pendentes podem ser recusadas" });
  }
  const updated = await prisma.transaction.update({ where: { id }, data: { status: "RECUSADA" } });
  res.json(updated);
}));

transactionsRouter.post("/:id/confirm", requireAuth, asyncHandler(async (req: AuthedRequest, res) => {
  const { id } = req.params;

  const transaction = await prisma.transaction.findUnique({ where: { id } });
  if (!transaction) return res.status(404).json({ error: "Troca não encontrada" });
  if (!["ACEITA", "EM_ANDAMENTO"].includes(transaction.status)) {
    return res.status(400).json({ error: "Apenas trocas aceitas podem ser confirmadas" });
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

  if (willComplete) {
    const requester = await prisma.user.findUnique({
      where: { id: transaction.requesterId },
      select: { creditBalance: true },
    });
    if (!requester || requester.creditBalance < transaction.creditsAgreed) {
      return res.status(400).json({ error: "Saldo insuficiente para concluir a troca" });
    }
  }

  const result = await prisma.$transaction(async (tx) => {
    const updated = await tx.transaction.update({
      where: { id },
      data: {
        ...data,
        status: willComplete ? "CONCLUIDA" : "EM_ANDAMENTO",
      },
    });

    if (willComplete) {
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
}));
