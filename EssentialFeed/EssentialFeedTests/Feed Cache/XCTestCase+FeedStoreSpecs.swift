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
        expect(sut, toRetrive: .empty, file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetriveTwice: .empty, file: file, line: line)
    }
    
    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let timeStamp = Date()
        let feed  = uniqueImageFeed().local

        insert((feed, timeStamp), to: sut)
        
        expect(sut, toRetrive: .found(feed: feed, timeStamp: timeStamp), file: file, line: line) // expect after exp.fulfill so expect runs after insert callback done
    }
    
    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let timeStamp = Date()
        let feed  = uniqueImageFeed().local

        insert((feed, timeStamp), to: sut)
        
        expect(sut, toRetriveTwice: .found(feed: feed, timeStamp: timeStamp), file: file, line: line)
    }
    
    func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let timeStamp = Date()
        let feed  = uniqueImageFeed().local

        insert((feed, timeStamp), to: sut)
        
        expect(sut, toRetriveTwice: .found(feed: feed, timeStamp: timeStamp), file: file, line: line)
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
        
        expect(sut, toRetrive: .found(feed: latestFeed, timeStamp: latestDate), file: file, line: line)
    }
    
    func assertDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        deleteCache(from: sut)
        
        expect(sut, toRetrive: .empty, file: file, line: line)
    }
    
    func assertDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expect delete success", file: file, line: line)
    }
    
    func assertDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        deleteCache(from: sut)
        
        expect(sut, toRetrive: .empty, file: file, line: line)
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
        sut.deleteCachedFeed { receivedDeletionError in
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 3.0)
        return deletionError
    }
    
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timeStamp: Date), to sut: FeedStore) -> Error? {
        let exp = expectation(description: "Waiting for insertion")
        var insertionError: Error?
        sut.insert(cache.feed, timeStamp: cache.timeStamp){ receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3.0)
        
        return insertionError
    }
    
    func expect(_ sut: FeedStore, toRetriveTwice expectedResult: RetrievedCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrive: expectedResult, file: file, line: line)
        expect(sut, toRetrive: expectedResult, file: file, line: line)
    }
    
    func expect(_ sut: FeedStore, toRetrive expectedResult: RetrievedCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Waiting for retrieval")
        sut.retrieve { result in
            switch (result, expectedResult) {
            case (.empty, .empty), (.failure, .failure):
                break
            case let (
                .found(resultFeed, timeStampFeed),
                .found(expectedResultFeed, expectedResultTimeStamp)):
                
                XCTAssertEqual(resultFeed, expectedResultFeed, file: file, line: line)
                XCTAssertEqual(timeStampFeed, expectedResultTimeStamp, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult) got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 3.0)
    }
}


extension FailableRetrieveFeedStoreSpecs where Self: XCTestCase {
    func assertRetrieveDeliversFailureOnRetrievalError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        
        expect(sut, toRetrive: .failure(anyNSError()))
    }
    
    func assertRetrieveHasNoSdeEffectsOnFailure(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        
        expect(sut, toRetriveTwice: .failure(anyNSError()))
    }
}

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
    func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let date = Date()
        
        let insertionError = insert((feed, date), to: sut)
        
        XCTAssertNotNil(insertionError, "Expect insert failure")
    }
    
    func assertThatInsertHasNoSideEffectOnInsertionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let date = Date()
        
        insert((feed, date), to: sut)
        
        expect(sut, toRetrive: .empty)
    }
}
