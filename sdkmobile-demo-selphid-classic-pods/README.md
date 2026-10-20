# SDK Mobile — demo SelphID Classic (4.0.0-classic)

Sample mínima para probar **`FPHISDKSelphIDClassicComponent`** (`4.0.0-classic`, widget ml+mb / WidgetiOSSim).

Basada en la demo full. Rellena `APIKEY_LICENSING`, `LICENSING_URL` y/o `license` en `SdkConfigurationManager` en local (no subir credenciales al repo público).

## Pods

Patrón **`fphi_pods`** como en full-pods (`remote` / `local` / `local_frameworks`).

| Modo | Capture |
|------|---------|
| `remote` | `FPHISDKSelphIDClassicComponent` **`4.0.0-classic`** (Artifactory) |
| `local` | `FPHISDKSelphIDClassicComponent-Test.podspec` |
| `local_frameworks` | `FPHISDKSelphIDClassicComponent-template.podspec` |

Stack: LicenseChecker, Core, Main, Tracking, **SelphID Classic**, Status, Tokenize. **Sin** extractors KMP.

## Uso

1. `~/.netrc` con Artifactory Facephi.
2. Elegir `fphi_pods` en `Podfile`.
3. `pod repo-art update cocoa-dev-fphi` (remote).
4. `pod install`
4. Abrir `demosdk.xcworkspace`, ejecutar en dispositivo/simulador.
5. **New Operation** → **SelphID**.

Módulo Swift: `selphidClassicComponent`.

**Status:** mismos recursos de host que full-pods (colores Status + fuentes en `CustomFonts/`).
