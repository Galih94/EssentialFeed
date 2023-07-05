//
//  FeedViewControllerTests+Localization.swift
//  EssentialFeediOSTests
//
//  Created by Galih Samudra on 07/06/23.
//

import Foundation
import EssentialFeed
import XCTest

extension FeedUIIntegrationTests {
    var loadError: String {
        LoadResourcePresenter<Any, DummyView>.loadError
    }
    
    var feedTitle: String {
        FeedPresenter.title
    }
    
    private class DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }
}
