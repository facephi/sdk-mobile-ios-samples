# DEMO CLASSIC ONBOARDING


## 1. Introducción

En esta demo se puede realizar un proceso de onboarding utilizando el SDK de Facephi.
Los componentes utilizados son:

- Core
- Sdk
- Selphi
- SelphID
- VideoRecording
- Tracking

Esta demo no configura cada componente por separado: todo el flujo (Selphi, SelphID, inicio/parada de VideoRecording) lo dirige un único `FlowConfigurationData`, resuelto por el backend a partir de su `flowId`. No hay pantallas locales de configuración de Selphi/SelphID/VideoRecording.

## 2. Detalle de la aplicación demo

### 2.1 Dependencias

Requisitos: Xcode, CocoaPods, iOS 15.0+ y SDK 4.0.0.

Los pods de Facephi se publican en un repositorio privado de Artifactory. Las credenciales deben ser proporcionadas por Facephi y añadirse al fichero `~/.netrc`:

```
machine facephicorp.jfrog.io
login <USERNAME>
password <TOKEN>
```

La primera vez, instala el plugin de CocoaPods para Artifactory y registra el repositorio donde se encuentran los paquetes:

```bash
sudo gem install cocoapods-art
pod repo-art add cocoa-pro-fphi "https://facephicorp.jfrog.io/artifactory/api/pods/cocoa-pro-fphi"
```

Cada vez que se publique una nueva versión de algún componente, actualiza el índice del repositorio:

```bash
pod repo-art update cocoa-pro-fphi
```

Después declara el repositorio y los pods en el `Podfile` (repositorio de producción `cocoa-pro-fphi`):

```ruby
plugin 'cocoapods-art', :sources => ['cocoa-pro-fphi']

source 'https://cdn.cocoapods.org/'
source 'https://github.com/livekit/podspecs.git'

target 'demosdk' do
  use_frameworks!

  pod 'FPHISelphIDExtractorV1', '~> 1.2.4'
  pod 'FPHISelphIDExtractorV3', '~> 1.2.6'
  pod 'FPHISDKMainComponent', '~> 4.0.0'
  pod 'FPHISDKSelphIDComponent', '~> 4.0.0'
  pod 'FPHISDKSelphiComponent', '~> 4.0.0'
  pod 'FPHISDKTrackingComponent', '~> 4.0.0'
  pod 'FPHISDKVideoRecordingComponent', '~> 4.0.0'
end
```

Desde el SDK 4.0.0, VideoRecording incorpora una dependencia transitiva publicada en el repositorio de podspecs de LiveKit, por lo que también hay que declarar esa fuente en el `Podfile` (ver arriba).

Instala las dependencias y abre el workspace (no el `.xcodeproj`):

```bash
pod install
open demosdk.xcworkspace
```

#### Posibles problemas con CocoaPods

- Si CocoaPods se instaló con Homebrew puede dar problemas. Se recomienda la instalación mediante gem.
- Si los pods no se resuelven o se usa una versión antigua, limpia la caché y reinstala:

```bash
pod cache clean --all
rm -rf Pods Podfile.lock
pod install
```

`FPHISelphIDExtractorV1` y `FPHISelphIDExtractorV3` son los extractores de documentos que `SelphIDController` necesita desde el SDK 4.0.0.

### 2.2 Uso del SDK

La documentación del SDK:

https://docs.facephi.com/sdks/sdk-mobile/ios-sdk

#### 2.2.1 Inicialización del SDK

El SDK se utiliza a través del objeto `SDKController` (`SDKController.shared`). Solo es necesario inicializarlo una vez.
1. Se decide si la licencia se obtiene del servicio de licencias o se proporciona como String.
2. Si la inicialización devuelve `.STATUS_OK` el SDK está listo para usarse.

