//
//  MainVM.swift
//  demosdk
//
//  Created by Faustino Flores García on 6/5/22.
//

import UIKit
import sdk
import nfcComponent
import termsConditionsComponent

protocol MainVMInput {
    func getLicense()
    func newOperation()
    func nfc(tfSupportNumber: String, tfBirthDate: String, tfExpirationDate: String, tfIssuer: String)
    func launchTermsConditions()
    func closeSession()
}

protocol MainVMOutput {
    func show(msg: String)

}

class MainVM {
    // MARK: - LETS
    private let viewController: UIViewController
    
    // MARK: - VARS
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
                self.log(msg: "NFC ERROR: \(nfcResult.errorType)")
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

    func launchTermsConditions() {
        let configuration = TermsConditionsConfigurationData(
            termsConditions: "Please accept the terms and conditions to continue.",
            extractionTimeout: 30000,
            orientation: .followSystem
        )
        SDKManager.shared.launchTermsConditions(setTracking: true, viewController: viewController, termsConditionsConfigurationData: configuration, output: { termsConditionsResult in
            guard termsConditionsResult.errorType == .NO_ERROR else {
                self.log(msg: "\(termsConditionsResult.errorType)")
                return
            }

            guard termsConditionsResult.data != nil else {
                self.log(msg: "TermsConditions result is nil")
                return
            }

            self.log(msg: "TermsConditions accepted")
        })
    }
    
    func closeSession() {
        SDKManager.shared.closeSession()
    }
}
