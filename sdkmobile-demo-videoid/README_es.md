# DEMO VIDEO ID


## 1. Introducción

En esta demo se puede realizar un proceso de onboarding utilizando el SDK de Facephi.
Los componentes utilizados son:

- Core
- Sdk
- VideoId

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

  pod 'FPHISDKMainComponent', '~> 4.0.0'
  pod 'FPHISDKVideoIDComponent', '~> 4.0.0'
end
```

Desde el SDK 4.0.0, VideoID incorpora una dependencia transitiva publicada en el repositorio de podspecs de LiveKit, por lo que también hay que declarar esa fuente en el `Podfile` (ver arriba).

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

### 2.2 Uso del SDK

La documentación del SDK:

https://docs.facephi.com/sdks/sdk-mobile/ios-sdk

#### 2.2.1 Inicialización del SDK

El SDK se utiliza a través del objeto `SDKController` (`SDKController.shared`). Solo es necesario inicializarlo una vez.
1. Se decide si la licencia se obtiene del servicio de licencias o se proporciona como String.
2. Si la inicialización devuelve `.STATUS_OK` el SDK está listo para usarse.

```swift
let output: (SdkResult<String>) -> Void = { sdkResult in
    if sdkResult.finishStatus == .STATUS_OK {
        log("INIT SDK OK")
    } else {
        log("INIT SDK ERROR: \(sdkResult.errorType)")
    }
}

let analyticsOutput: AnalyticsOutput = { time, componentName, eventType, info in
    print("APP - *** \(Date(timeIntervalSince1970: time / 1000)) - \(componentName) - \(eventType) - \(info)")
}

if SdkConfigurationManager.onlineLicensing {
    // License obtained from the licensing service
    SDKController.shared.initSdk(
        licensingUrl: SdkConfigurationManager.LICENSING_URL,
        apiKey: SdkConfigurationManager.APIKEY_LICENSING,
        output: output,
        analyticsOutput: analyticsOutput
    )
} else {
    // License as a String
    SDKController.shared.initSdk(
        license: SdkConfigurationManager.license,
        output: output,
        analyticsOutput: analyticsOutput
    )
}
```


La estructura **SdkConfigurationManager** almacena todos los datos necesarios para el SDK (ver sección 2.2.5).

#### 2.2.2 Creación de una operación

Para iniciar una operación de ONBOARDING o AUTHENTICATION hay que crear una nueva operación con `SDKController.shared.newOperation`. Tiene estos parámetros de entrada:

1. operationType: Indica si se va a realizar un proceso de ONBOARDING o AUTHENTICATION
2. customerId: Identificador del usuario si se dispone de él
3. output: Callback con el resultado de la operación

En esta demo se lanza desde un botón:

```swift
SDKController.shared.newOperation(
    operationType: SdkConfigurationManager.OPERATION_TYPE,
    customerId: SdkConfigurationManager.CUSTOMER_ID,
    output: { result in
        if result.errorType == .NO_ERROR {
            log("NEW OPERATION: OK")
        } else {
            log("NEW OPERATION: Error - \(result.errorType)")
        }
    }
)
```

#### 2.2.3 Captura de video

La captura de video se realiza mediante `VideoIdController`. `VideoIDConfigurationData` también acepta `customerId` para identificar al cliente frente al backend de video; en una instalación estándar no se informan `url`/`apiKey`/`tenantId`, ya que el SDK obtiene los datos de conexión de la licencia.

Configuración usada en esta demo:

```swift
VideoIDConfigurationData(
    mode: .FACE_DOCUMENT_FRONT_BACK,
    sectionTimeout: 20000,
    autoFaceDetection: autoFace,
    customerId: CUSTOMER_ID
)
```

```swift
let controller = VideoIdController(
    data: videoIDConfigurationData,
    output: output,
    viewController: viewController
)
SDKController.shared.launch(controller: controller)
```

En esta demo el proceso se lanza desde un botón:

```swift
SDKManager.shared.launchVideoId(
    viewController: viewController,
    videoIDConfigurationData: SdkConfigurationManager.videoIDConfiguration(autoFace: autoFace)
) { result in
    if result.errorType == .NO_ERROR {
        log("Video ID: OK")
    } else {
        log("Video ID: Error - \(result.errorType)")
    }
}
```

#### 2.2.4 Cierre de sesión

Cuando se termina de usar el SDK hay que cerrar la sesión:

```swift
SDKController.shared.closeSession()
```

#### 2.2.5 Datos necesarios para el uso del SDK

Para que la aplicación funcione correctamente hay que rellenar la siguiente información en la estructura `SdkConfigurationManager` (`Library/SDKConfigurations/SdkConfigurationManager.swift`):

```swift
struct SdkConfigurationManager {
    // Licensing service
    static let onlineLicensing = true
    static let APIKEY_LICENSING = "YOUR_API_KEY"
    static let LICENSING_URL = URL(string: "https://license.identity-platform.io")!

    // License as a String (used when onlineLicensing = false)
    static let license = ""

    // Customer identifier and operation type
    static let CUSTOMER_ID = "YOUR_CUSTOMER_ID"
    static let OPERATION_TYPE: OperationType = .ONBOARDING
}
```

- Datos del servicio de licencias (con `onlineLicensing = true`): `APIKEY_LICENSING` y `LICENSING_URL`.
- Licencia como String (con `onlineLicensing = false`): `license`.
- Identificador del cliente y tipo de operación a utilizar en la operación: `CUSTOMER_ID` y `OPERATION_TYPE`.
- IMPORTANTE: El bundle identifier de la aplicación debe coincidir con el solicitado en la licencia (target `demosdk` -> Signing & Capabilities).

### 2.3 Pasos para iniciar la demo

Los pasos a seguir para iniciar la demo son:

1. En Xcode (target `demosdk` -> Signing & Capabilities), establece el Bundle Identifier con el de la aplicación para la que se ha solicitado la licencia y selecciona tu equipo de firma.
2. Añade a `~/.netrc` las credenciales de Artifactory proporcionadas por Facephi (ver sección 2.1).
3. Ejecuta `pod repo-art update cocoa-pro-fphi` y `pod install`, y abre `demosdk.xcworkspace`.
4. En `SdkConfigurationManager.swift` rellena los datos del servicio de licencias (`APIKEY_LICENSING`, `LICENSING_URL`) o la licencia como String (`license`).
5. Según cómo se haya añadido la licencia, ajusta `onlineLicensing` (`true` para el servicio de licencias, `false` para la licencia como String).
6. Ejecuta la app en un dispositivo físico (se necesita cámara).
