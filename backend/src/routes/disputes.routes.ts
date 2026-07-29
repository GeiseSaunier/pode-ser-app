import { Router, Request, Response, NextFunction } from "express";
import { prisma } from "../lib/prisma";
import { requireAuth, AuthedRequest } from "../middleware/auth";
import { asyncHandler } from "../lib/asyncHandler";

export const disputesRouter = Router();

function requireAdmin(req: Request, res: Response, next: NextFunction) {
  const key = req.headers["x-admin-key"];
  if (!process.env.ADMIN_KEY || key !== process.env.ADMIN_KEY) {
    return res.status(403).json({ error: "Acesso restrito" });
  }
  next();
}

disputesRouter.post("/", requireAuth, asyncHandler(async (req: AuthedRequest, res) => {
  const { transactionId, reason, description } = req.body;

  const transaction = await prisma.transaction.findUnique({ where: { id: transactionId } });
  if (!transaction) return res.status(404).json({ error: "Troca não encontrada" });

  const isParty = transaction.requesterId === req.userId || transaction.providerId === req.userId;
  if (!isParty) return res.status(403).json({ error: "Você não faz parte dessa troca" });

  if (!["ACEITA", "EM_ANDAMENTO"].includes(transaction.status)) {
    return res.status(400).json({ error: "Só é possível abrir disputa em trocas em andamento" });
  }

  const existing = await prisma.dispute.findUnique({ where: { transactionId } });
  if (existing) return res.status(409).json({ error: "Já existe uma disputa para essa troca" });

  const [dispute] = await prisma.$transaction([
    prisma.dispute.create({
      data: { transactionId, openedById: req.userId!, reason, description },
    }),
    prisma.transaction.update({
      where: { id: transactionId },
      data: { status: "DISPUTA" },
    }),
  ]);

  res.status(201).json(dispute);
}));

disputesRouter.patch("/:id/resolve", requireAuth, requireAdmin, asyncHandler(async (req: AuthedRequest, res) => {
  const { id } = req.params;
  const { status, resolutionNote } = req.body;

  const dispute = await prisma.dispute.findUnique({ where: { id }, include: { transaction: true } });
  if (!dispute) return res.status(404).json({ error: "Disputa não encontrada" });

  const updated = await prisma.$transaction(async (tx) => {
    const d = await tx.dispute.update({
      where: { id },
      data: { status, resolutionNote, resolvedAt: new Date() },
    });

    if (status === "RESOLVIDA_CREDITO") {
      const t = dispute.transaction;
      await tx.creditLedger.create({
        data: { userId: t.requesterId, transactionId: t.id, amount: -t.creditsAgreed, reason: "ESTORNO_DISPUTA" },
      });
      await tx.creditLedger.create({
        data: { userId: t.providerId, transactionId: t.id, amount: t.creditsAgreed, reason: "ESTORNO_DISPUTA" },
      });
      await tx.user.update({ where: { id: t.requesterId }, data: { creditBalance: { decrement: t.creditsAgreed } } });
      await tx.user.update({ where: { id: t.providerId }, data: { creditBalance: { increment: t.creditsAgreed } } });
      await tx.transaction.update({ where: { id: t.id }, data: { status: "CONCLUIDA" } });
    } else {
      await tx.transaction.update({ where: { id: dispute.transactionId }, data: { status: "CANCELADA" } });
    }

    return d;
  });

  res.json(updated);
}));
