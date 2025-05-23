# DEMO CLASSIC ONBOARDING


## 1. Introducción

En esta demo se puede realizar un proceso de onboarding utilizando el SDK de Facephi.
Los componentes utilizados son:

- Core
- Sdk
- NFC
- Tracking

## 2. Detalle de la aplicación demo

### 2.1 Dependencias

#### 2.1.1 Opción SPM

Xcode nos da la opción de importar nuestro Swift Package de la siguiente forma. Botón derecho al proyecto y “Add Packages…”

En el apartado de Github nos saldrán los paquetes de la empresa, pero para buscar uno en específico tenemos que poner el link que usaríamos para clonarlo. Finalmente, se pulsa en “Add Package”.

Si este tiene algún tipo de error, a la hora de importar lo indicará.

Para quitar un paquete importado, pulsamos el proyecto, “Package Dependencies” y le damos a “-”.

#### 2.1.2 Opción Cocoapod

Primero instalamos el comando que nos dará acceso a usar cocoapods con Artifactory.
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

##### 2.1.2.1 Cómo importar el pod

Necesitaremos añadir unas lineas a nuestro Podfile para que pueda identificar el pod privado que queremos obtener

```
plugin 'cocoapods-art', :sources => [
  'cocoa-pro-fphi’
]
Si fuésemos a importar Selphi, el Podfile se quedaría tal que así:

source 'https://cdn.cocoapods.org/'
source '...'

target 'Example' do
  pod 'IQKeyboardManagerSwift'
  pod 'SwiftLint'
  pod 'FPHISDKTrackingComponent', '~> 1.4.0'
  pod 'FPHISDKNFCComponent', '~> 2.5.1'
  pod 'FPHISDKMainComponent', '~> 1.4.0'
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

Una operación es el flujo completo desde que un usuario inicia un authentication u onboarding hasta que lo completa.

Hay 2 maneras de hacerlo; en función de si se conocen los pasos que formarán el flujo del proceso de registro o autenticación o no.

Flujo conocido (aparecerá la operación en la web con todos los pasos de la lista):

```
    SDKController.shared.newOperation(operationType: OperationType.X, customerId: "customerId", steps: [.SELPHI, .SELPHID, .OTHER("CUSTOMSTEP")], output: { _ in })
```

Flujo desconocido (aparecerá la operación en la web con puntos suspensivos) :

```
    SDKController.shared.newOperation(operationType: OperationType.X, customerId: "customerId", output: { _ in})
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

#### 2.2.4 Lectura NFC

La captura facial se realiza a través de Selphi. 
```
    public func launchNfc(setTracking: Bool, nfcConfigurationData: NfcConfigurationData, output: @escaping (SdkResult<NfcResult>) -> Void) {
        log("LAUNCH NFC")
        
        let controller = NfcController(data: nfcConfigurationData, output: output, stateDelegate: nil)
        if setTracking {
            SDKController.shared.launch(controller: controller)
        } else {
            SDKController.shared.launchMethod(controller: controller)
        }
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
static let customerId = "sdk-full-ios"
```

