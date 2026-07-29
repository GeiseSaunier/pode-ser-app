import { Router } from "express";

// Estrutura pronta para plugar login social de verdade.
// Cada provedor exige credenciais próprias (ver README > "Login social").
//
// Exemplo de como isso ficaria com passport (não ativado por padrão para não
// exigir dependências extras sem as credenciais configuradas):
//
//   import passport from "passport";
//   import { Strategy as GoogleStrategy } from "passport-google-oauth20";
//
//   passport.use(new GoogleStrategy({
//     clientID: process.env.GOOGLE_CLIENT_ID!,
//     clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
//     callbackURL: "/auth/google/callback",
//   }, async (accessToken, refreshToken, profile, done) => {
//     // buscar ou criar usuário a partir de profile.emails[0].value
//   }));
//
//   oauthRouter.get("/google", passport.authenticate("google", { scope: ["profile", "email"] }));
//   oauthRouter.get("/google/callback", passport.authenticate("google"), (req, res) => { ... });

export const oauthRouter = Router();

oauthRouter.get("/:provider", (req, res) => {
  res.status(501).json({
    error: `Login via ${req.params.provider} ainda não configurado`,
    hint: "Preencha as credenciais no .env e implemente a estratégia do Passport correspondente.",
  });
});
