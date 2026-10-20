# Informe de implementación — SDK Mobile iOS 4.0.0 (Samples)

**Repositorio:** `sdk-mobile-ios-samples`  
**Referencia de integración:** `sdkmobile-demos-ios/sdkmobile-demo-full-pods`  
**Fecha:** 2026-10-20  

## Resumen

Se ha migrado el código y la configuración de las **12 demos** de **2.12.x** a **4.0.0** (CocoaPods `~> 4.0.0`), alineando la estructura de inicialización del SDK con la demo Full de clienters. La validación de compilación con pods **4.0.0** queda **bloqueada** hasta que los artefactos estén publicados en Artifactory (`cocoa-pro-fphi`); en el índice local la versión más alta de `FPHISDKMainComponent` sigue siendo **2.12.0**.

## Cambios mayores de integración (4.0)

### 1. `SDKController.initSdk`

Nueva firma orientada a sesión visual, locale y behavior opcional (ver `SDK-Sdk-SPM/Sources/sdk/SDKController.swift`):

| Parámetro | Uso en samples |
|-----------|----------------|
| `locale` | `"es"` o `SdkLocale.rawValue` (full / onboarding) |
| `sessionVisualOptions` | `nil` en demos simples; `SdkConfigurationManager.demoSessionVisualOptions` en **full** |
| `behaviorController` | `nil` en todas las samples |
| `analyticsOutput` | Callback de analytics en **full**, **onboarding**, **idv** |
| `trackingController` | En **full**, `nil` cuando el tracking es **MidApi** (misma lógica que full-pods) |

**Antes de init:** `ThemeStatusManager.setup(theme: CustomThemeStatus())` en todas las demos que usan Status (se añadió `demosdk/Themes/CustomThemeStatus.swift` donde faltaba).

### 2. Cancelación de flujo

- **Antes:** `flowController?.cancelFlow()` (ya no disponible en la API pública).
- **Ahora:** `SDKController.shared.cancelLaunch()` (+ limpieza local del `FlowController` donde aplica).
- La UI de **idv** mantiene el nombre `cancelFlow()` en el VM, pero delega en `SDKManager.cancelLaunch()`.

### 3. SelphID (KMP)

| 2.x | 4.0 |
|-----|-----|
| `FPHISDKSelphIDMBSDRComponent` | `FPHISDKSelphIDComponent` |
| Sin extractors en host | Pods host `FPHISelphIDExtractorV1/V2/V3` + carpeta `Library/SDKConfigurations/Extractors/` |
| — | `SelphIDController(..., extractors: SelphIDExtractorProvider.makeAllExtractors(), ...)` **obligatorio** |

Demos con SelphID actualizadas: **full**, **classic**, **classic-videorecording**, **idv**, **onboarding**.

### 4. Plataforma y CocoaPods

- **iOS mínimo:** `16.0` (`platform :ios, '16.0'` + `post_install` en Podfiles que lo reescribieron).
- **NFC:** mismo pin `FPHISDKNFCComponent ~> 4.0.0` (ya no hace falta pin separado 2.20).
- **VideoCall / Full:** `source 'https://github.com/livekit/podspecs.git'`; extensión de broadcast alineada con full-pods (`target 'videoRecording'`).

### 5. Demo Full

- `SDKManager`, `SdkConfigurationManager`, helpers y gran parte de `demosdk/Library/` sincronizados con **full-pods** (MidApi, `TrackingVersion`, extractors, validaciones, KMP custom views).
- Configuración de licencias/API en samples usa **placeholders** (claves vacías, `customerId` tipo clienters) para no commitear secretos; hay que rellenar `SdkConfigurationManager` / `Environment` como en clienters antes de probar en STG.

## Demos tocadas

| Demo | Dependencias 4.0 | initSdk / Theme | SelphID extractors | Notas |
|------|-------------------|-----------------|-------------------|--------|
| sdkmobile-demo-full | Sí | Completo + session visual | Sí | Proyecto Xcode alineado con full-pods |
| onboarding-fileuploader.demo | Sí | locale + analytics | Sí | — |
| sdkmobile-demo-classic-pods | Sí | Sí | Sí | — |
| sdkmobile-demo-classic-videorcording.pods | Sí | Sí | Sí | + VideoRecording |
| sdkmobile-demo-idv | Sí | Actualizado en esta pasada | Sí | Flujos IDV |
| sdkmobile-demo-selphi-pods | Sí | Sí | — | — |
| sdkmobile-demo-nfc-pods | Sí | Sí | — | — |
| sdkmobile-demo-videoid | Sí | Sí | — | — |
| sdkmobile-demo-videocall-pods | Sí | Corregido videocall | — | LiveKit source |
| sdkmobile-demo-voiceid-pods | Sí | Sí | — | — |
| sdkmobile-demo-phingers-pods | Sí | Sí | — | — |
| sdkmobile-demo-signature-pods | Sí | Sí | — | — |

