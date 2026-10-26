# Demo NFC

Aplicación demo para validar un flujo de onboarding con el SDK de Facephi.

## Resumen

**Componentes**
- Core
- SDK
- NFC
- SelphID

**Qué permite**
- Captura de datos del documento con SelphID (MRZ)
- Lectura del chip NFC con datos capturados o manuales

Desde el SDK 4.0.0, la configuración de SelphID se organiza en bloques (`uiConfiguration`, `extractionConfiguration`...) en vez de una lista plana de campos, y `SelphIDController` necesita una lista de extractores de documentos (`FPHISelphIDExtractorV1`/`FPHISelphIDExtractorV3` en esta demo).

## Flujo de la aplicación

1. **Términos y condiciones**: tras inicializar el SDK y crear una nueva operación, se muestra una pantalla con los términos de uso (`TermsConditionsController`). Es necesario aceptarlos para continuar.
2. **Pantalla principal con pestañas**:
   - **SelphID + NFC**: primero se capturan los datos del documento con la cámara leyendo el MRZ; después esos datos se usan para leer el chip NFC. En las opciones se puede cambiar el tipo de documento a leer.
   - **NFC**: permite introducir manualmente los datos necesarios para leer el chip NFC.

## Configuración

### Repositorio CocoaPods

Requisitos: Xcode, CocoaPods, iOS 15.0+ y SDK 4.0.0. La lectura NFC requiere un iPhone físico.

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

### Pods

Después declara el repositorio y los pods en el `Podfile` (repositorio de producción `cocoa-pro-fphi`):

```ruby
plugin 'cocoapods-art', :sources => ['cocoa-pro-fphi']

source 'https://cdn.cocoapods.org/'

target 'demosdk' do
  use_frameworks!

  pod 'FPHISelphIDExtractorV1', '~> 1.2.4'
  pod 'FPHISelphIDExtractorV3', '~> 1.2.6'
  pod 'FPHISDKMainComponent', '~> 4.0.0'
  pod 'FPHISDKSelphIDComponent', '~> 4.0.0'
  pod 'FPHISDKNFCComponent', '~> 4.0.0'
  pod 'FPHISDKTermsConditionsComponent', '~> 4.0.0'
end
```

Instala las dependencias y abre el workspace (no el `.xcodeproj`):

```bash
pod install
open demosdk.xcworkspace
```

### Capacidad NFC

El target necesita la capacidad *Near Field Communication Tag Reading* (`demosdk.entitlements`, formato `TAG`), los identificadores de aplicación ISO 7816 (`com.apple.developer.nfc.readersession.iso7816.select-identifiers`) en el `Info.plist` y el texto `NFCReaderUsageDescription` (build setting `INFOPLIST_KEY_NFCReaderUsageDescription`); todo ello ya está configurado en esta demo. El App ID de tu bundle identifier debe tener la capacidad NFC habilitada.

### Posibles problemas con CocoaPods

- Si CocoaPods se instaló con Homebrew puede dar problemas. Se recomienda la instalación mediante gem.
- Si los pods no se resuelven o se usa una versión antigua, limpia la caché y reinstala:

```bash
pod cache clean --all
rm -rf Pods Podfile.lock
pod install
```

## Configuración del SDK

La estructura `SdkConfigurationManager` (`Library/SDKConfigurations/SdkConfigurationManager.swift`) almacena todos los datos necesarios. `SDKManager` (`Library/SDKManager.swift`) encapsula las llamadas al SDK (`initSdk`, `newOperation`, `launchTermsConditions`, `launchSelphId`, `launchNfc`, `closeSession`).

**Licencia vía servicio o como String, identificador del cliente y operación**

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

**Inicialización del SDK y nueva operación**

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

**Configuración de SelphID (MRZ del documento) y lanzamiento de los componentes**

```swift
var config = SelphIDConfigurationData()
config.extractionConfiguration.captureMode = .MRZ
config.extractionConfiguration.documentTypes = [.ID_CARD]
config.extractionConfiguration.documentCountries = ["ES"]
config.extractionConfiguration.generateRawImages = true
```

```swift
// 1. Capture the document data with SelphID (MRZ)
let selphId = SelphIDController(
    data: selphIDConfigurationData,
    extractors: SelphIDExtractorProvider.makeAllExtractors(),
    output: output,
    viewController: viewController
)
SDKController.shared.launch(controller: selphId)

// 2. Read the NFC chip with the captured (or manually entered) data
let nfc = NfcController(
    data: nfcConfigurationData,   // documentNumber, birthDate, expirationDate, documentType...
    viewController: viewController,
    output: output,
    stateDelegate: observer       // NfcWidgetDelegateProtocol
)
SDKController.shared.launch(controller: nfc)
```

Cuando se termina de usar el SDK hay que cerrar la sesión:

```swift
SDKController.shared.closeSession()
```

> IMPORTANTE: el bundle identifier de la aplicación debe coincidir con el solicitado en la licencia.

> Nota: el `NfcConfigurationData` de iOS no admite `maxAttempts`, por lo que el valor seleccionado en la UI no se envía al componente NFC.

## Ejecutar la demo

1. En Xcode (target `demosdk` -> Signing & Capabilities), establece el Bundle Identifier con el de la aplicación para la que se ha solicitado la licencia y selecciona tu equipo de firma.
2. Añade a `~/.netrc` las credenciales de Artifactory proporcionadas por Facephi (ver sección 2.1).
3. Ejecuta `pod repo-art update cocoa-pro-fphi` y `pod install`, y abre `demosdk.xcworkspace`.
4. En `SdkConfigurationManager.swift` rellena los datos del servicio de licencias (`APIKEY_LICENSING`, `LICENSING_URL`) o la licencia como String (`license`).
5. Según cómo se haya añadido la licencia, ajusta `onlineLicensing` (`true` para el servicio de licencias, `false` para la licencia como String).
6. Ejecuta la app en un iPhone físico con NFC.

## Enlaces

- Documentación del SDK: https://docs.facephi.com/sdks/sdk-mobile/ios-sdk
