# SDK Mobile iOS — Samples

Repositorio de aplicaciones de ejemplo (demos) para integrar y probar **SDK Mobile iOS** vía **CocoaPods** (Artifactory `cocoa-pro-fphi`) o **SPM** según cada proyecto.

## Release actual: SDK 4.0.0

| Ámbito | Versión |
|--------|---------|
| Componentes CocoaPods (`FPHISDK*`) | `~> 4.0.0` |
| SelphID KMP (host) | `FPHISelphIDExtractorV1/V2/V3` (ver Podfile de cada demo) |

Migración e integración: ver **[IMPLEMENTATION_REPORT_4.0.0.md](./IMPLEMENTATION_REPORT_4.0.0.md)**.

### Actualizar dependencias (CocoaPods)

1. Credenciales en `~/.netrc` para `facephicorp.jfrog.io` (ver README de cada demo).
2. Registrar / actualizar índice:
   ```bash
   pod repo-art add cocoa-pro-fphi "https://facephicorp.jfrog.io/artifactory/api/pods/cocoa-pro-fphi"
   pod repo-art update cocoa-pro-fphi
   ```
3. En la carpeta de la demo: `pod install` o `pod update`

**iOS mínimo:** 16.0.

### Validar todas las demos (build)

```bash
./scripts/build_all_samples.sh
```

Informe de builds: `BUILD_REPORT_4.0.0.txt` (requiere pods 4.0.0 publicados en Artifactory).

### SPM

Tras publicar tags 4.0.0 en Clienters, resolver en Xcode (**File → Packages → Resolve Package Versions**) o:

```bash
xcodebuild -resolvePackageDependencies -project demosdk.xcodeproj -scheme demosdk
```

### Notas release 4.0.0

- Referencia de integración: `sdkmobile-demos-ios/sdkmobile-demo-full-pods`.
- SelphID: `FPHISDKSelphIDComponent` + extractors en la app; ya no `FPHISDKSelphIDComponent (+ FPHISelphIDExtractorV1/V2/V3)`.
- `SDKController.initSdk`: `locale`, `sessionVisualOptions`, `behaviorController`; cancelación con `cancelLaunch()`.
- VideoCall: source LiveKit en Podfile donde aplique.

## Demos incluidas

| Carpeta | Descripción |
|---------|-------------|
| `sdkmobile-demo-full` | Todos los componentes (Full) |
| `sdkmobile-demo-classic-pods` | Selphi + SelphID KMP (legacy name) |
| `sdkmobile-demo-selphi-classic-pods` | Selphi **Classic** pod `4.0.0-classic` |
| `sdkmobile-demo-selphid-classic-pods` | SelphID **Classic** pod `4.0.0-classic` |
| `sdkmobile-demo-classic-videorcording.pods` | Classic + VideoRecording |
| `sdkmobile-demo-selphi-pods` | Selphi |
| `sdkmobile-demo-nfc-pods` | NFC |
| `sdkmobile-demo-videoid` | VideoID |
| `sdkmobile-demo-videocall-pods` | VideoCall (+ extensión) |
| `sdkmobile-demo-voiceid-pods` | VoiceID |
| `sdkmobile-demo-phingers-pods` | Phingers |
| `sdkmobile-demo-signature-pods` | Firma / flujo compuesto |
| `sdkmobile-demo-idv` | IDV |
| `onboarding-fileuploader.demo` | Onboarding + file uploader |

Cada subcarpeta tiene `README.md` / `README_EN.md` con instrucciones de instalación.
