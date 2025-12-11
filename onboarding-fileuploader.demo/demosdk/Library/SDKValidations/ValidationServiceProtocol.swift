
//
//  ValidationServiceProtocol.swift
//  demosdk
//
//  Created by Jorge Poveda on 1/12/25.
//

protocol ValidationServiceProtocol {
    func execute(callback: @escaping (String) -> Void)
}
