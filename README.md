# Pode ser? — nativo (iOS + Android)

```
pode-ser-nativo/
  app/               App Flutter
  backend/           API Node + Express + Prisma + PostgreSQL
  docker-compose.yml Banco PostgreSQL
```

## Pré-requisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Node.js 20+](https://nodejs.org)
- [Flutter SDK 3.19+](https://docs.flutter.dev/get-started/install)
- Android Studio (emulador Android) ou Xcode 15+ (simulador iOS, macOS only)

## Como rodar

### 1. Banco

```bash
docker compose up -d db
```

### 2. Backend

```bash
cd backend
cp .env.example .env
npm install
npx prisma migrate dev --name init
npx prisma db seed
npm run dev
```

API disponível em `http://localhost:3333`.

### 3. App

```bash
cd app
flutter create --org com.podeser --project-name pode_ser --platforms=android,ios .
flutter pub get
flutter run
```

> Para dispositivo físico ou simulador iOS, passe o IP da sua máquina:
> ```bash
> flutter run --dart-define=API_URL=http://SEU_IP:3333
> ```

## Build para as lojas

**Android:**
```bash
flutter build appbundle
```
Suba o `.aab` em `build/app/outputs/bundle/release/` no Google Play Console.

**iOS (requer macOS + Xcode):**
```bash
flutter build ipa
```
Suba via Xcode ou Transporter no App Store Connect.
