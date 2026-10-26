# DEMO CLASSIC ONBOARDING

## 1. Introducción

En esta demo se puede realizar un proceso de onboarding utilizando el SDK de Facephi.
Los componentes utilizados son:

- Core
- Sdk
- Selphi

## 2. Detalle de la aplicación demo

### 2.1 Dependencias

La demo descarga las librerías de Facephi con CocoaPods desde el repositorio privado de Artifactory. Versión mínima de iOS: iOS 15.0+. Versión del SDK: 4.0.0.

1. Las credenciales proporcionadas por Facephi deben incluirse en el fichero `~/.netrc`:

```
machine facephicorp.jfrog.io
login TU_USUARIO_ARTIFACTORY
password TU_TOKEN_ARTIFACTORY
```

2. Instalar el plugin de CocoaPods para Artifactory (solo la primera vez):

```
sudo gem install cocoapods-art
```

3. Añadir el repositorio donde se alojan los paquetes y mantenerlo actualizado (ejecutar la actualización cada vez que se publique una nueva versión del SDK):

```
pod repo-art add cocoa-pro-fphi "https://facephicorp.jfrog.io/artifactory/api/pods/cocoa-pro-fphi"
pod repo-art update cocoa-pro-fphi
```

4. El Podfile debe declarar el repositorio como fuente:

```ruby
plugin 'cocoapods-art', :sources => ['cocoa-pro-fphi']
```

5. Las dependencias de las librerías se declaran en el Podfile:

```ruby
pod 'FPHISDKMainComponent', '~> 4.0.0'
pod 'FPHISDKSelphiComponent', '~> 4.0.0'
```

6. Instalar los pods y abrir el workspace (no el `.xcodeproj`):

```
pod install
open demosdk.xcworkspace
```

#### 2.1.1 Posibles problemas con CocoaPods

- Si CocoaPods se instaló con Homebrew puede dar problemas; se recomienda la instalación mediante gems.
- Si los pods no se resuelven tras una nueva versión, limpiar la caché y reinstalar:

```
pod cache clean --all
pod repo-art update cocoa-pro-fphi
pod install --repo-update
```

### 2.2 Uso del SDK

La documentación del SDK:

https://docs.facephi.com/sdks/sdk-mobile/ios-sdk

#### 2.2.1 Inicialización del SDK

El SDK se utiliza a través del objeto `SDKController.shared`. Este objeto debe inicializarse una sola vez (ver `SDKManager.initSdk`).
1. Se decide si la licencia se incluirá mediante un String o con un servicio de licencias remoto (`SdkConfigurationManager.onlineLicensing`).
2. El closure `output` informa del resultado de la inicialización.
3. Si la inicialización devuelve `STATUS_OK` el driver del SDK estará listo para su uso.

```swift
let output: (SdkResult<String>) -> Void = { sdkResult in
    if sdkResult.finishStatus == .STATUS_OK {
        log("INIT SDK OK")
    } else {
        log("INIT SDK ERROR: \(sdkResult.errorType)")
    }
}

if SdkConfigurationManager.onlineLicensing {
    SDKController.shared.initSdk(
        licensingUrl: SdkConfigurationManager.LICENSING_URL,
        apiKey: SdkConfigurationManager.APIKEY_LICENSING,
        output: output
    )
} else {
    SDKController.shared.initSdk(
        license: SdkConfigurationManager.license,
        output: output
    )
}
```

La estructura **SdkConfigurationManager** almacena todos los datos necesarios para el SDK. (Sección 2.2.5)

#### 2.2.2 Creación de una operación

Para iniciar una operación de ONBOARDING o AUTHENTICATION hay que crear una nueva operación. Para ello se utiliza la función `SDKController.shared.newOperation`, que tiene estos parámetros de entrada:

1. operationType: Indica si se va a realizar un proceso de ONBOARDING o de AUTHENTICATION
2. customerId: Identificador del usuario, si se dispone de él
3. output: Closure que devuelve el resultado de la operación

En esta demo el proceso se lanza desde un botón en `MainViewModel`:

