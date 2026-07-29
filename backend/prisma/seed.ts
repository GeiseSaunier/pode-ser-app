import { PrismaClient } from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

async function main() {
  const passwordHash = await bcrypt.hash("senha123", 10);

  const mariana = await prisma.user.create({
    data: {
      name: "Mariana Alves",
      email: "mariana@example.com",
      passwordHash,
      bio: "Edito vídeo há 5 anos. Adoro trocar por aulas e experiências novas.",
      creditBalance: 6,
      ratingAvg: 4.8,
      skills: {
        create: [
          { type: "OFERTA", title: "Edição de vídeo", category: "Audiovisual", mode: "REMOTO" },
          { type: "OFERTA", title: "Motion graphics", category: "Audiovisual", mode: "REMOTO" },
          { type: "DESEJO", title: "Pilates", category: "Bem-estar", mode: "PRESENCIAL" },
          { type: "DESEJO", title: "Aulas de violão", category: "Música", mode: "PRESENCIAL" },
        ],
      },
    },
  });

  const carla = await prisma.user.create({
    data: {
      name: "Carla Nunes",
      email: "carla@example.com",
      passwordHash,
      ratingAvg: 4.9,
      skills: { create: [{ type: "OFERTA", title: "Aula de pilates", category: "Bem-estar", mode: "PRESENCIAL" }] },
    },
  });

  const bruno = await prisma.user.create({
    data: {
      name: "Bruno Diniz",
      email: "bruno@example.com",
      passwordHash,
      ratingAvg: 4.7,
      skills: { create: [{ type: "OFERTA", title: "Aula de violão", category: "Música", mode: "PRESENCIAL" }] },
    },
  });

  const fernanda = await prisma.user.create({
    data: {
      name: "Fernanda Lima",
      email: "fernanda@example.com",
      passwordHash,
      ratingAvg: 5.0,
      skills: { create: [{ type: "OFERTA", title: "Tradução PT-EN", category: "Idiomas", mode: "REMOTO" }] },
    },
  });

  const pilatesSkill = await prisma.skill.findFirstOrThrow({ where: { userId: carla.id } });

  await prisma.transaction.create({
    data: {
      requesterId: mariana.id,
      providerId: carla.id,
      skillId: pilatesSkill.id,
      creditsAgreed: 1,
      status: "EM_ANDAMENTO",
      providerConfirmedAt: new Date(),
    },
  });

  console.log("Seed concluído:", { mariana: mariana.email, carla: carla.email, bruno: bruno.email, fernanda: fernanda.email });
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
