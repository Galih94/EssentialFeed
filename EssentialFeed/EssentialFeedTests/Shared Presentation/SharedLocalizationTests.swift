//
//  SharedLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 05/07/23.
//

import XCTest
import EssentialFeed

final class SharedLocalizationTests: XCTestCase {

    func test_localizedStrings_haveKeysAndValuesForAkkSupportedLocalizations() {
        let table = "Shared"
        let bundle = Bundle(for: LoadResourcePresenter<Any, DummyView>.self)
        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }
    
    // MARK: -- Helpers
    private class DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }
}
