//
//  UIView.swift
//  demosdk
//
//  Created by Carlos Cantos on 12/7/23.
//
import UIKit

extension UIView {
    class func fromNib<T: UIView>() -> T {
        guard let nib = Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as? T
        else {
                fatalError("could not load nib name from Bundle")
            }
        return nib
    }
    
    func addSubviewWithConstraints(attributes: [NSLayoutConstraint.Attribute] = [.top, .bottom, .leading, .trailing], parentView: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        parentView.insertSubview(self, aboveSubview: parentView)
        
        attributes.forEach { constraint in
            parentView.addConstraint(NSLayoutConstraint(item: self, attribute: constraint, relatedBy: .equal, toItem: parentView, attribute: constraint, multiplier: 1.0, constant: 0.0))
        }
    }
}
