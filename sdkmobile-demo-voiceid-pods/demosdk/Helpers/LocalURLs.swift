//
//  LocalURLs.swift
//  demosdk
//
//  Created by Carlos Cantos on 12/7/23.
//

import Foundation

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}
