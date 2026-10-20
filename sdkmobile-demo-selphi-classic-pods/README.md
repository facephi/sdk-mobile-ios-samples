# SDK Mobile — demo Selphi Classic (4.0.0-classic)

Sample mínima para probar **`FPHISDKSelphiClassicComponent`** (`4.0.0-classic`) con Main, Tracking, Status y Tokenize.

Basada en la demo full. Rellena `APIKEY_LICENSING`, `LICENSING_URL` y/o `license` en `SdkConfigurationManager` en local (no subir credenciales al repo público).

## Pods

Mismo patrón que `sdkmobile-demo-full-pods`: variable **`fphi_pods`** en el `Podfile`:

| Modo | Uso |
|------|-----|
| `"remote"` | Artifactory: Main, Tracking, Status, Tokenize `~> 4.0.0` + `FPHISDKSelphiClassicComponent` **`4.0.0-classic`** |
| `"local"` | `*-Test.podspec` en repos hermanos (`SDK-Core-SPM`, `SDK-Sdk-SPM`, `SDK-Selphi_component-SPM`, …) |
| `"local_frameworks"` | `*-template.podspec` (xcframeworks locales) |

Componentes: LicenseChecker, Core, Main, Tracking, **SelphiClassic**, Status, Tokenize.

## Uso

1. `~/.netrc` con Artifactory Facephi.
2. Ajustar `fphi_pods` en `Podfile` si hace falta.
3. `pod repo-art update cocoa-dev-fphi` (modo remote).
4. `pod install`
4. Abrir `demosdk.xcworkspace`, ejecutar en dispositivo/simulador.
5. **New Operation** → **Selphi**.

Módulo Swift: `selphiClassicComponent`.

**Status:** colores en `Assets.xcassets` (`sdkBackgroundPrimaryColor`, `sdkButtonBackgroundColor`, …) + `Resources/CustomFonts/` como en `sdkmobile-demo-full-pods` (tutorial/diagnóstico/permisos).
