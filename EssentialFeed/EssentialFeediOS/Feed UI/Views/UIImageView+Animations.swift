//
//  UIImageView+Animations.swift
//  EssentialFeediOS
//
//  Created by Galih Samudra on 07/06/23.
//

import UIKit

extension UIImageView {
    func setImageAnimated(_ newImage: UIImage?) {
        image = newImage
        guard newImage != nil else { return }
        alpha = 0
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.alpha = 1
        }
    }
}