```swift
let trackingController = TrackingController(trackingError: { error in
    log("Tracking Error: \(error)")
})

let analyticsOutput: AnalyticsOutput = { time, componentName, eventType, info in
    print("APP - *** \(Date(timeIntervalSince1970: time / 1000)) - \(componentName) - \(eventType) - \(info)")
}

SDKController.shared.initSdk(
    licensingUrl: SdkConfigurationManager.LICENSING_URL,
    apiKey: SdkConfigurationManager.APIKEY_LICENSING,
    output: output,   // (SdkResult<String>) -> Void, .STATUS_OK when the SDK is ready
    trackingController: trackingController,
    analyticsOutput: analyticsOutput
)
```


La estructura **SdkConfigurationManager** almacena todos los datos necesarios para el SDK (ver sección 2.2.4).

#### 2.2.2 Lanzamiento del proceso de onboarding IDV

Los flujos disponibles se obtienen con `FlowController.getFlowIntegrationData()` y el `flowId` seleccionado se lanza mediante `FlowController`:

```swift
let flows = FlowController.getFlowIntegrationData()   // [IntegrationFlowData]
```

```swift
let selphiController = SelphiController(data: nil, output: { _ in }, viewController: viewController)
let selphIdController = SelphIDController(
    data: nil,
    extractors: SelphIDExtractorProvider.makeAllExtractors(),
    output: { _ in },
    viewController: viewController
)
let videoRecordingController = VideoRecordingController(viewController: viewController, output: { _ in })
let stopVideoRecordingController = StopVideoRecordingController(
    videoRecordingController: videoRecordingController,
    output: { _ in }
)

let flowConfigurationData = FlowConfigurationData(
    id: flowId,
    controllers: [selphiController, selphIdController, stopVideoRecordingController, videoRecordingController],
    customerId: SdkConfigurationManager.CUSTOMER_ID
)

let flowController = FlowController(flowConfigurationData: flowConfigurationData, output: { flowResult in
    // flowResult.step, flowResult.operationId, flowResult.flowFinish
})
SDKController.shared.launch(controller: flowController)
```

La lista de controladores del flujo usa la variante de flujo de cada componente. Desde el SDK 4.0.0, `SelphIDController` también necesita la lista de extractores de documentos a usar (`SelphIDExtractorProvider.makeAllExtractors()`, que proporciona los extractores V1 y V3).

#### 2.2.3 Cierre de sesión

Cuando se termina de usar el SDK hay que cerrar la sesión:

```swift
SDKController.shared.closeSession()
```

#### 2.2.4 Datos necesarios para el uso del SDK

Para que la aplicación funcione correctamente hay que rellenar la siguiente información en la estructura `SdkConfigurationManager` (`Library/SDKConfigurations/SdkConfigurationManager.swift`):

```swift
struct SdkConfigurationManager {
    // Licensing service
    static let APIKEY_LICENSING = "YOUR_API_KEY"
    static let LICENSING_URL = URL(string: "https://license.identity-platform.io")!

    // Customer identifier
    static let CUSTOMER_ID = "YOUR_CUSTOMER_ID"
}
```

- Datos del servicio de licencias (con `onlineLicensing = true`): `APIKEY_LICENSING` y `LICENSING_URL`.
- `CUSTOMER_ID`: identificador del cliente usado en el flujo.
- El `flowId` no se guarda en la app: se elige entre los flujos que devuelve el backend.
- IMPORTANTE: El bundle identifier de la aplicación debe coincidir con el solicitado en la licencia (target `demosdk` -> Signing & Capabilities).

### 2.3 Pasos para iniciar la demo

Los pasos a seguir para iniciar la demo son:

1. En Xcode (target `demosdk` -> Signing & Capabilities), establece el Bundle Identifier con el de la aplicación para la que se ha solicitado la licencia y selecciona tu equipo de firma.
2. Añade a `~/.netrc` las credenciales de Artifactory proporcionadas por Facephi (ver sección 2.1).
3. Ejecuta `pod repo-art update cocoa-pro-fphi` y `pod install`, y abre `demosdk.xcworkspace`.
4. En `SdkConfigurationManager.swift` rellena los datos del servicio de licencias (`APIKEY_LICENSING`, `LICENSING_URL`) y `CUSTOMER_ID`.
5. Ejecuta la app en un dispositivo físico (se necesita cámara) y elige uno de los flujos listados tras inicializar el SDK.
