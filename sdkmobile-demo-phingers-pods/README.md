# SDK-Mobile Cocoapods Demo Full Version

Aplicación demo para testear internamente todos los componentes de la SDK Mobile implementados hasta la fecha (Full Version), descargando los componentes desde nuestro repositorios privados (Artifactory). 

## Status:

 - FPHISDKCoreComponent (1.0.22) (Pod privado) - Version iOS (10)
 - FPHISDKMainComponent (1.0.15) (Pod privado) - Version iOS (10)
 - FPHISDKTrackingComponent (1.0.15) (Pod privado) - Version iOS (10)
 - FPHISelphIDComponent (1.15.1) (Pod público) - Version iOS (10)
 - FPHISDKSelphiComponent (1.0.7) (Pod privado) - Version iOS (13) 
 - FPHISDKNFCComponent - NOT WORKING (OpenSSL issue) - Version iOS (13)
 - FPHISDKQRComponent (1.0.0) (Pod privado) - Version iOS (10)
 - FPHISDKVideoIDComponent (1.0.11) (Pod privado) - Version iOS (10)
 - FPHISDKVideoCallComponent (1.0.5) (Pod privado) - Version iOS (10)
 - FPHISDKLicensingComponent (1.0.9) (Pod privado) - Version iOS (10)
 - FPHIPhingersComponent (1.0.1) (Pod público) - Version iOS (10)

## Instalación:

- Si es la **primera vez** que se va a utilizar el repositorio privado instalar Cocoapods para Artifactory:

`sudo gem install cocoapods-art`

- Para acceder a los repos privados, se necesitará añadir el repositorio y las credenciales del usuario en la lista del fichero **netrc**:
 
`nano ~/.netrc`

Y una vez abiertos se copian los siguientes datos:
 
`machine facephicorp.jfrog.io`
`login <USERNAME>`
`password <TOKEN>`

- Y finalmente se deberá añadir el repositorio donde se encuentran todos los paquetes:

`pod repo-art add cocoa-dev-fphi "https://facephicorp.jfrog.io/artifactory/api/pods/cocoa-dev-fphi"`

- Tras esto, ya se podrían instalar e integrar los paquetes en la app, ejecutando el Podfile y el siguiente comando:

`pod install`

## Actualización de paquetes:

En caso de liberarse una versión nueva de alguno de los componentes de la SDK Mobile, se deberá actualizar el repositorio añadido previamente, para que se actualicen los cambios que se han realizado. Para ello, se deberá ejecutar el siguiente comando:

`pod repo-art update cocoa-dev-fphi`


## Posibles problemas


- Si cocoapods fue instalado mediante homebrew, puede dar problemas.

- A veces hacer el update no hace que el Pod install apunte a la última versión.

- Para hacer un CI la máquina tiene que tener instalado cocoapods art (Instalarlo en Jenkins o en un Runner de GitHub). (Solucionado) 

- Interactuar con cocoa-remote toma demasiado tiempo. (Solucionado)

- No se sabe qué pasará si hay dos pods con el mismo nombre, uno en el apartado privado y otro en público. (Buscará la última versión, por lo que tendremos que crear un pod público con una versión mínima para que no roben el nombre y den problemas en el futuro)

