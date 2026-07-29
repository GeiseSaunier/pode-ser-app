import { Router } from "express";
import { prisma } from "../lib/prisma";
import { requireAuth, AuthedRequest } from "../middleware/auth";
import { asyncHandler } from "../lib/asyncHandler";

export const reviewsRouter = Router();

reviewsRouter.post("/", requireAuth, asyncHandler(async (req: AuthedRequest, res) => {
  const { transactionId, rating, comment } = req.body;

  if (!rating || rating < 1 || rating > 5) {
    return res.status(400).json({ error: "Avaliação deve ser entre 1 e 5" });
  }

  const transaction = await prisma.transaction.findUnique({ where: { id: transactionId } });
  if (!transaction) return res.status(404).json({ error: "Troca não encontrada" });
  if (transaction.status !== "CONCLUIDA") {
    return res.status(400).json({ error: "Só é possível avaliar trocas concluídas" });
  }

  const isParty = transaction.requesterId === req.userId || transaction.providerId === req.userId;
  if (!isParty) return res.status(403).json({ error: "Você não faz parte dessa troca" });

  const existing = await prisma.review.findUnique({ where: { transactionId } });
  if (existing) return res.status(409).json({ error: "Essa troca já foi avaliada" });

  const revieweeId =
    transaction.requesterId === req.userId ? transaction.providerId : transaction.requesterId;

  const review = await prisma.review.create({
    data: { transactionId, reviewerId: req.userId!, revieweeId, rating, comment },
  });

  const agg = await prisma.review.aggregate({
    where: { revieweeId },
    _avg: { rating: true },
  });
  await prisma.user.update({
    where: { id: revieweeId },
    data: { ratingAvg: agg._avg.rating ?? 0 },
  });

  res.status(201).json(review);
}));
