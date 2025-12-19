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
import phingersTFComponent

protocol MainVMInput {
    func newOperation()
    func phingers(reticleOrientation: Int, filterFinger: FingerFilter)
    func getLicense()
    func closeSession()
}

protocol MainVMOutput {
    func show(msg: String)
    func showAlert(msg: String)
}

class MainVM {
    // MARK: - VARS
    private let baseUrl = "https://external-selphid-sdk.facephi.dev/"
    private let methodPassiveLivenesTracking = "api/v1/selphid/passive-liveness/evaluate"
    private let methodAuthenticateFacial = "api/v1/selphid/authenticate-facial/document/face-image"

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

    func phingers(reticleOrientation: Int, filterFinger: FingerFilter) {
        var reticle = configReticleOrientation(reticleOrientation: reticleOrientation)
        var phingersConfiguration = SdkConfigurationManager.phingersConfiguration
        phingersConfiguration.reticleOrientation = reticle
        phingersConfiguration.fingerFilter = filterFinger
        SDKManager.shared.launchPhingers(setTracking: true, viewController: viewController, phingersConfigurationData: phingersConfiguration, output: { phingersResult in
            guard phingersResult.finishStatus == .STATUS_OK else {
                self.log(msg: "Phingers ERROR: \(phingersResult.errorType)")
                return
            }
            self.log(msg: "Status OK")
        })
    }
    
    func configFilterFinger(filterFinger: Int) -> FingerFilter {
        var fingerFilter: FingerFilter = .ALL_4_FINGERS_ONE_BY_ONE
        
        switch (filterFinger) {
        case 1:
            fingerFilter = .INDEX_FINGER
        case 2:
            fingerFilter = .MIDDLE_FINGER
        case 3:
            fingerFilter = .RING_FINGER
        case 4:
            fingerFilter = .LITTLE_FINGER
        case 5:
            fingerFilter = .THUMB_FINGER
        case 6:
            fingerFilter = .SLAP
        case 7:
            fingerFilter = .ALL_4_FINGERS_ONE_BY_ONE
        case 8:
            fingerFilter = .ALL_5_FINGERS_ONE_BY_ONE
        default:
            fingerFilter = .ALL_4_FINGERS_ONE_BY_ONE
        }
        
        return fingerFilter
    }
    
    func configReticleOrientation(reticleOrientation: Int) -> CaptureOrientation {
            var reticle: CaptureOrientation = .LEFT

        switch (reticleOrientation) {
            case 1:
                reticle = .RIGHT
                break
            default:
                reticle = .LEFT
                break
            }
            return reticle
    }

    func setCustomerId() {
        SDKManager.shared.setCustomerId(customerId: "nuevoCustomerId")
    }

    // Never used
    func closeSession() {
        SDKManager.shared.closeSession()
    }
}
