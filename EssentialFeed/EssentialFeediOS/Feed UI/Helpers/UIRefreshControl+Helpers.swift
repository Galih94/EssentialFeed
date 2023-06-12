//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by Galih Samudra on 12/06/23.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
