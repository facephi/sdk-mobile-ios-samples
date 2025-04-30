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
    func launchFlow()
}

protocol MainVMOutput {
    func show(msg: String)
}

class MainVM {
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
    
    func getLicense() {
        // Initializes for the first time, so it launches the GetLicense functionality
        let _ = SDKManager.shared
    }
}

// MARK: - MainVMInput
extension MainVM: MainVMInput {
    func launchFlow() {
        SDKManager.shared.launchFlow(customerId: SdkConfigurationManager.CUSTOMER_ID, viewController: viewController, selphidOutput: { selphIDResult in
            guard selphIDResult.errorType == .NO_ERROR else {
                self.log(msg: selphIDResult.errorType.toString())
                return
            }
            
            if let dictionary = selphIDResult.data?.ocrResults {
                self.ocr = Dictionary(uniqueKeysWithValues: dictionary.compactMap { (key, value) -> (String, String)? in
                    return (key, value)
                })
                self.log(msg: self.ocr.debugDescription)
            } else {
                self.log(msg: "OCR is NIL")
            }
            self.bestImageData = selphIDResult.data?.faceImageData ?? Data()
        }, selphiOutput: { selphiResult in
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
}
