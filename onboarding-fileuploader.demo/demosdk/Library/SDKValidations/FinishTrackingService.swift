//
//  FinishTrackingService.swift
//  demosdk
//
//  Created by Jorge Poveda on 1/12/25.
//

import core
import Foundation

class FinishTrackingService: ValidationServiceProtocol {
    private let path = "/services/finishTracking"
    
    private let baseUrl: String
    private let apiKey: String
    
    private let extraDataResult: SdkResult<String>
    private let family: String
    private let status: String
    private let reason: String

    init(baseUrl: String, apiKey: String, extraDataResult: SdkResult<String>, finishTrackingData: FinishTrackingData) {
        self.baseUrl = baseUrl
        self.apiKey = apiKey
        self.extraDataResult = extraDataResult
        self.family = finishTrackingData.family.toIdApiString()
        self.status = finishTrackingData.status.rawValue
        self.reason = finishTrackingData.reason.rawValue
    }
    
    func execute(callback: @escaping (String) -> Void) {
        guard extraDataResult.finishStatus == .STATUS_OK,
              let extraData = extraDataResult.data else {
            callback("LAUNCH FINISH TRACKING -> KO\nFAILED TO CREATE EXTRADATA: \(extraDataResult.errorType)")
            return
        }
        let body = """
            {
              \"family\": \"\(family)\",
              \"status\": \"\(status)\",
              \"reason\": \"\(reason)\",
              \"extraData\": \"\(extraData)\"
            }
            """
        
        var request = URLRequest(url: URL(string: baseUrl + path)!, timeoutInterval: Double.infinity)
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
            print("LAUNCH FINISH TRACKING")
            callback(String(data: data, encoding: .utf8) ?? "<non-utf8 data: \(data.count) bytes>")
        }
        task.resume()
    }
}
