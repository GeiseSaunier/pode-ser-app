import express, { Request, Response, NextFunction } from "express";
import cors from "cors";
import { authRouter } from "./routes/auth.routes";
import { oauthRouter } from "./routes/oauth.routes";
import { usersRouter } from "./routes/users.routes";
import { skillsRouter } from "./routes/skills.routes";
import { transactionsRouter } from "./routes/transactions.routes";
import { disputesRouter } from "./routes/disputes.routes";
import { reviewsRouter } from "./routes/reviews.routes";

export const app = express();

app.use(cors());
app.use(express.json());

app.get("/health", (_req, res) => res.json({ ok: true }));

app.use("/auth", authRouter);
app.use("/auth/oauth", oauthRouter);
app.use("/users", usersRouter);
app.use("/skills", skillsRouter);
app.use("/transactions", transactionsRouter);
app.use("/disputes", disputesRouter);
app.use("/reviews", reviewsRouter);

app.use((err: Error, _req: Request, res: Response, _next: NextFunction) => {
  console.error(err);
  res.status(500).json({ error: "Erro interno do servidor" });
});
