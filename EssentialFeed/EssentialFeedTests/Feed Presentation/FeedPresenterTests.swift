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
        let (_, view) = makeSUT()
        _ = FeedPresenter(view: view)
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messsages")
    }
    
    // MARK: -- Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (FeedPresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(view: view)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(view, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy {
        let messages = [Any]()
    }
}
