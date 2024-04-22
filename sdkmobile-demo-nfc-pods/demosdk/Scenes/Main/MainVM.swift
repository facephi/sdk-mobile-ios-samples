//
//  MainVM.swift
//  demosdk
//
//  Created by Faustino Flores García on 6/5/22.
//

import UIKit
import sdk
import nfcComponent

protocol MainVMInput {
    func getLicense()
    func newOperation()
    func nfc(tfSupportNumber: String, tfBirthDate: String, tfExpirationDate: String, tfIssuer: String)
    func closeSession()
}

protocol MainVMOutput {
    func show(msg: String)

}

class MainVM {
    // MARK: - LETS
    private let viewController: UIViewController
    
    // MARK: - VARS
    private var tokenFaceImage = " "
    private var extradataToken = " "
    private var bestImage = " "
    private var bestImageData: Data = Data()
    private var ocr: [String: String] = [:]
    private var delegate: MainVMOutput?
    
    init(viewController: UIViewController, delegate: MainVMOutput) {
        self.delegate = delegate
        self.viewController = viewController
        
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
            self.log(msg: sdkResult.data ?? "ERROR: NewOperation's data output is nil")
        })
    }

    func nfc(tfSupportNumber: String, tfBirthDate: String, tfExpirationDate: String, tfIssuer: String) {
        var nfcConfig = NfcConfigurationData(documentNumber: tfSupportNumber, birthDate: tfBirthDate, expirationDate: tfExpirationDate, issuer: tfIssuer, documentType: .ID_CARD)
        SDKManager.shared.launchNfc(setTracking: true, nfcConfigurationData: nfcConfig, output: { nfcResult in
            guard nfcResult.errorType == .NO_ERROR else {
                self.log(msg: nfcResult.errorType.rawValue)
                return
            }
            
            guard let _ = nfcResult.data
                    else
            {
                self.log(msg: "NFC KO")
                return
            }
            self.log(msg: "NFC OK")
        })
    }
    
    func closeSession() {
        SDKManager.shared.closeSession()
    }
}
