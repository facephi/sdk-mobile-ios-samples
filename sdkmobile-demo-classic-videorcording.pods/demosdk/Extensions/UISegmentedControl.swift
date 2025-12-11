//
//  UISegmentedControl.swift
//  ios
//
//  Created by Faustino Flores García on 28/1/22.
//

import UIKit

extension UISegmentedControl {
    func fill<T: Equatable & RawRepresentable>(withValues values: [T], defaultValue: T?) {
        self.removeAllSegments()

        var selectedIndex = 0
        for index in 0 ..< values.count {
            let selected: T = values[index]
            if selectedIndex == 0, selected == defaultValue {
                selectedIndex = index
            }
            if let title = selected.rawValue as? String {
                self.insertSegment(withTitle: title, at: index, animated: false)
            }
        }

        self.selectedSegmentIndex = selectedIndex
    }
}