## Scripts añadidos / actualizados

| Script | Función |
|--------|---------|
| `scripts/build_all_samples.sh` | `pod install --repo-update` + `xcodebuild` por demo (destino por defecto: iPhone 17, iOS 26.2) |
| `scripts/add_selphid_extractors_to_pbxproj.py` | Registra Extractors en el proyecto Xcode |
| `scripts/add_custom_theme_status_to_pbxproj.py` | Registra `CustomThemeStatus.swift` |

## Validación de builds (2026-10-20)

Comando: `./scripts/build_all_samples.sh`

| Resultado | Motivo |
|-----------|--------|
| **12/12 FAIL** en `pod install` | Ningún podspec `FPHISDK* 4.0.0` en `cocoa-pro-fphi` (índice local hasta **2.12.0**) |

Detalle en `BUILD_REPORT_4.0.0.txt`.

### Cómo revalidar cuando exista 4.0.0 en Artifactory

```bash
pod repo-art add cocoa-pro-fphi "https://facephicorp.jfrog.io/artifactory/api/pods/cocoa-pro-fphi"   # si no existe
pod repo-art update cocoa-pro-fphi
cd sdk-mobile-ios-samples
./scripts/build_all_samples.sh
```

Requisitos: `~/.netrc` con credenciales JFrog, plugin `cocoapods-art`, Xcode con simulador compatible (ajustar destino en el script si hace falta).

## Demos Classic 4.0.0-classic (EST-1098)

| Demo | Pod classic |
|------|-------------|
| `sdkmobile-demo-selphi-classic-pods` | `FPHISDKSelphiClassicComponent` `4.0.0-classic` |
| `sdkmobile-demo-selphid-classic-pods` | `FPHISDKSelphIDClassicComponent` `4.0.0-classic` |

- Módulos: `selphiClassicComponent` / `selphidClassicComponent` (sin extractors KMP en SelphID).
- Licencia: placeholders vacíos en `SdkConfigurationManager` (mismo criterio que el resto de samples públicos).
- Build: requiere specs `4.0.0` y `4.0.0-classic` en Artifactory; si faltan, usar `:path` a `*-Test.podspec` en `SDK-Selphi_component-SPM` / `SDK-SelphidComponent`.

## Secretos y configuración pública

Antes de publicar la rama **4.0.X** en GitHub:

- **Demo full:** `SdkConfigurationManager` y `SdkSelphidConfigManager` usan placeholders (API keys vacías, URLs simbólicas, licencias offline vacías). No incluir envelopes copiados de `sdkmobile-demo-full-pods`.
- **URLs de servicio** en código de demo (`VOICE_SDK_BASE_URL`, `EXTERNAL_SDK_BASE_URL`, validaciones): rellenar solo en local o vía Environment; no commitear endpoints STG/DEV reales si el equipo lo restringe.
- **Onboarding:** `SdkConfigurationManager` ya usa claves simbólicas (`licensingApiKey`, `devUrl`, …); mantener así.
- **README:** solo mencionan `~/.netrc` y `<TOKEN>` genérico (OK).

## Configuración que debe revisar el integrador

1. **Licencias y API keys** en `SdkConfigurationManager` (y pantalla Environment en full).
2. **Customer ID / flow IDs** acordes al tenant de pruebas.
3. **Extensión VideoRecording / VideoCall:** bundle id `com.facephi.sdk.demo.videoRecording` (idv/onboarding/full según demo).
4. **SelphID:** mantener versiones de extractors host en Podfile (`kmp_selphid_host_extractors`) alineadas con la release 4.0.

## Documentación del repo

- `README.md` (raíz) actualizado a **4.0.0**.
- READMEs por demo: versión SDK y referencia a SelphID KMP donde aplica.

## Riesgos / follow-up

- Hasta publicar pods **4.0.0**, no se puede confirmar compilación Swift contra binarios reales (posibles breaking changes menores no detectados).
- **Phingers** en simulador: revisar slices arm64 cuando exista el pod 4.0.0 (histórico en 2.12).
- Tras el primer `pod install` OK, ejecutar smoke test manual en dispositivo (NFC, VideoCall + extensión, VideoRecording).
