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
import nfcComponent
import captureComponent
import phingersTFComponent
import voiceIDComponent
import videocallComponent
import videoidComponent

enum ConfigComponent {
    case SELPHI_COMPONENT
    case SELPHID_COMPONENT
    case NFC_COMPONENT
    case QR_COMPONENT
    case PHINGER_COMPONENT
    case VIDEOCALL_COMPONENT
    case VOICE_COMPONENT
    case VIDEOID_COMPONENT
    case DOCUMENT_CAPTURE_COMPONENT
    case FINISH_TRACKING
    case START_VIDEO_RECORDING_COMPONENT
    case TERMS_CONDITIONS_COMPONENT
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
    private var enumOptionButtonsByKey: [String: [UIButton]] = [:]
    private var enumStringOptionsByKey: [String: [String]] = [:]
    private var enumIntOptionsByKey: [String: [Int]] = [:]
    private weak var activeInputView: UIView?

    /// Called after any configuration control updates `configuration.values`.
    var onConfigurationValueChanged: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        setupUI()
        setupKeyboardObservers()
        configureView()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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
            .NFC_COMPONENT: { SdkConfigurationManager.configureNfcFields(in: $0, with: nil) },
            .QR_COMPONENT: { SdkConfigurationManager.configureQRFields(in: $0, with: nil) },
            .VIDEOCALL_COMPONENT: { SdkConfigurationManager.configureVideoCallFields(in: $0, with: nil) },
            .VIDEOID_COMPONENT: { SdkConfigurationManager.configureVideoIDFields(in: $0, with: nil) },
            .DOCUMENT_CAPTURE_COMPONENT: { SdkConfigurationManager.configureDocumentCaptureFields(in: $0, with: nil) },
            .VOICE_COMPONENT: { SdkConfigurationManager.configureVoiceIDFields(in: $0, with: nil) },
            .PHINGER_COMPONENT: { SdkConfigurationManager.configurePhingersFields(in: $0, with: nil) },
            .FINISH_TRACKING: { SdkConfigurationManager.configureFinishTrackingFields(in: $0, with: nil) },
            .START_VIDEO_RECORDING_COMPONENT: { SdkConfigurationManager.configureVideoRecordingDataFields(in: $0, with: nil) },
            .TERMS_CONDITIONS_COMPONENT: { SdkConfigurationManager.configureTermsConditionsFields(in: $0, with: nil) },
        ]
        configActions[component]?(self)
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
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
            inputView = createEnumList(value: val, options: options, key: key)
        case .enumValueInt(let val, let options):
            inputView = createEnumIntList(value: val, options: options, key: key)
        case .double(value: let val):
            inputView = createTextField(value: "\(val)", key: key, keyboardType: .decimalPad)
        case .enumValueCombo(let val, let options):
            inputView = createPickerCombo(value: val, options: options, key: key)
        }

        let stack = UIStackView(arrangedSubviews: [label, inputView])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }

    private func createTextField(value: String, key: String, keyboardType: UIKeyboardType) -> UITextField {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.keyboardType = keyboardType
        textField.text = value
        textField.accessibilityIdentifier = key
        textField.addTarget(self, action: #selector(inputDidBeginEditing(_:)), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(updateField(_:)), for: .editingChanged)
        return textField
    }

    private func createEnumList(value: String, options: [String], key: String) -> UIStackView {
        enumStringOptionsByKey[key] = options

        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 8

        var buttons: [UIButton] = []
        for (index, option) in options.enumerated() {
            let button = UIButton(type: .system)
            button.tag = index
            button.accessibilityIdentifier = key
            button.setTitle(option, for: .normal)
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.lineBreakMode = .byWordWrapping
            button.contentHorizontalAlignment = .left
            button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
            button.layer.cornerRadius = 8
            button.layer.borderWidth = 1
            button.addTarget(self, action: #selector(updateEnumListSelection(_:)), for: .touchUpInside)

            applyEnumButtonStyle(button, selected: option == value)
            container.addArrangedSubview(button)
            buttons.append(button)
        }

        enumOptionButtonsByKey[key] = buttons
        return container
    }

    private func createEnumIntList(value: Int, options: [Int], key: String) -> UIStackView {
        enumIntOptionsByKey[key] = options

        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 8

        var buttons: [UIButton] = []
        for (index, option) in options.enumerated() {
            let button = UIButton(type: .system)
            button.tag = index
            button.accessibilityIdentifier = key
            button.setTitle("\(option)", for: .normal)
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.lineBreakMode = .byWordWrapping
            button.contentHorizontalAlignment = .left
            button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
            button.layer.cornerRadius = 8
            button.layer.borderWidth = 1
            button.addTarget(self, action: #selector(updateEnumListSelection(_:)), for: .touchUpInside)

            applyEnumButtonStyle(button, selected: option == value)
            container.addArrangedSubview(button)
            buttons.append(button)
        }

        enumOptionButtonsByKey[key] = buttons
        return container
    }

    private func applyEnumButtonStyle(_ button: UIButton, selected: Bool) {
        if selected {
            button.layer.borderColor = UIColor.systemBlue.cgColor
            button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)
        } else {
            button.layer.borderColor = UIColor.systemGray4.cgColor
            button.backgroundColor = .clear
        }
    }

    public func createSwitch(isOn: Bool, key: String) -> UISwitch {
        let switchControl = UISwitch()
        switchControl.isOn = isOn
        switchControl.accessibilityIdentifier = key
        switchControl.addTarget(self, action: #selector(updateField(_:)), for: .valueChanged)
        return switchControl
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
            
        default:
            break
        }

        onConfigurationValueChanged?(key)
    }

    @objc private func updateEnumListSelection(_ sender: UIButton) {
        guard let key = sender.accessibilityIdentifier else { return }

        if let options = enumStringOptionsByKey[key], sender.tag >= 0, sender.tag < options.count {
            let selectedValue = options[sender.tag]
            configuration.values[key] = .enumValue(value: selectedValue, options: options)
        } else if let options = enumIntOptionsByKey[key], sender.tag >= 0, sender.tag < options.count {
            let selectedValue = options[sender.tag]
            configuration.values[key] = .enumValueInt(value: selectedValue, options: options)
        } else {
            return
        }

        guard let buttons = enumOptionButtonsByKey[key] else { return }
        for button in buttons {
            applyEnumButtonStyle(button, selected: button == sender)
        }

        onConfigurationValueChanged?(key)
    }

    func setEnumFieldEnabled(key: String, enabled: Bool) {
        guard let buttons = enumOptionButtonsByKey[key] else { return }
        for button in buttons {
            button.isEnabled = enabled
            button.alpha = enabled ? 1 : 0.45
        }
    }

    func insertConfigurationBlock(at index: Int, views: [UIView]) {
        for (offset, view) in views.enumerated() {
            stackView.insertArrangedSubview(view, at: index + offset)
        }
    }

    private func createTextField(value: String, key: String, keyboardType: UIKeyboardType?, addTarget: Bool = true) -> UITextField {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        if let keyboardType {
            textField.keyboardType = keyboardType
        }
        textField.text = value
        textField.accessibilityIdentifier = key
        textField.addTarget(self, action: #selector(inputDidBeginEditing(_:)), for: .editingDidBegin)
        if addTarget {
            textField.addTarget(self, action: #selector(updateField(_:)), for: .allEditingEvents)
        }
        return textField
    }

    @objc private func inputDidBeginEditing(_ sender: UIView) {
        activeInputView = sender
    }

    @objc private func handleKeyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let keyboardInView = view.convert(keyboardFrame, from: nil)
        let bottomInset = max(0, keyboardInView.height - view.safeAreaInsets.bottom)

        scrollView.contentInset.bottom = bottomInset + 12
        scrollView.verticalScrollIndicatorInsets.bottom = bottomInset + 12

        if let activeInputView {
            let visibleRect = activeInputView.convert(activeInputView.bounds, to: scrollView)
            scrollView.scrollRectToVisible(visibleRect.insetBy(dx: 0, dy: -16), animated: true)
        }
    }

    @objc private func handleKeyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
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
    
    @objc private func updateCombo(_ sender: Any) {
        if let key = (sender as? UIView)?.accessibilityIdentifier,
           let comboTf = sender as? UITextField {
            configuration.values[key] = .enumValueCombo(value: comboTf.text ?? "", options: [])
        }
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
    
    @objc private func executeAction() {
        guard let component else { return }

        let config: Any?
        switch component {
        case .SELPHI_COMPONENT:
            config = SdkConfigurationManager.createSelphiConfigurationData(from: configuration)
        case .SELPHID_COMPONENT:
            config = SdkConfigurationManager.createSelphidConfigurationData(from: configuration)
        case .NFC_COMPONENT:
            config = SdkConfigurationManager.createNfcConfigurationData(from: configuration)
        case .PHINGER_COMPONENT:
            config = SdkConfigurationManager.createPhingersConfigurationData(from: configuration)
        case .VOICE_COMPONENT:
            config = SdkConfigurationManager.createVoiceIDConfigurationData(from: configuration)
        case .VIDEOCALL_COMPONENT:
            config = SdkConfigurationManager.createVideoCallConfigurationData(from: configuration)
        case .VIDEOID_COMPONENT:
            config = SdkConfigurationManager.createVideoIDConfigurationData(from: configuration)
        case .QR_COMPONENT:
            config = SdkConfigurationManager.createQrCaptureConfigurationData(from: configuration)
        case .DOCUMENT_CAPTURE_COMPONENT:
            config = SdkConfigurationManager.createFileUploaderConfigurationData(from: configuration)
        case .FINISH_TRACKING:
            config = SdkConfigurationManager.createFinishTrackingData(from: configuration)
        case .START_VIDEO_RECORDING_COMPONENT:
            config = SdkConfigurationManager.createVideoRecordingConfigurationData(from: configuration)
        case .TERMS_CONDITIONS_COMPONENT:
            config = SdkConfigurationManager.createTermsConditionsConfigurationData(from: configuration)
        }

        let launchAction = action
        dismiss(animated: true) {
            guard let config else { return }
            launchAction?(config)
        }
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
