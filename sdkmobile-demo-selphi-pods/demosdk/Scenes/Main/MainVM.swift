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

protocol MainVMInput {
    func newOperation()
    func selphi()
    func getLicense()
    func closeSession()
}

protocol MainVMOutput {
    func show(msg: String)
    func showAlert(msg: String)
}

class MainVM {

    private var extradataToken = " "
    private var bestImage = " "
    private var bestImageData: Data = Data()
    private var ocr: [String: String] = [:]

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

    func selphi() {
        SDKManager.shared.launchSelphi(setTracking: true, viewController: viewController, selphiConfigurationData: SdkConfigurationManager.selphiConfiguration, output: { selphiResult in
            guard selphiResult.errorType == .NO_ERROR else {
                self.log(msg: selphiResult.errorType.toString())
                return
            }
            guard let imageData = selphiResult.data?.bestImageData
                    else
            {
                self.log(msg: "Selphi bestImage is nil")
                return
            }
            
            self.bestImage = imageData.base64EncodedString()
            self.log(msg: "Selphi Image correctly fetched")
        })
    }
    
    // Never used
    func setCustomerId() {
        SDKManager.shared.setCustomerId(customerId: "nuevoCustomerId")
    }
    
    func closeSession() {
        SDKManager.shared.closeSession()
    }
}
