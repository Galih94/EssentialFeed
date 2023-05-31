//
//  UIControl+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Galih Samudra on 31/05/23.
//

import UIKit

extension UIControl {
    func simulate(event: UIControl.Event) {
        allTargets.forEach{ target in
            actions(forTarget: target, forControlEvent: event)?.forEach{
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
