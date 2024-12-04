# DEMO VIDEO IDENTIFICACIÓN


## 1. Introducción

En esta demo se puede realizar un proceso de video identificación utilizando el SDK de Facephi.
Los componentes utilizados son:

- FPHISDKLicenseCheckerComponent
- FPHISDKCoreComponent
- FPHISDKLicensingComponent
- FPHISDKMainComponent
- FPHISDKTrackingComponent
- FPHISDKVideoIDComponent
- FPHISDKTokenizeComponent


## 2. Detalle de la aplicación demo

### 2.1 Dependencias

#### Cocoapod

- Si es la **primera vez** que se va a utilizar el repositorio privado instalar Cocoapods para Artifactory: 

```
sudo gem install cocoapods-art
```
Con un Mac M1 es posible que surjan errores en el futuro, de ser así, se recomienda usar en cambio el siguiente comando:
```
sudo arch -arm64 gem install ffi; sudo arch -arm64 gem install cocoapods-art
```
En caso de tener problemas con la instalación, desinstalar completamente cocoapods y todas sus dependencias para hacer una instalación limpia. El equipo de Facephi cuenta con un script que automatiza este proceso.

Necesitaremos añadir el repositorio a la lista del fichero netrc.

```
$ nano ~/.netrc
```

Y en este copiamos lo siguiente con los datos correspondientes al final del fichero:

```
machine facephicorp.jfrog.io
login <USERNAME>
password <TOKEN>
```
Ahora añadiremos dos repos, los que contienen dependencias privadas y el que conecta con el exterior. Estos comandos se ponen en la consola:

```
pod repo-art add cocoa-pro-fphi "https://facephicorp.jfrog.io/artifactory/api/pods/cocoa-pro-fphi"
```

Tras esto, ya se podrían instalar e integrar los paquetes en la app, ejecutando el Podfile y el siguiente comando:

`pod install`

En caso de liberarse una versión nueva de alguno de los componentes de la SDK Mobile, se deberá actualizar el repositorio añadido previamente, para que se actualicen los cambios que se han realizado. Para ello, se deberá ejecutar el siguiente comando:

`pod repo-art update cocoa-pro-fphi`


##### Cómo importar el pod

Necesitaremos añadir unas lineas a nuestro Podfile para que pueda identificar el pod privado que queremos obtener

```
plugin 'cocoapods-art', :sources => [
  'cocoa-pro-fphi’
]
Si fuésemos a importar Nfc, el Podfile se quedaría tal que así:

source 'https://cdn.cocoapods.org/'
source '...'

target 'Example' do
  pod 'IQKeyboardManagerSwift'
  pod 'SwiftLint'
  pod 'FPHISDKLicenseCheckerComponent', '~> 1.4.0'
  pod 'FPHISDKCoreComponent', '~> 1.4.0'
  pod 'FPHISDKLicensingComponent', '~> 1.4.0'
  pod 'FPHISDKMainComponent', '~> 1.4.0'
  pod 'FPHISDKTrackingComponent', '~> 1.4.0'
  pod 'FPHISDKVideoIDComponent', '~> 1.4.0'
  pod 'FPHISDKTokenizeComponent', '~> 1.4.0'
...
end
```

Cuando se quiera actualizar dependencias, antes del $ pod install hay que hacer el siguiente comando:

```
pod repo-art update cocoa-pro-fphi
```


### 2.2 Uso del SDK

#### 2.2.1 Inicialización del SDK

La inicialización del SDK se hará con una única función [initSdk]. Existen 2 maneras de usarla en función de cómo se vaya a obtener la licencia. 

A la función se le pasarán los siguientes datos:

- Application

- La licencia en String o los datos para obtenerla a través del servicio se tienen que incluir la URL y el API KEY del mismo (EnvironmentLicensingData).

- El controlador de TrackingController si se quiere conectar con la plataforma

#### 2.2.2 Creación de una operación

```
    public func newOperation(operationType: sdk.OperationType, customerId: String, output: @escaping (SdkResult<String>) -> ()) {
        log("newOperation - start, device, coordinates, customerId - \(customerId)")
        
        SDKController.shared.newOperation(operationType: operationType, customerId: customerId, output: output)
    }
```

#### 2.2.3 Lanzamiento de controladores

Una vez creada la operación se podrán lanzar los controladores del SDK. 

Formas de lanzamiento:
```
    SDKController.shared.launch(controller: controller)
```
    Es un lanzamiento que incluye el trackeo a la plataforma
    
```
    SDKController.shared.launchMethod(controller: controller)
```
    Es un lanzamiento que NO incluye el trackeo a la plataforma

#### 2.2.4 Video Identificación

```
    func videoId() {
        SDKManager.shared.launchVideoId(data: SdkConfigurationManager.videoIDConfiguration, setTracking: true, viewController: viewController, output: { videoIdResult in
            if videoIdResult.finishStatus == .STATUS_OK {
                self.log(msg: "Status OK \(videoIdResult.finishStatus)")
            } else {
                self.log(msg: "Status KO \(videoIdResult.errorType)")
            }
        })
    }
```
#### 2.2.5 Cierre de sesión

Debe lanzarse al destruir la App

```
        SDKController.shared.closeSession()     
```
#### 2.2.6 Datos necesarios para el uso del SDK

Para que la aplicación funcione correctamente se deberán rellenar los siguientes datos.

En la clase SdkConfigurationManager:

- Datos necesarios si se va a utilizar un servicio para obtener las licencias:

```
    static let APIKEY_LICENSING = "...."
    static let LICENSING_URL = URL(string: "https://...")!
```

- String de la licencia si no se va a utilizar un servicio:
```
    static let license = """
    {
    ...
    }
    """
```

- Identificador del cliente y tipo de operación que se va a utilizar en la inicialización:
```
    static let CUSTOMER_ID = "sdk-videoid-ios@ejemplo"
```

