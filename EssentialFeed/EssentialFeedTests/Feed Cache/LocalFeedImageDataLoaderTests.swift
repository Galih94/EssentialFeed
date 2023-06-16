//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 16/06/23.
//

import XCTest

final class LocalFeedImageDataLoader {
    init(store: Any) {}
}

final class LocalFeedImageDataLoaderTests: XCTestCase {

    func test_init_doesOtMessageStoreUponCreation() {
        let store = FeedStoreSpy()
        _ = LocalFeedImageDataLoader(store: store)
        
        XCTAssertTrue(store.receivedMessages.isEmpty, "Expected no receivedMessages on initialization")
    }
    
    // MARK: Helpers
    private class FeedStoreSpy {
        let receivedMessages = [Any]()
    }
}
