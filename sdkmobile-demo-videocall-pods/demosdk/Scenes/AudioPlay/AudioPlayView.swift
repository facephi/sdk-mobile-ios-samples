//
//  AudioPlayView.swift
//  demosdk
//
//  Created by Carlos Cantos on 12/7/23.
//

import Foundation
import UIKit

protocol AudioPlayViewDelegate: AnyObject {
    func backButtonTouchUpInside()
    func playAudioButtonTouchUpInside(tag: Int)
}

class AudioPlayView: UIView {
    var delegate: AudioPlayViewDelegate?
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    
    @objc func buttonClickListener(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        delegate?.playAudioButtonTouchUpInside(tag: button.tag)
    }
    
    @IBAction func backButtonTouchUpInside(_ sender: Any) {
        delegate?.backButtonTouchUpInside()
    }
    public func configure(numberOfAudios: Int) {
        
        var i = 0
        while i < numberOfAudios {
            let button = UIButton()
            button.tag = i
            button.setTitle("Play Audio " + String(button.tag), for: .normal)
            button.backgroundColor = .systemBlue
            button.addTarget(self, action: #selector(self.buttonClickListener(_:)), for: .touchUpInside)
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
//            button.trailingAnchor.constraint(equalTo: 8).isActive = true
//            button.leadingAnchor.constraint(equalTo: 8).isActive = true
            stackView.addArrangedSubview(button)
            i += 1
        }
    }
}
