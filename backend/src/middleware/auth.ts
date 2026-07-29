import { Request, Response, NextFunction } from "express";
import { verifyToken } from "../lib/jwt";

export interface AuthedRequest extends Request {
  userId?: string;
}

export function requireAuth(req: AuthedRequest, res: Response, next: NextFunction) {
  const header = req.headers.authorization;
  if (!header?.startsWith("Bearer ")) {
    return res.status(401).json({ error: "Token ausente" });
  }
  try {
    const { sub } = verifyToken(header.replace("Bearer ", ""));
    req.userId = sub;
    next();
  } catch {
    return res.status(401).json({ error: "Token inválido ou expirado" });
  }
}
