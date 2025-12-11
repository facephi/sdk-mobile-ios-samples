//
//  ConfigsComponentsVC.swift
//  demosdk
//
//  Created by Daniel Eloy García-Gómez on 12/2/25.
//

import UIKit
import core
import Foundation
import selphiComponent
import selphidComponent
import captureComponent

enum ConfigComponent {
    case SELPHI_COMPONENT
    case SELPHID_COMPONENT
    case FILE_UPLOADER_COMPONENT
    case FINISH_TRACKING
}

enum ConfigValue {
    case int(value: Int)
    case float(value: Float)
    case double(value: Double)
    case bool(value: Bool)
    case string(value: String)
    case enumValue(value: String, options: [String])
    case enumValueCombo(value: String, options: [String])
    case enumValueInt(value: Int, options: [Int])
}

struct Configuration {
    var configType: ConfigComponent
    var values: [String: ConfigValue]
}

class ConfigsComponentsVC: UIViewController {
    var component: ConfigComponent!
    var configuration: Configuration!
    var action: ((Any) -> Void)?

    public let stackView = UIStackView()
    private let scrollView = UIScrollView()
    private let executeButton = UIButton(type: .system)
    private let backButton = UIButton(type: .system)

    private var pickerList: [String] = []
    private var pickerDataSources: [String: PickerDataSource] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        setupUI()
        configureView()
    }
    
    @objc func donePressed() {
        if let textField = findFirstResponder(in: self.view) as? UITextField {
            textField.resignFirstResponder() // Oculta el picker
        }
    }

    func findFirstResponder(in view: UIView) -> UIView? {
        if view.isFirstResponder { return view }
        for subview in view.subviews {
            if let firstResponder = findFirstResponder(in: subview) { return firstResponder }
        }
        return nil
    }
    
    private func setupUI() {
        view.backgroundColor = .white

        // Configurar ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        // Configurar StackView dentro del ScrollView
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])

        // Configurar Botones
        executeButton.setTitle("COMENZAR", for: .normal)
        executeButton.addTarget(self, action: #selector(executeAction), for: .touchUpInside)

        backButton.setTitle("ATRÁS", for: .normal)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)

        stackView.addArrangedSubview(executeButton)
        stackView.addArrangedSubview(backButton)
    }

    private func configureView() {
        let configActions: [ConfigComponent: (ConfigsComponentsVC) -> Void] = [
            .SELPHI_COMPONENT: { SdkConfigurationManager.configureSelphiFields(in: $0, with: nil) },
            .SELPHID_COMPONENT: { SdkConfigurationManager.configureSelphidFields(in: $0, with: nil) },
            .FILE_UPLOADER_COMPONENT: { SdkConfigurationManager.configureFileUploaderFields(in: $0, with: nil) },
            .FINISH_TRACKING: { SdkConfigurationManager.configureFinishTrackingFields(in: $0, with: nil) },
        ]
        configActions[component]?(self)
    }

    public func createField(key: String, value: ConfigValue) -> UIView {
        let label = UILabel()
        label.text = key
        
        let inputView: UIView

        switch value {
        case .int(let val):
            inputView = createTextField(value: "\(val)", key: key, keyboardType: .numberPad)
        case .float(let val):
            inputView = createTextField(value: "\(val)", key: key, keyboardType: .decimalPad)
        case .string(let val):
            inputView = createTextField(value: val, key: key, keyboardType: .default)
        case .bool(let val):
            inputView = createSwitch(isOn: val, key: key)
        case .enumValue(let val, let options):
            inputView = createPicker(value: val, options: options, key: key)
        case .enumValueCombo(let val, let options):
            inputView = createPickerCombo(value: val, options: options, key: key)
        case .enumValueInt(let val, let options):
            inputView = createPicker(value: "\(val)", options: options.map { "\($0)" }, key: key)
        case .double(value: let val):
            inputView = createTextField(value: "\(val)", key: key, keyboardType: .decimalPad)
        }

        let stack = UIStackView(arrangedSubviews: [label, inputView])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }

    private func createTextField(value: String, key: String, keyboardType: UIKeyboardType?, addTarget: Bool = true) -> UITextField {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        if let keyboardType {
            textField.keyboardType = keyboardType
        }
        textField.text = value
        textField.accessibilityIdentifier = key
        if addTarget {
            textField.addTarget(self, action: #selector(updateField(_:)), for: .allEditingEvents)
        }
        return textField
    }

    private func createPicker(value: String, options: [String], key: String) -> UISegmentedControl {
        let segmentedControl = UISegmentedControl(items: options)
        segmentedControl.selectedSegmentIndex = options.firstIndex(of: value) ?? 0
        segmentedControl.accessibilityIdentifier = key
        segmentedControl.addTarget(self, action: #selector(updateField(_:)), for: .valueChanged)
        return segmentedControl
    }
    
    private func createPickerCombo(value: String, options: [String], key: String) -> UITextField {
        let pickerView = UIPickerView()
        let pickerSelector = createTextField(value: value, key: key, keyboardType: nil, addTarget: false)
        let pickerDataManager = PickerDataSource(selectedElement: value, options: options, pickerSelector: pickerSelector)
        self.pickerDataSources[key] = pickerDataManager
        
        pickerView.dataSource = pickerDataManager
        pickerView.delegate = pickerDataManager
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        
        pickerSelector.inputView = pickerView
        pickerSelector.translatesAutoresizingMaskIntoConstraints = false
        pickerSelector.addTarget(self, action: #selector(updateCombo(_:)), for: .allEditingEvents)

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
        pickerSelector.inputAccessoryView = container
        
        return pickerSelector
    }

    public func createSwitch(isOn: Bool, key: String) -> UISwitch {
        let switchControl = UISwitch()
        switchControl.isOn = isOn
        switchControl.accessibilityIdentifier = key
        switchControl.addTarget(self, action: #selector(updateField(_:)), for: .valueChanged)
        return switchControl
    }

    @objc private func updateCombo(_ sender: Any) {
        if let key = (sender as? UIView)?.accessibilityIdentifier,
           let comboTf = sender as? UITextField {
            configuration.values[key] = .enumValueCombo(value: comboTf.text ?? "", options: [])
        }
    }
        
    @objc private func updateField(_ sender: Any) {
        guard let key = (sender as? UIView)?.accessibilityIdentifier else { return }

        switch sender {
        case let textField as UITextField:
            if let intValue = Int(textField.text ?? "") {
                configuration.values[key] = .int(value: intValue)
            } else if let floatValue = Float(textField.text ?? "") {
                configuration.values[key] = .float(value: floatValue)
            } else {
                configuration.values[key] = .string(value: textField.text ?? "")
            }
            
        case let switchControl as UISwitch:
            configuration.values[key] = .bool(value: switchControl.isOn)
            
        case let segmentedControl as UISegmentedControl:
            if let configValue = configuration.values[key], case let ConfigValue.enumValue(_, options) = configValue {
                let selectedValue = options[segmentedControl.selectedSegmentIndex]
                configuration.values[key] = .enumValue(value: selectedValue, options: options)
            }
            
        default:
            break
        }
    }
    
    @objc private func executeAction() {
        if let component = component {
            switch component {
            case .SELPHI_COMPONENT:
                let selphiConfig = SdkConfigurationManager.createSelphiConfigurationData(from: configuration)
                action?(selphiConfig)
            case .SELPHID_COMPONENT:
                let selphidConfig = SdkConfigurationManager.createSelphidConfigurationData(from: configuration)
                action?(selphidConfig)
            case .FILE_UPLOADER_COMPONENT:
                let captureConfig = SdkConfigurationManager.createFileUploaderConfigurationData(from: configuration)
                action?(captureConfig)
            case .FINISH_TRACKING:
                let captureConfig = SdkConfigurationManager.createFinishTrackingData(from: configuration)
                action?(captureConfig)
            }
        }
        self.dismiss(animated: true)
    }

    @objc private func goBack() {
        dismiss(animated: true)
    }
}


class PickerDataSource: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    private var selectedElement: String
    private var options: [String]
    private var pickerSelector: UITextField

    init(selectedElement: String, options: [String], pickerSelector: UITextField) {
        self.selectedElement = selectedElement
        self.options = options
        self.pickerSelector = pickerSelector
        super.init()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // solo una columna
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[safe: row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let element = options[safe: row] else { return }
        pickerSelector.text = element
        selectedElement = element
    }
}
