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

final class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {
    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let decoratee = FeedLoaderStub(result: .success(feed))
        let sut = FeedLoaderCacheDecorator(decoratee: decoratee)

        expect(sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliversFeedOnLoaderFailure() {
        let error = anyNSError()
        let decoratee = FeedLoaderStub(result: .failure(error))
        let sut = FeedLoaderCacheDecorator(decoratee: decoratee)

        expect(sut, toCompleteWith: .failure(error))
    }
}
