//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Galih Samudra on 22/06/23.
//

import XCTest
import EssentialFeed

protocol FeedCache {
    typealias SaveResult = Result<Void, Error>
    func save(_ feed : [FeedImage], completion: @escaping (SaveResult) -> Void)
}

final class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCache
    
    init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            if let feed = try? result.get() {
                self?.cache.save(feed, completion: { _ in })
            }
            completion(result)
        }
    }
}

final class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {
    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let sut = makeSUT(loaderResult: .success(feed))

        expect(sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliversFeedOnLoaderFailure() {
        let error = anyNSError()
        let sut = makeSUT(loaderResult: .failure(error))

        expect(sut, toCompleteWith: .failure(error))
    }
    
    func test_load_cachesLoadedFeedOnLoaderSuccess() {
        let cache = CacheSpy()
        let feed = uniqueFeed()
        let sut = makeSUT(loaderResult: .success(feed), cache: cache)
        
        sut.load { _ in }
        
        XCTAssertEqual(cache.message, [.save(feed)], "Expected to cache loaded feed on success")
    }
    
    func test_load_doesNotCacheOnLoadFailure() {
        let cache = CacheSpy()
        let sut = makeSUT(loaderResult: .failure(anyNSError()), cache: cache)
        
        sut.load { _ in }
        
        XCTAssertTrue(cache.message.isEmpty, "Expected not to cache loaded feed on laod error")
    }
    
    // MARK: Helpers
    private func makeSUT(loaderResult: FeedLoader.Result, cache: CacheSpy = .init(), file: StaticString = #filePath, line: UInt = #line) -> FeedLoaderCacheDecorator {
        let loader = FeedLoaderStub(result: loaderResult)
        let sut = FeedLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return sut
    }
    
    private final class CacheSpy: FeedCache {
        private(set) var message = [Message]()
        enum Message: Equatable {
            case save([FeedImage])
        }
        
        func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
            message.append(.save(feed))
            completion(.success(() ))
        }
    }
}
