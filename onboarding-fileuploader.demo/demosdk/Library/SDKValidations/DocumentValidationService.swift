//
//  DocumentValidationService.swift
//  demosdk
//
//  Created by Jorge Poveda on 1/12/25.
//

import core
import Foundation

protocol DocumentValidationServiceProtocol {
    func start(callback: @escaping (String) -> Void)
    func status(callback: @escaping (String) -> Void)
    func data(callback: @escaping (String) -> Void)
}

class DocumentValidationService: DocumentValidationServiceProtocol {
    private let path = "/verify/documentValidation/v2/"
    
    private let baseUrl: String
    private let apiKey: String
    
    private let extraDataResult: SdkResult<String>
    private let frontDocumentImage: String
    private let backDocumentImage: String
    private let country: String
    private let documentType: String
    private let operationId: String
    
    private var validationStartResponse: DocumentValidationStartResponse?

    init(baseUrl: String, apiKey: String, extraDataResult: SdkResult<String>, frontDocumentImage: String, backDocumentImage: String, country: String, documentType: String, operationId: String) {
        self.baseUrl = baseUrl
        self.apiKey = apiKey
        
        self.extraDataResult = extraDataResult
        self.frontDocumentImage = frontDocumentImage
        self.backDocumentImage = backDocumentImage
        self.country = country
        self.documentType = documentType
        self.operationId = operationId
    }
    
    func start(callback: @escaping (String) -> Void) {
        guard extraDataResult.finishStatus == .STATUS_OK else {
            callback("LAUNCH DOCUMENT VALIDATION START -> KO\nFAILED TO CREATE EXTRADATA: \(extraDataResult.errorType)")
            return
        }
        let body = """
            {
              \"documentFrontRawImage\": \"\(frontDocumentImage)\",
              \"documentBackRawImage\": \"\(backDocumentImage)\",
              \"documentRawImageMimeType\": \"image/jpeg\",
              \"country\": \"\(country)\",
              \"idType\": \"\(documentType)\"
            }
            """
        
        var request = URLRequest(url: URL(string: baseUrl + path + "start")!,timeoutInterval: Double.infinity)
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                let message = error.map { String(describing: $0) } ?? "Unknown network error"
                callback(message)
                return
            }
            guard let startResponse = try? JSONDecoder().decode(DocumentValidationStartResponse.self, from: data) else {
                callback("Couldn't decode DocumentValidationStartResponse:\n\(data)")
                return
            }
            self.validationStartResponse = startResponse
            callback(String(data: data, encoding: .utf8) ?? "<non-utf8 data: \(data.count) bytes>")
        }
        task.resume()
    }
    
    func status(callback: @escaping (String) -> Void) {
        guard extraDataResult.finishStatus == .STATUS_OK else {
            callback("LAUNCH DOCUMENT VALIDATION STATUS -> KO\nFAILED TO CREATE EXTRADATA: \(extraDataResult.errorType)")
            return
        }
        guard let validationStartResponse else {
            callback("LAUNCH DOCUMENT VALIDATION STATUS -> KO\nVALIDATION START MUST PRECEDE THIS STEP")
            return
        }
        let body = """
            {
              \"scanReference\": \"\(validationStartResponse.scanReference)\",
              \"type\": \"\(validationStartResponse.type)\"
            }
            """
        
        var request = URLRequest(url: URL(string: baseUrl + path + "status")!,timeoutInterval: Double.infinity)
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                let message = error.map { String(describing: $0) } ?? "Unknown network error"
                callback(message)
                return
            }
            print("LAUNCH DOCUMENT VALIDATION STATUS")
            callback(String(data: data, encoding: .utf8) ?? "<non-utf8 data: \(data.count) bytes>")
        }
        task.resume()
    }
    
    func data(callback: @escaping (String) -> Void) {
        guard extraDataResult.finishStatus == .STATUS_OK,
              let extraData = extraDataResult.data else {
            callback("LAUNCH DOCUMENT EXTRACTION -> KO\nFAILED TO CREATE EXTRADATA: \(extraDataResult.errorType)")
            return
        }
        guard let validationStartResponse else {
            callback("LAUNCH DOCUMENT VALIDATION STATUS -> KO\nVALIDATION START MUST PRECEDE THIS STEP")
            return
        }
        let body = """
            {
              \"scanReference\": \"\(validationStartResponse.scanReference)\",
              \"type\": \"\(validationStartResponse.type)\",
              \"tracking\": {
                \"extraData\": \"\(extraData)\",
                \"operationId\": \"\(operationId)\"
              }
            }
            """
        
        var request = URLRequest(url: URL(string: baseUrl + path + "data")!,timeoutInterval: Double.infinity)
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                let message = error.map { String(describing: $0) } ?? "Unknown network error"
                callback(message)
                return
            }
            print("LAUNCH DOCUMENT VALIDATION DATA")
            callback(String(data: data, encoding: .utf8) ?? "<non-utf8 data: \(data.count) bytes>")
        }
        task.resume()
    }
}


struct DocumentValidationDataResponse: Codable {
    var status: String
    var verification: DocumentValidationDataVerificationResponse
}

struct DocumentValidationDataVerificationResponse: Codable {
    var code: IdApiVerificationCode
}


//Corresponding status code. Possible values: Started (7001), Submitted (7002), Approved (9001), Declined (9102), Resubmission (9103), Expired/Abandoned (9104), Review (9121)
enum IdApiVerificationCode: Int, Codable {
    case Started = 7001
    case Submitted = 7002
    case Approved = 9001
    case Declined = 9102
    case Resubmission = 9103
    case Expired = 9104
    case Review = 9121
    
    func toString() -> String {
        switch self {
        case .Started:
            return "Started"
        case .Submitted:
            return "Submitted"
        case .Approved:
            return "Approved"
        case .Declined:
            return "Declined"
        case .Resubmission:
            return "Resubmission"
        case .Expired:
            return "Expired"
        case .Review:
            return "Review"
        }
    }
}

struct DocumentValidationStartResponse: Codable {
    var scanReference: String
    var type: String
}



//family    String    Yes    Possible values: Authentication, OnBoarding
//status    String    Yes    Possible values: SUCCEEDED, DENIED, ERROR, CANCELLED, BLACKLISTED
//reason    String    Yes    Possible values: DOCUMENT_VALIDATION_NOT_PASSED, DOCUMENT_VALIDATION_ERROR, FACIAL_AUTHENTICATION_NOT_PASSED, FACIAL_LIVENESS_NOT_PASSED, FACIAL_AUTHENTICATION_ERROR, FACIAL_LIVENESS_ERROR, BLACKLISTED_FACE_TEMPLATE, ALREADY_REGISTERED, MANUAL_STATUS_CHANGE, SECURITY_SERVICE_ERROR, SELPHID_INTERNAL_ERROR, SELPHID_TIMEOUT, SELPHI_TIMEOUT
