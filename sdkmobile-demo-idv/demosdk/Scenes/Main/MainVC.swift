//
//  MainVC.swift
//  demosdk
//
//  Created by Faustino Flores García on 26/4/22.
//

import UIKit
import sdk

class MainVC: UIViewController {
    // MARK: - ENUM
    private enum ButtonTag: Int {
        case launchFlow = 1,
             nextStepFlow = 10,
             cancelFlow,
             downloadFlows,
             clearLogs
    }
    
    // MARK: - OUTLET
    @IBOutlet var lbLog: UITextView!
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var flowSelector: UITextField!
    
    let pickerView = UIPickerView()

    // MARK: - VARS
    private var viewModel: MainVMInput!
    private var logLinesCount = 5
    private var selectedFlow = "Click to Select"
    private var flowList: [IntegrationFlowData] = []
    
    // MARK: - OVERRIDE
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = MainVM(viewController: self, delegate: self)
        addPickerView()
    }
    
    // MARK: - EVENTS
    @IBAction func buttonClickListener(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        clearText()
        switch ButtonTag(rawValue: button.tag) {
        case .launchFlow:
            viewModel.launchIdvFlow(id: selectedFlow)
        case .nextStepFlow:
            viewModel.nextStepFlow()
        case .cancelFlow:
            viewModel.cancelFlow()
        case .downloadFlows:
            viewModel.downloadFlows()
        case .clearLogs:
            self.clearLogs()
        default:
            break
        }
    }
    
    private func addPickerView() {
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        
        flowSelector.inputView = pickerView
        flowSelector.translatesAutoresizingMaskIntoConstraints = false
        flowSelector.addBorder(color: .systemBlue)

        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false

        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        toolbar.setItems([flexible, doneButton], animated: false)

        // Force height constraint
        NSLayoutConstraint.activate([
            toolbar.heightAnchor.constraint(equalToConstant: 44)
        ])

        // Wrap the toolbar in a container view (important for inputAccessoryView)
        let container = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        container.addSubview(toolbar)

        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            toolbar.topAnchor.constraint(equalTo: container.topAnchor),
            toolbar.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        flowSelector.inputAccessoryView = container
    }
    
    @objc func donePressed() {
        flowSelector.resignFirstResponder() // Oculta el picker
    }
    
    // MARK: - FUNC
    private func clearText() {
        show(msg: "")
        showImage(image: nil)
    }
}

extension MainVC: SdkManagerDelegate {
    func setAvailableFlows(flows: [sdk.IntegrationFlowData]) {
        self.flowList = flows
    }
    
    func show(msg: String) {
        DispatchQueue.main.async {
            if self.logLinesCount == 0 {
                self.logLinesCount = 5
                self.lbLog.text = msg
            } else {
                self.lbLog.text.append("\n\(msg)")
            }
            self.logLinesCount -= 1
        }
    }
    func showImage(image: Data?) {
        DispatchQueue.main.async {
            if image != nil {
                let imageAux : UIImage = UIImage(data: image!)!
                self.imageOne.image = imageAux
            } else {
                self.imageOne.image = nil
            }
        }
    }
    
    func clearLogs() {
        DispatchQueue.main.async {
            self.lbLog.text = ""
            self.logLinesCount = 0
            self.imageOne.image = nil
        }
    }
}

extension MainVC: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // solo una columna
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return flowList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return flowList[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        flowSelector.text = flowList[row].name
        selectedFlow = flowList[row].id
        self.show(msg: "Selected: \(flowList[row].name) with id: \(flowList[row].id)")
    }
}
