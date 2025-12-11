//
//  IdentityValidationService.swift
//  demosdk
//
//  Created by Jorge Poveda on 1/12/25.
//

import core
import Foundation

class IdentityValidationService: ValidationServiceProtocol {
    private let path = "/onboarding/v2/identity"
    
    private let baseUrl: String
    private let apiKey: String
    
    private let extraDataResult: SdkResult<String>
    private let tokenFaceImage: String
    private let bestImageToken: String
    private let operationId: String

    init(baseUrl: String, apiKey: String, extraDataResult: SdkResult<String>, tokenFaceImage: String, bestImageToken: String, operationId: String) {
        self.baseUrl = baseUrl
        self.apiKey = apiKey
        self.extraDataResult = extraDataResult
        self.tokenFaceImage = tokenFaceImage
        self.bestImageToken = bestImageToken
        self.operationId = operationId
    }
    
    func execute(callback: @escaping (String) -> Void) {
        var result = ""
        guard extraDataResult.finishStatus == .STATUS_OK,
              let extraData = extraDataResult.data else {
            callback("LAUNCH IDENTITY VALIDATION -> KO\nFAILED TO CREATE EXTRADATA: \(extraDataResult.errorType)")
            return
        }
        let body = """
            {
                \"token1\": \"\(tokenFaceImage)\",
                \"bestImageToken\": \"\(bestImageToken)\",
                \"method\": \"5\",
                \"tracking\": {
                    \"extraData\": \"\(extraData)\",
                    \"operationId\": \"\(operationId)\"
                }
            }
            """
        
        var request = URLRequest(url: URL(string: baseUrl + path)!,timeoutInterval: Double.infinity)
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
            print("LAUNCH IDENTITY VALIDATION")
            result = String(data: data, encoding: .utf8) ?? "<non-utf8 data: \(data.count) bytes>"
            callback(result)
        }
        task.resume()
    }
}
