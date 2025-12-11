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
    case QR_COMPONENT
    case PHINGER_COMPONENT
    case VIDEOCALL_COMPONENT
    case VOICE_COMPONENT
    case VIDEOID_COMPONENT
    case CAPTURE_COMPONENT
    case FILE_UPLOADER_COMPONENT
    case GALLERY_COMPONENT
}

enum ConfigValue {
    case int(value: Int)
    case float(value: Float)
    case double(value: Double)
    case bool(value: Bool)
    case string(value: String)
    case enumValue(value: String, options: [String])
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        setupUI()
        configureView()
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
            .QR_COMPONENT: { SdkConfigurationManager.configureQRFields(in: $0, with: nil) },
            .VIDEOCALL_COMPONENT: { SdkConfigurationManager.configureVideoCallFields(in: $0, with: nil) },
            .VIDEOID_COMPONENT: { SdkConfigurationManager.configureVideoIDFields(in: $0, with: nil) },
            .CAPTURE_COMPONENT: { SdkConfigurationManager.configureInvoiceCaptureFields(in: $0, with: nil) },
            .FILE_UPLOADER_COMPONENT: { SdkConfigurationManager.configureFileUploaderFields(in: $0, with: nil) },
            .VOICE_COMPONENT: { SdkConfigurationManager.configureVoiceIDFields(in: $0, with: nil) },
            .PHINGER_COMPONENT: { SdkConfigurationManager.configurePhingersFields(in: $0, with: nil) },
            .GALLERY_COMPONENT: { SdkConfigurationManager.configureGalleryFields(in: $0, with: nil)}
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

    private func createTextField(value: String, key: String, keyboardType: UIKeyboardType) -> UITextField {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.keyboardType = keyboardType
        textField.text = value
        textField.accessibilityIdentifier = key
        textField.addTarget(self, action: #selector(updateField(_:)), for: .editingChanged)
        return textField
    }

    private func createPicker(value: String, options: [String], key: String) -> UISegmentedControl {
        let segmentedControl = UISegmentedControl(items: options)
        segmentedControl.selectedSegmentIndex = options.firstIndex(of: value) ?? 0
        segmentedControl.accessibilityIdentifier = key
        segmentedControl.addTarget(self, action: #selector(updateField(_:)), for: .valueChanged)
        return segmentedControl
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
            case .PHINGER_COMPONENT:
                let phingerConfig = SdkConfigurationManager.createPhingersConfigurationData(from: configuration)
                action?(phingerConfig)
            case .VOICE_COMPONENT:
                let voiceConfig = SdkConfigurationManager.createVoiceIDConfigurationData(from: configuration)
                action?(voiceConfig)
            case .VIDEOCALL_COMPONENT:
                let videoCallConfig = SdkConfigurationManager.createVideoCallConfigurationData(from: configuration)
                action?(videoCallConfig)
            case .VIDEOID_COMPONENT:
                let videoIdConfig = SdkConfigurationManager.createVideoIDConfigurationData(from: configuration)
                action?(videoIdConfig)
            case .QR_COMPONENT:
                let qrConfig = SdkConfigurationManager.createQrCaptureConfigurationData(from: configuration)
                action?(qrConfig)
            case .CAPTURE_COMPONENT:
                let captureConfig = SdkConfigurationManager.createInvoiceCaptureConfigurationData(from: configuration)
                action?(captureConfig)
            case .FILE_UPLOADER_COMPONENT:
                let captureConfig = SdkConfigurationManager.createFileUploaderConfigurationData(from: configuration)
                action?(captureConfig)
            case .GALLERY_COMPONENT:
                let galleryConfig = SdkConfigurationManager.createGalleryConfigurationData(from: configuration)
                action?(galleryConfig)
            }
        }
        self.dismiss(animated: true)
    }

    @objc private func goBack() {
        dismiss(animated: true)
    }
}
