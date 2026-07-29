import { Router } from "express";
import { prisma } from "../lib/prisma";
import { requireAuth, AuthedRequest } from "../middleware/auth";

export const skillsRouter = Router();

// Busca pública de ofertas (equivalente à tela "Buscar" do app)
skillsRouter.get("/", async (req, res) => {
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
});

skillsRouter.post("/", requireAuth, async (req: AuthedRequest, res) => {
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
});
