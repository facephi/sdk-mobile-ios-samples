# SDK Mobile iOS — Samples

Repositorio de aplicaciones de ejemplo (demos) para integrar y probar **SDK Mobile iOS** vía **CocoaPods** (Artifactory `cocoa-pro-fphi`) o **SPM** según cada proyecto.

## Release actual: SDK 4.0.0

| Ámbito | Versión |
|--------|---------|
| Componentes CocoaPods (`FPHISDK*`) | `~> 4.0.0` |
| SelphID KMP (host) | `FPHISelphIDExtractorV1/V2/V3` (ver Podfile de cada demo) |
| Selphi / SelphID **Classic** | pods `4.0.0-classic` (demos `sdkmobile-demo-*-classic-pods`) |

### Actualizar dependencias (CocoaPods)

1. Credenciales en `~/.netrc` para `facephicorp.jfrog.io` (ver README de cada demo).
2. Registrar / actualizar índice:
   ```bash
   pod repo-art add cocoa-pro-fphi "https://facephicorp.jfrog.io/artifactory/api/pods/cocoa-pro-fphi"
   pod repo-art update cocoa-pro-fphi
   ```
3. En la carpeta de la demo: `pod install` o `pod update`

**iOS mínimo:** 16.0 (demos con Podfile 4.0.0).

### SPM

Tras publicar tags 4.0.0 en Clienters, resolver en Xcode (**File → Packages → Resolve Package Versions**) o:

```bash
xcodebuild -resolvePackageDependencies -project demosdk.xcodeproj -scheme demosdk
```

Los `Package.resolved` incluidos pueden seguir en 2.x hasta actualizar el proyecto; los **Podfile** declaran **4.0.0**.

### Notas release 4.0.0

- SelphID KMP: `FPHISDKSelphIDComponent` + extractors en la app host (`FPHISelphIDExtractorV1/V2/V3`).
- VideoCall: source LiveKit en Podfile donde aplique.
- Referencia de integración full: `sdkmobile-demos-ios/sdkmobile-demo-full-pods`.

## Demos incluidas

| Carpeta | Descripción |
|---------|-------------|
| `sdkmobile-demo-full` | Todos los componentes (Full) |
| `sdkmobile-demo-classic-pods` | Selphi + SelphID KMP |
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

## Jira

- [EST-1098](https://facephicorporative.atlassian.net/browse/EST-1098) — Samples release 4.0.0
