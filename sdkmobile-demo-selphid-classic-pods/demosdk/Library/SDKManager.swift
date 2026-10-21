//
//  SDKManager.swift
//  demosdk
//

import core
import Foundation
import sdk
import selphidClassicComponent
import trackingComponent
import UIKit
import tokenizeComponent
import statusComponent

protocol SDKManagerDelegate: AnyObject {
    func log(msg: String)
}

class SDKManager {
    public static var shared: SDKManager = SDKManager()
    private let TAG = "APP_MANAGER"
    public var mainVC: MainVMOutput!

    init() {
        let trackingController = TrackingController(trackingError: { trackingError in
            self.log("TRACKING ERROR: \(trackingError)")
        })

        let statusController = StatusController()
        ThemeStatusManager.setup(theme: CustomThemeStatus())
        let tokenizeController = TokenizeController()

        if SdkConfigurationManager.onlineLicensing {
            SDKController.shared.initSdk(
                licensingUrl: SdkConfigurationManager.LICENSING_URL,
                apiKey: SdkConfigurationManager.APIKEY_LICENSING,
                locale: "es",
                sessionVisualOptions: nil,
                output: { sdkResult in
                    if sdkResult.finishStatus == .STATUS_OK {
                        self.log("Licencia automática seteada correctamente")
                    } else {
                        self.log("Ha ocurrido un error al intentar obtener la licencia: \(sdkResult.errorType)")
                    }
                },
                trackingController: trackingController,
                tokenizeController: tokenizeController,
                behaviorController: nil,
                statusController: statusController
            )
        } else {
            SDKController.shared.initSdk(
                license: SdkConfigurationManager.license,
                locale: "es",
                sessionVisualOptions: nil,
                output: { sdkResult in
                    if sdkResult.finishStatus == .STATUS_OK {
                        self.log("Licencia manual seteada correctamente")
                    } else {
                        self.log("La licencia manual no es correcta")
                    }
                },
                trackingController: trackingController,
                tokenizeController: tokenizeController,
                behaviorController: nil,
                statusController: statusController
            )
        }
    }

    public func launchSelphId(
        setTracking: Bool,
        viewController: UIViewController,
        selphIDConfigurationData: SelphIDConfigurationData,
        output: @escaping (SdkResult<SelphIDResult>) -> Void
    ) {
        log("LAUNCH SELPHID CLASSIC")

        let controller = SelphIDController(
            data: selphIDConfigurationData,
            output: output,
            viewController: viewController
        )
        if setTracking {
            SDKController.shared.launch(controller: controller)
        } else {
            SDKController.shared.launchMethod(controller: controller)
        }
    }

    public func newOperation(operationType: OperationType, customerId: String, output: @escaping (SdkResult<String>) -> Void) {
        SDKController.shared.newOperation(operationType: operationType, customerId: customerId, output: output)
    }

    public func closeSession() {
        SDKController.shared.closeSession()
    }

    private func log(_ msg: String) {
        print("\(TAG): \(msg)")
        mainVC?.show(msg: msg)
    }
}
