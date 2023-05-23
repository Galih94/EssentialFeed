//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 19/05/23.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    
    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrive: .success(.none), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetriveTwice: .success(.none), file: file, line: line)
    }
    
    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let timeStamp = Date()
        let feed  = uniqueImageFeed().local

        insert((feed, timeStamp), to: sut)
        
        expect(sut, toRetrive: .success(CachedFeed(feed: feed, timeStamp: timeStamp)), file: file, line: line) // expect after exp.fulfill so expect runs after insert callback done
    }
    
    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let timeStamp = Date()
        let feed  = uniqueImageFeed().local

        insert((feed, timeStamp), to: sut)
        
        expect(sut, toRetriveTwice: .success(CachedFeed(feed: feed, timeStamp: timeStamp)), file: file, line: line)
    }
    
    func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let timeStamp = Date()
        let feed  = uniqueImageFeed().local

        insert((feed, timeStamp), to: sut)
        
        expect(sut, toRetriveTwice: .success(CachedFeed(feed: feed, timeStamp: timeStamp)), file: file, line: line)
    }
    
    func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let insertionRrror = insert((uniqueImageFeed().local, Date()), to: sut)
        
        XCTAssertNil(insertionRrror, "Expect insert success", file: file, line: line)
    }
    
    func assertThatInsertOverridePreviouslyInsertedCacheValues(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let firstCache = (uniqueImageFeed().local, Date())
        insert(firstCache, to: sut)
        
        let latestFeed = uniqueImageFeed().local
        let latestDate = Date()
        insert((latestFeed, latestDate), to: sut)
        
        expect(sut, toRetrive: .success(CachedFeed(feed: latestFeed, timeStamp: latestDate)), file: file, line: line)
    }
    
    func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        deleteCache(from: sut)
        
        expect(sut, toRetrive: .success(.none), file: file, line: line)
    }
    
    func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expect delete success", file: file, line: line)
    }
    
    func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        deleteCache(from: sut)
        
        expect(sut, toRetrive: .success(.none), file: file, line: line)
    }
    
    func assertThatSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        var completedOperationsOrder = [XCTestExpectation]()
        
        
        let op1 = expectation(description: "operation 1")
        sut.insert(uniqueImageFeed().local, timeStamp: Date()) { _ in
            completedOperationsOrder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "operation 2")
        sut.deleteCachedFeed { _ in
            completedOperationsOrder.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "operation 3")
        sut.insert(uniqueImageFeed().local, timeStamp: Date()) { _ in
            completedOperationsOrder.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 3.0)
        XCTAssertEqual(completedOperationsOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in wrong order", file: file, line: line)
    }
    
    @discardableResult
    func deleteCache(from sut: FeedStore) -> Error? {
        var deletionError: Error?
        
        let exp = expectation(description: "Waiting for deletion")
        sut.deleteCachedFeed { receivedDeletionResult in
            if case let Result.failure(error) = receivedDeletionResult {
                deletionError = error
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 3.0)
        return deletionError
    }
    
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timeStamp: Date), to sut: FeedStore) -> Error? {
        let exp = expectation(description: "Waiting for insertion")
        var insertionError: Error?
        sut.insert(cache.feed, timeStamp: cache.timeStamp){ receivedInsertionResult in
            if case let Result.failure(error) = receivedInsertionResult {
                insertionError = error
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3.0)
        
        return insertionError
    }
    
    func expect(_ sut: FeedStore, toRetriveTwice expectedResult: FeedStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrive: expectedResult, file: file, line: line)
        expect(sut, toRetrive: expectedResult, file: file, line: line)
    }
    
    func expect(_ sut: FeedStore, toRetrive expectedResult: FeedStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Waiting for retrieval")
        sut.retrieve { result in
            switch (result, expectedResult) {
            case (.success(.none), .success(.none)), (.failure, .failure):
                break
            case let (
                .success(cachedFeed),
                .success(expectedCachedFeed)):
                
                XCTAssertEqual(cachedFeed?.feed, expectedCachedFeed?.feed, file: file, line: line)
                XCTAssertEqual(cachedFeed?.timeStamp, expectedCachedFeed?.timeStamp, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult) got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 3.0)
    }
}
