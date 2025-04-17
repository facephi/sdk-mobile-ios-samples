//
//  MainVC.swift
//  demosdk
//
//  Created by Faustino Flores García on 26/4/22.
//

import UIKit
import phingersTFComponent

class MainVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: - ENUM
    private enum ButtonTag: Int {
        case newOperation = 1, phingers, license, clearLogs
    }

    // MARK: - OUTLET
    @IBOutlet var lbLog: UITextView!
    @IBOutlet var btConfiguration: UIButton!

    @IBOutlet weak var segReticleOrientation: UISegmentedControl!
    @IBOutlet weak var pckFilterFinger: UIPickerView!
    
    var selectedFingerFilter: FingerFilter?
    // MARK: - VARS
    private var viewModel: MainVMInput!

    // MARK: - OVERRIDE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPickerView()
        viewModel = MainVM(viewController: self, delegate: self)
    }

    // MARK: - FUNC

    private func clearText() {
        show(msg: "")
    }
    
    private func setupPickerView() {
        pckFilterFinger.delegate = self
        pckFilterFinger.dataSource = self
    }

    // MARK: - EVENTS
    // swiftlint:disable cyclomatic_complexity
    @IBAction func buttonClickListener(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        clearText()
        switch ButtonTag(rawValue: button.tag) {
        case .newOperation:
            viewModel.newOperation()
        case .phingers:
            viewModel.phingers(reticleOrientation: segReticleOrientation.selectedSegmentIndex, filterFinger: selectedFingerFilter ?? .ALL_4_FINGERS_ONE_BY_ONE)
        case .license:
            viewModel.getLicense()
        case .clearLogs:
            clearText()
        default:
            break
        }
    }
    

    func numberOfComponents(in pckFilterFinger: UIPickerView) -> Int {
            return 1 // Solo una columna de valores
        }

        func pickerView(_ pckFilterFinger: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return FingerFilter.allCases.count
        }

        // MARK: - UIPickerViewDelegate

        func pickerView(_ pckFilterFinger: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return getDisplayName(for: FingerFilter.allCases[row])
        }

        func pickerView(_ pckFilterFinger: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            selectedFingerFilter = FingerFilter.allCases[row]
        }

        // Método para obtener un nombre legible de la enumeración
        private func getDisplayName(for filter: FingerFilter) -> String {
            switch filter {
            case .INDEX_FINGER: return "Index Finger"
            case .MIDDLE_FINGER: return "Middle Finger"
            case .RING_FINGER: return "Ring Finger"
            case .LITTLE_FINGER: return "Little Finger"
            case .THUMB_FINGER: return "Thumb Finger"
            case .SLAP: return "Slap"
            case .ALL_4_FINGERS_ONE_BY_ONE: return "All 4 Fingers One by One"
            case .ALL_5_FINGERS_ONE_BY_ONE: return "All 5 Fingers One by One"
            }
        }
    
}

extension MainVC: MainVMOutput {
    func showAlert(msg: String) {
        let alertController = UIAlertController(title: "",
                                                message: msg,
                                                preferredStyle: .alert)

        let okAction = UIAlertAction(title: "ok", style: .default, handler: { _ in
            exit(0)
        })
        alertController.addAction(okAction)

        present(alertController, animated: true, completion: nil)
    }
    func show(msg: String) {
        DispatchQueue.main.async {
            self.lbLog.text = msg
        }
    }
}
