import { Router } from "express";
import { prisma } from "../lib/prisma";
import { requireAuth, AuthedRequest } from "../middleware/auth";
import { asyncHandler } from "../lib/asyncHandler";

export const usersRouter = Router();

usersRouter.get("/me", requireAuth, asyncHandler(async (req: AuthedRequest, res) => {
  const user = await prisma.user.findUnique({
    where: { id: req.userId },
    include: { skills: true },
  });
  if (!user) return res.status(404).json({ error: "Usuário não encontrado" });

  const { passwordHash, ...safeUser } = user;
  res.json(safeUser);
}));

usersRouter.patch("/me", requireAuth, asyncHandler(async (req: AuthedRequest, res) => {
  const { bio, name } = req.body;
  const user = await prisma.user.update({
    where: { id: req.userId },
    data: { bio, name },
  });
  const { passwordHash, ...safeUser } = user;
  res.json(safeUser);
}));