```swift
SDKManager.shared.newOperation(
    operationType: SdkConfigurationManager.OPERATION_TYPE,
    customerId: SdkConfigurationManager.CUSTOMER_ID
) { result in
    if result.errorType == .NO_ERROR {
        log("NEW OPERATION: OK")
    } else {
        log("NEW OPERATION: Error - \(result.errorType)")
    }
}
```

#### 2.2.3 Captura facial

La captura facial se realiza mediante Selphi.
En esta demo el proceso se lanza desde un botón en `MainViewModel`:

```swift
var configSelphi = SelphiConfigurationData()
configSelphi.livenessMode = .LIVENESS_PASSIVE
configSelphi.maxAttempts = 3
configSelphi.facialConfiguration.selphiCameraConfiguration.cameraPreferred = .FRONT
configSelphi.facialConfiguration.selphiCameraConfiguration.showTutorial = true
configSelphi.facialConfiguration.selphiCameraConfiguration.showPreviousTip = true
configSelphi.facialConfiguration.selphiCameraConfiguration.showDiagnostic = true
configSelphi.iadConfiguration.enabled = false
```

```swift
let controller = SelphiController(data: configSelphi, output: output, viewController: viewController)
SDKController.shared.launch(controller: controller)

// output:
// result.errorType == .NO_ERROR -> log("Selphi: OK")
// otherwise                     -> log("Selphi: Error - \(result.errorType)")
```

#### 2.2.4 Cierre de sesión

Al terminar de usar el SDK hay que cerrar la sesión:

```swift
_ = SDKController.shared.closeSession()
```

#### 2.2.5 Datos necesarios para el uso del SDK

Para que la aplicación funcione correctamente hay que rellenar la siguiente información.

En la estructura `SdkConfigurationManager`:

- Datos necesarios si se va a utilizar un servicio para obtener las licencias (`onlineLicensing = true`):

```swift
static let onlineLicensing = true
static let APIKEY_LICENSING = "YOUR_API_KEY"
static let LICENSING_URL = URL(string: "https://license.identity-platform.io")!
```

- String de licencia si no se va a utilizar un servicio (`onlineLicensing = false`):

```swift
static let license = "YOUR_LICENSE"
```

- Identificador de cliente y tipo de operación a utilizar en `newOperation`:

```swift
static let CUSTOMER_ID = "demo_selphi@email.com"
static let OPERATION_TYPE: OperationType = .ONBOARDING
```

- Desde el SDK 4.0.0, `SelphiConfigurationData` se agrupa en bloques (`facialConfiguration`, `iadConfiguration`...) en lugar de una lista plana de campos. Ya no utiliza un ZIP de recursos: la personalización visual se realiza mediante el sistema general de personalización del SDK.

- En caso de utilizar los servicios de verificación (liveness y matching), hay que informar la llamada al servicio

- IMPORTANTE: El bundle identifier de la aplicación debe coincidir con el solicitado en la licencia

### 2.3 Servicios de verificación

Si el cliente tiene acceso al servicio de verificación, puede utilizar Liveness y MatchingFacial. Para ello será necesario haber realizado previamente el reconocimiento facial y del documento.

### 2.4 Pasos para iniciar la demo

Los pasos a seguir para iniciar la demo son:

1. En Xcode (target `demosdk` -> Signing & Capabilities), informar el Bundle Identifier con el de la aplicación para la que se ha solicitado la licencia.

2. En el fichero `~/.netrc` añadir las credenciales de Artifactory proporcionadas por Facephi (ver sección 2.1).

3. Ejecutar `pod install` y abrir `demosdk.xcworkspace`.

4. En el fichero `SdkConfigurationManager.swift` añadir los datos del servicio del que se obtendrá la licencia o la licencia en String:

```swift
static let APIKEY_LICENSING = "YOUR_API_KEY"
static let LICENSING_URL = URL(string: "https://license.identity-platform.io")!
```

o

```swift
static let license = "YOUR_LICENSE"
```

5. Según cómo se haya añadido la licencia, adaptar el valor de la variable:

```swift
static let onlineLicensing = true // false si se usa el String de licencia
```
