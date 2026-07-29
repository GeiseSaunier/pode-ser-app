# Pode ser? — app Flutter (iOS + Android)

App nativo (via Flutter/Dart) que consome o **mesmo backend** já construído
(Node + Express + Prisma + PostgreSQL). Nada muda no servidor — só a camada de
app troca de React Native seria/React web para Flutter.

## Por que este pacote não vem com as pastas `android/` e `ios/`

Essas pastas são geradas automaticamente pelo comando `flutter create` a partir
da versão do Flutter/Xcode/Android Studio instalada na sua máquina (contêm
`Info.plist`, `AndroidManifest.xml`, projetos do Gradle e do Xcode, etc.).
Gerar isso à mão, fora de um ambiente com o Flutter SDK instalado, resultaria
em arquivos desatualizados ou incompatíveis com a versão que você for usar.
Em vez disso, este pacote traz todo o **código Dart da aplicação** (`lib/`) e
o `pubspec.yaml` prontos — falta só rodar dois comandos pra ter o projeto
completo.

## Passo a passo

### 1. Instalar o Flutter
Se ainda não tiver: https://docs.flutter.dev/get-started/install

Confirme que está tudo certo:
```bash
flutter doctor
```

### 2. Gerar as pastas nativas dentro deste projeto
Na pasta `pode_ser_app` (onde está este README):
```bash
flutter create --org com.podeser --project-name pode_ser --platforms=android,ios .
```
Isso cria `android/` e `ios/` do zero **sem sobrescrever** o `lib/` e o
`pubspec.yaml` que já estão aqui (o Flutter detecta que já existem e só
completa o que falta).

### 3. Instalar as dependências
```bash
flutter pub get
```

### 4. Apontar para o backend
O app já sabe usar `http://10.0.2.2:3333` por padrão (é como o emulador
Android enxerga o `localhost` da sua máquina). Pra rodar em outro endereço
(dispositivo físico, iOS simulator, ou produção):
```bash
flutter run --dart-define=API_URL=http://SEU_IP_OU_DOMINIO:3333
```

### 5. Rodar
```bash
flutter run
```
Escolha o emulador/dispositivo Android ou o simulador iOS quando o Flutter
perguntar.

## Publicando nas lojas

### Google Play
1. Gere uma keystore de assinatura e configure em `android/key.properties`
   (o próprio `flutter create` já deixa o `build.gradle` pronto pra ler isso).
2. `flutter build appbundle` gera o `.aab` em `build/app/outputs/bundle/release/`.
3. Suba no [Google Play Console](https://play.google.com/console) (conta de
   desenvolvedor custa uma taxa única).

### App Store
1. Precisa de um Mac com Xcode instalado (build de iOS não roda em
   Windows/Linux).
2. Configure o Bundle Identifier e o time de assinatura no Xcode
   (`ios/Runner.xcworkspace`).
3. `flutter build ipa` gera o pacote pra subir via Xcode ou
   `xcrun altool`/Transporter no [App Store Connect](https://appstoreconnect.apple.com)
   (conta de desenvolvedor Apple é paga anualmente).

## O que já está implementado

- Fluxo completo: tela de entrada → login/cadastro (com Google/Facebook/Insta
  na tela, ver nota abaixo) → app com 4 abas (Buscar, Trocas, Perfil, Como
  funciona)
- Autenticação real via JWT contra o backend, token guardado com
  `flutter_secure_storage` (keychain no iOS, keystore no Android — mais seguro
  que `SharedPreferences` puro)
- Busca de ofertas, proposta de troca, confirmação dupla e abertura de disputa
  conectadas às mesmas rotas do backend já documentadas no projeto web

## Login social (Google / Facebook / Instagram)

Os botões já estão na UI. Pra funcionar de verdade em um app nativo, o correto
é usar os SDKs oficiais em vez de um simples redirect de navegador:
- `google_sign_in` (pacote oficial do Flutter)
- `flutter_facebook_auth` (cobre Facebook e Instagram, que usam a mesma
  plataforma de login da Meta)

Cada um exige registrar o app nos respectivos consoles (Google Cloud Console,
Meta for Developers) com o Bundle ID (iOS) e o SHA-1 de assinatura (Android).
Isso é um passo de configuração específico da sua conta de desenvolvedor —
não dá pra deixar pronto sem essas credenciais.

## Próximos passos sugeridos

1. Plugar os SDKs nativos de login social (ver acima)
2. Push notifications (Firebase Cloud Messaging cobre Android e iOS)
3. Ícone do app e splash screen (pacote `flutter_launcher_icons` +
   `flutter_native_splash`)
4. Geolocalização real pra busca por distância (pacote `geolocator`)
