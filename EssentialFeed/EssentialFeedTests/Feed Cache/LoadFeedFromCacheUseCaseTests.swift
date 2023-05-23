//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 15/05/23.
//

import XCTest
import EssentialFeed

final class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
        
    }
    
    func test_load_requestCacheRetrieval() {
        let (sut, store) = makeSUT()
        sut.load() { _ in }
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        expect(sut, toCompleteWith: .failure(retrievalError)) {
            store.completeRetrieval(with: retrievalError)
        }
    }
    
    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrievalWithEmptyCache()
        }
    }
    
    func test_load_deliversCachedImagesNonExpiredCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let nonExpiredTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1 )
        let feed = uniqueImageFeed()
        expect(sut, toCompleteWith: .success(feed.model)) {
            store.completeRetrieval(with: feed.local, timeStamp: nonExpiredTimeStamp)
        }
    }
    
    func test_load_deliversNoImagesOnCacheExpiration() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let expirationTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let feed = uniqueImageFeed()
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: feed.local, timeStamp: expirationTimeStamp)
        }
    }
    
    func test_load_deliversNoImagesOnExpiredCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let expiredTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let feed = uniqueImageFeed()
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: feed.local, timeStamp: expiredTimeStamp)
        }
    }
    
    func test_load_hasNoSideEffectsOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnNonExpiredCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let nonExpiredTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1 )
        let feed = uniqueImageFeed()
        
        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timeStamp: nonExpiredTimeStamp)
         
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnCacheExpiration() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let expirationTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let feed = uniqueImageFeed()
        
        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timeStamp: expirationTimeStamp)
         
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnExpiredCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let expiredTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let feed = uniqueImageFeed()

        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timeStamp: expiredTimeStamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var capturedResults = [FeedLoader.Result]()
        sut?.load { result in
            capturedResults.append(result)
        }
        sut = nil
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (LocalFeedLoader, FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResult, when action: @escaping () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Waiting for load cache")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedImages), .success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
                
            case let (.failure(receiverError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receiverError.code, expectedError.code, file: file, line: line)
                XCTAssertEqual(receiverError.domain, expectedError.domain, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
}
