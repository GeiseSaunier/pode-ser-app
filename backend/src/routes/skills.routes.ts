import { Router } from "express";
import { prisma } from "../lib/prisma";
import { requireAuth, AuthedRequest } from "../middleware/auth";
import { asyncHandler } from "../lib/asyncHandler";

export const skillsRouter = Router();

skillsRouter.get("/categories", asyncHandler(async (_req, res) => {
  const rows = await prisma.skill.findMany({
    where: { type: "OFERTA" },
    select: { category: true },
    distinct: ["category"],
    orderBy: { category: "asc" },
  });
  res.json(rows.map((r) => r.category).filter(Boolean));
}));

skillsRouter.get("/", asyncHandler(async (req, res) => {
  const { q, mode, category } = req.query;

  const skills = await prisma.skill.findMany({
    where: {
      type: "OFERTA",
      ...(mode ? { mode: mode as any } : {}),
      ...(category ? { category: category as string } : {}),
      ...(q
        ? {
            OR: [
              { title: { contains: q as string, mode: "insensitive" } },
              { category: { contains: q as string, mode: "insensitive" } },
            ],
          }
        : {}),
    },
    include: {
      user: { select: { id: true, name: true, ratingAvg: true } },
    },
    orderBy: { createdAt: "desc" },
  });

  res.json(skills);
}));

skillsRouter.post("/", requireAuth, asyncHandler(async (req: AuthedRequest, res) => {
  const { type, title, category, mode, creditsPerHour } = req.body;
  const skill = await prisma.skill.create({
    data: {
      userId: req.userId!,
      type,
      title,
      category,
      mode,
      creditsPerHour: creditsPerHour ?? 1,
    },
  });
  res.status(201).json(skill);
}));
