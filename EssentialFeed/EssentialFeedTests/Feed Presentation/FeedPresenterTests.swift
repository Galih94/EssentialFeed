//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 13/06/23.
//

import XCTest

final class FeedPresenter {
    let view: Any
    init(view: Any) {
        self.view = view
    }
}

final class FeedPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let view = ViewSpy()
        _ = FeedPresenter(view: view)
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messsages")
    }
    
    // MARK: -- Helpers
    private class ViewSpy {
        let messages = [Any]()
    }
}
