//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Galih Samudra on 22/06/23.
//

import XCTest
import EssentialFeed

final class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    
    init(decoratee: FeedLoader) {
        self.decoratee = decoratee
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load(completion: completion)
    }
}

final class FeedLoaderCacheDecoratorTests: XCTestCase {
    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let decoratee = LoaderStub(result: .success(feed))
        let sut = FeedLoaderCacheDecorator(decoratee: decoratee)

        let exp = expectation(description: "Wait for completion")
        sut.load { result in
            switch result {
            case let .success(feedResult):
                XCTAssertEqual(feedResult, feed)
            default: XCTFail("Expected success got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: Helper
    private final class LoaderStub: FeedLoader {
        private let result: FeedLoader.Result
        init(result: FeedLoader.Result) {
            self.result = result
        }
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }
}
