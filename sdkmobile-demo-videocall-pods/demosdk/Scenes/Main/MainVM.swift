//
//  MainVM.swift
//  demosdk
//
//  Created by Faustino Flores García on 6/5/22.
//

import core
import Foundation
import UIKit
import AVFoundation
//import phingersComponent

protocol MainVMInput {
    func newOperation()
    func videoCall()
    func getLicense()
    func closeSession()
}

protocol MainVMOutput {
    func show(msg: String)
    func showAlert(msg: String)
}

class MainVM {
    
    private var delegate: MainVMOutput?
    
    private let viewController: UIViewController

    init(viewController: UIViewController, delegate: MainVMOutput) {
        self.delegate = delegate
        self.viewController = viewController
        SDKManager.shared.mainVC = delegate
        getLicense()
    }

    // MARK: - FUNC
    func log(msg: String) {
        delegate?.show(msg: msg)
    }
}

// MARK: - MainVMInput
extension MainVM: MainVMInput {
    
    func getLicense() {
        // Initializes for the first time, so it launches the GetLicense functionality
        let _ = SDKManager.shared
    }
    
    func newOperation() {
        SDKManager.shared.newOperation(operationType: .ONBOARDING, customerId: SdkConfigurationManager.CUSTOMER_ID, output: { sdkResult in
            self.log(msg: sdkResult.data != nil ? "New Operation with ID: \(sdkResult.data)": "ERROR: NewOperation's data output is nil")
        })
    }
    
    func videoCall() {
        SDKManager.shared.launchVideoCall(data: SdkConfigurationManager.videoCallConfiguration, setTracking: true, viewController: viewController, output: { videocallResult in
            if videocallResult.finishStatus == .STATUS_OK {
                self.log(msg: "Status OK \(videocallResult.finishStatus)")
            } else {
                self.log(msg: "Status KO \(videocallResult.errorType)")
            }
        })
    }
    
    // Never used
    func setCustomerId() {
        SDKManager.shared.setCustomerId(customerId: "nuevoCustomerId")
    }
    
    // Never used
    func closeSession() {
        SDKManager.shared.closeSession()
    }
}
