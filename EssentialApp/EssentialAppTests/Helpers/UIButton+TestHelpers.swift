//
//  UIButton+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Galih Samudra on 31/05/23.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
