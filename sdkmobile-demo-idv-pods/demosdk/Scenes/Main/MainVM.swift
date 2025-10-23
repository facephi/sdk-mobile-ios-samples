//
//  MainVM.swift
//  demosdk
//
//  Created by Faustino Flores García on 6/5/22.
//

import UIKit
import sdk
import core
import selphiComponent
import selphidComponent

protocol MainVMInput {
    func launchIdvFlow(id: String)
    func nextStepFlow()
    func cancelFlow()
    func downloadFlows()
}

protocol SdkManagerDelegate {
    func setAvailableFlows(flows: [IntegrationFlowData])
    func show(msg: String)
    func showImage(image: Data?)
}

class MainVM {
    // MARK: - LETS
    private let viewController: UIViewController
    
    // MARK: - VARS
    private var delegate: SdkManagerDelegate
    
    init(viewController: UIViewController, delegate: SdkManagerDelegate) {
        self.delegate = delegate
        self.viewController = viewController
        
        // Initializes for the first time, so it launches the GetLicense functionality
        SDKManager.delegate = self.delegate
        let _ = SDKManager.shared
    }
}

// MARK: - MainVMInput
extension MainVM: MainVMInput {
    func launchIdvFlow(id: String) {
        SDKManager.shared.launchFlow(flowId: id, viewController: viewController) { sdkFlowResult in
            self.delegate.show(msg: "Flow Finish: \(sdkFlowResult.flowFinish)")
            self.delegate.show(msg: "Flow Step: \(sdkFlowResult.step)")
            
            switch (sdkFlowResult.result.data) {
            case (let data as SelphIDResult):
                self.parseSelphIDResult(data: data)
            case (let data as SelphiResult):
                self.parseSelphiResult(selphiResult: data)
            default: break
            }
        }
    }
    
    func nextStepFlow() {
        SDKManager.shared.flowNextStep()
    }
    
    func cancelFlow() {
        SDKManager.shared.cancelFlow()
    }
    
    func downloadFlows() {
        SDKManager.shared.initializeSDK()
    }
    
    private func parseSelphiResult(selphiResult: SelphiResult){
        guard let imageData = selphiResult.bestImageData else {
            self.delegate.show(msg: "Selphi bestImage is nil")
            return
        }

        self.delegate.showImage(image: imageData)
    }

    func parseSelphIDResult(data: SelphIDResult) {
        if let dictionary = data.ocrResults {
            let ocr = Dictionary(uniqueKeysWithValues: dictionary.flatMap { (key, value) -> (String, String)? in
                return (key, value)
            })
            self.delegate.show(msg: "SelphID OCR: \(ocr)")
        } else {
            self.delegate.show(msg: "El OCR es nulo")
        }
        
        self.delegate.showImage(image: data.faceImageData!)
    }
}
