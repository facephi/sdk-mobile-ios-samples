# SDK-Mobile Onboarding with FileUploader Version

Aplicación demo con integración del SDK, descargando los componentes desde nuestro repositorios privados (Artifactory). 

## Módulos:

- FPHISDKCaptureComponent
- FPHISDKMainComponent
- FPHISDKSelphiComponent
- FPHISDKSelphIDComponent
- FPHISDKStatusComponent
- FPHISDKTokenizeComponent
- FPHISDKTrackingComponent
- FPHISDKVideoRecordingComponent

## Instalación con SPM:

- Abrir demosdk.**xcodeproj**
- Configurar en XCode una cuenta de GitHub que disponga de acceso al repositorio privado de Facephi-Clienters.
- Si se ha utilizado previamente Cocoapods en el proyecto, para limpiar todo rastro previo debemos usar el comando `pod deintegrate`
- En el proyecto demosdk -> TARGETS -> demosdk -> General -> Frameworks, Libraries, and Embedded Content debemos asegurarnos de que están referenciados todos los paquetes del listado de #Módulos.

### SPM - Recursos de CaptureComponent
- Los recursos gráficos del componente de Captura se copian durante la fase Build gracias a un Run Script en la sección de Build Phases:

set -euo pipefail
BUNDLE_PATH="${TARGET_BUILD_DIR}/FPHICaptureWidget-SPM_FPHICaptureWidget-SPM.bundle/compose-resources"
DESTINATION="${TARGET_BUILD_DIR}/${TARGET_NAME}.app/compose-resources"
if [ -d "$BUNDLE_PATH" ]; then
  rm -rf "$DESTINATION"
  mkdir -p "$DESTINATION"
  cp -R "$BUNDLE_PATH/" "$DESTINATION/"
  echo "Copied FPHICaptureWidget Compose resources to ${DESTINATION}"
else
  echo "FPHICaptureWidget Compose resources not found at ${BUNDLE_PATH}. If your app is not using FPHICaptureWidget Component anymore, delete the script from your Build Phases -> Run Script section"
fi


BUNDLE_PATH_DS="${TARGET_BUILD_DIR}/FPHIDesignSystemResources_FPHIDesignSystemResources.bundle/"
DESTINATION="${TARGET_BUILD_DIR}/${TARGET_NAME}.app/compose-resources/composeResources"
if [ -d "$BUNDLE_PATH_DS" ]; then
  cp -R "$BUNDLE_PATH_DS/" "$DESTINATION/"
  echo "Copied FPHIDesignSystemResources Compose resources to ${DESTINATION}"
else
  echo "FPHIDesignSystemResources Compose resources not found at ${BUNDLE_PATH_DS}. If your app is not using FacePhi Components anymore, delete the script from your Build Phases -> Run Script section"
fi


## Instalación con Cocoapods:

- Si es la **primera vez** que se va a utilizar el repositorio privado instalar Cocoapods para Artifactory:

`sudo gem install cocoapods-art`

- Para acceder a los repos privados, se necesitará añadir el repositorio y las credenciales del usuario en la lista del fichero **netrc**:
 
`nano ~/.netrc`

Y una vez abiertos se copian los siguientes datos:
 
`machine facephicorp.jfrog.io`
`login <USERNAME>`
`password <TOKEN>`

- Y finalmente se deberá añadir el repositorio donde se encuentran todos los paquetes:

`pod repo-art add cocoa-pro-fphi "https://facephicorp.jfrog.io/artifactory/api/pods/cocoa-pro-fphi"`

- Tras esto, ya se podrían instalar e integrar los paquetes en la app, ejecutando el Podfile y el siguiente comando:

`pod install`

- Si se ha utilizado previamente SPM en el proyecto, para limpiar todo rastro previo podemos quitar las referencias SPM desde _demosdk -> Package Dependencies_
- Para esta demo, se puede simplemente eliminar las referencias del TARGET demosdk a los paquetes SPM en lugar de hacer lo anterior.

## Actualización de paquetes con Cocoapods:

En caso de liberarse una versión nueva de alguno de los componentes de la SDK Mobile, se deberá actualizar el repositorio añadido previamente, para que se actualicen los cambios que se han realizado. Para ello, se deberá ejecutar el siguiente comando:

`pod repo-art update cocoa-pro-fphi`


## Posibles problemas en Cocoapods

- Si cocoapods fue instalado mediante homebrew, puede dar problemas.
