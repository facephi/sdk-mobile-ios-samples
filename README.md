# SDK Mobile iOS — Samples

Repositorio de aplicaciones de ejemplo (demos) para integrar y probar **SDK Mobile iOS** vía **CocoaPods** (Artifactory `cocoa-pro-fphi`) o **SPM** según cada proyecto.

## Release actual: SDK 2.12.0

| Ámbito | Versión |
|--------|---------|
| Componentes core / mayoría de pods | `~> 2.12.0` |
| `FPHISDKNFCComponent` | `~> 2.20.0` (alineado con core 2.12.0) |

### Actualizar dependencias (CocoaPods)

1. Credenciales en `~/.netrc` para `facephicorp.jfrog.io` (ver README de cada demo).
2. Actualizar índice: `pod repo-art update cocoa-pro-fphi`
3. En la carpeta de la demo: `pod install` o `pod update`

### SPM

Los `Podfile` y los `Package.resolved` incluidos en el repo declaran pins **2.12.0** (NFC **2.20.0**). Tras publicar los tags en Clienters, conviene volver a resolver en Xcode (**File → Packages → Resolve Package Versions**) para alinear `revision` con el tag publicado:

```bash
xcodebuild -resolvePackageDependencies -project demosdk.xcodeproj -scheme demosdk
```

### Notas release 2.12.0

- Alineación con la release [EST-780](https://facephicorporative.atlassian.net/browse/EST-780) (iOS SDK Mobile 2.12.0).
- Tras el bump, validar al menos la demo **full** y las demos de componentes que uses en QA.
- Conocido: `FPHISDKPhingersTFComponent` 2.12.0 puede advertir falta de slice **arm64** en simulador; probar en dispositivo físico si el build de simulador falla.

## Demos incluidas

| Carpeta | Descripción |
|---------|-------------|
| `sdkmobile-demo-full` | Todos los componentes (Full) |
| `sdkmobile-demo-classic-pods` | Selphi + SelphID clásico |
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

- [EST-825](https://facephicorporative.atlassian.net/browse/EST-825) — Samples release 2.12.0
