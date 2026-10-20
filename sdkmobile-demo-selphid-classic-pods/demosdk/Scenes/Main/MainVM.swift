//
//  MainVM.swift
//  demosdk
//

import core
import Foundation
import UIKit

protocol MainVMInput {
    func newOperation()
    func selphID()
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

    func log(msg: String) {
        delegate?.show(msg: msg)
    }
}

extension MainVM: MainVMInput {

    func getLicense() {
        _ = SDKManager.shared
    }

    func newOperation() {
        SDKManager.shared.newOperation(operationType: .ONBOARDING, customerId: SdkConfigurationManager.CUSTOMER_ID, output: { sdkResult in
            self.log(msg: sdkResult.data != nil ? "New Operation with ID: \(sdkResult.data!)": "ERROR: NewOperation's data output is nil")
        })
    }

    func selphID() {
        SDKManager.shared.launchSelphId(
            setTracking: true,
            viewController: viewController,
            selphIDConfigurationData: SdkConfigurationManager.selphIDConfiguration,
            output: { selphIDResult in
                guard selphIDResult.errorType == .NO_ERROR else {
                    self.log(msg: "SelphID ERROR: \(selphIDResult.errorType)")
                    return
                }
                if let dictionary = selphIDResult.data?.ocrResults {
                    let ocr = Dictionary(uniqueKeysWithValues: dictionary.compactMap { key, value -> (String, String)? in
                        (key, value)
                    })
                    self.log(msg: "OCR Data:\n\(ocr)")
                } else {
                    self.log(msg: "Capture OK (no OCR in result)")
                }
            }
        )
    }

    func closeSession() {
        SDKManager.shared.closeSession()
    }
}
