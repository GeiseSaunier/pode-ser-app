import { Router } from "express";
import bcrypt from "bcryptjs";
import { prisma } from "../lib/prisma";
import { signToken } from "../lib/jwt";

export const authRouter = Router();

// Todo usuário novo ganha um pequeno saldo de boas-vindas (ver README / modelo de dados).
const WELCOME_BONUS = 2;

authRouter.post("/register", async (req, res) => {
  const { name, email, password, oferece, quer } = req.body;

  if (!name || !email || !password) {
    return res.status(400).json({ error: "Nome, e-mail e senha são obrigatórios" });
  }

  const existing = await prisma.user.findUnique({ where: { email } });
  if (existing) {
    return res.status(409).json({ error: "Já existe uma conta com esse e-mail" });
  }

  const passwordHash = await bcrypt.hash(password, 10);

  const user = await prisma.user.create({
    data: {
      name,
      email,
      passwordHash,
      creditBalance: WELCOME_BONUS,
      skills: {
        create: [
          ...(oferece || []).map((title: string) => ({
            type: "OFERTA" as const,
            title,
            category: "Geral",
            mode: "REMOTO" as const,
          })),
          ...(quer || []).map((title: string) => ({
            type: "DESEJO" as const,
            title,
            category: "Geral",
            mode: "REMOTO" as const,
          })),
        ],
      },
      ledgerEntries: {
        create: [{ amount: WELCOME_BONUS, reason: "BONUS_CADASTRO" }],
      },
    },
  });

  const token = signToken(user.id);
  res.status(201).json({ token, user: { id: user.id, name: user.name, email: user.email } });
});

authRouter.post("/login", async (req, res) => {
  const { email, password } = req.body;

  const user = await prisma.user.findUnique({ where: { email } });
  if (!user) return res.status(401).json({ error: "Credenciais inválidas" });

  const valid = await bcrypt.compare(password, user.passwordHash);
  if (!valid) return res.status(401).json({ error: "Credenciais inválidas" });

  const token = signToken(user.id);
  res.json({ token, user: { id: user.id, name: user.name, email: user.email } });
});
