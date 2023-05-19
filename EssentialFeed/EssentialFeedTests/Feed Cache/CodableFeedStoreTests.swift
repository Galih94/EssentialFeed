//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 17/05/23.
//

import XCTest
import EssentialFeed

protocol FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache()
    func test_retrieve_hasNoSideEffectsOnEmptyCache()
    func test_retrieve_deliversFoundValuesOnNonEmptyCache()
    func test_retrieve_hasNoSdeEffectsOnNonEmptyCache()
    
    func test_insert_deliversNoErrorOnEmptyCache()
    func test_insert_deliversNoErrorOnNonEmptyCache()
    func test_insert_overridePreviouslyInsertedCacheValues()
    
    func test_delete_deliversNoErrorOnEmptyCache()
    func test_delete_deliversNoErrorOnNonEmptyCache()
    func test_delete_hasNoSideEffectsOnEmptyCache()
    func test_delete_emptiesPreviouslyInsertedCache()
    
    func test_storeSideEffects_runSerially()
}

protocol FailableRetrieveFeedStoreSpecs {
    func test_retrieve_deliversFailureOnRetrievalError()
    func test_retrieve_hasNoSdeEffectsOnFailure()
}

protocol FailableInsertFeedStoreSpecs {
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_hasNoSideEffectOnInsertionError()
}

protocol FailableDeleteFeedStoreSpecs {
    func test_delete_deliversErrorOnDeletionError()
    func test_delete_hasNoSideEffectOnDeletionError()
}


final class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
         let sut = makeSUT()
        
        expect(sut, toRetrive: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
         let sut = makeSUT()
        
        expect(sut, toRetriveTwice: .empty)
    }

    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let timeStamp = Date()
        let feed  = uniqueImageFeed().local

        insert((feed, timeStamp), to: sut)
        
        expect(sut, toRetrive: .found(feed: feed, timeStamp: timeStamp)) // expect after exp.fulfill so expect runs after insert callback done
    }
    
    func test_retrieve_hasNoSdeEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let timeStamp = Date()
        let feed  = uniqueImageFeed().local

        insert((feed, timeStamp), to: sut)
        
        expect(sut, toRetriveTwice: .found(feed: feed, timeStamp: timeStamp))
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpesificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid json".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrive: .failure(anyNSError()))
    }
    
    func test_retrieve_hasNoSdeEffectsOnFailure() {
        let storeURL = testSpesificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid json".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetriveTwice: .failure(anyNSError()))
    }
    
    func test_insert_overridePreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        
        let firstCache = (uniqueImageFeed().local, Date())
        let firstInsertionError = insert(firstCache, to: sut)
        XCTAssertNil(firstInsertionError, "Expect insert success")
        
        let latestFeed = uniqueImageFeed().local
        let latestDate = Date()
        let latestInsertionError = insert((latestFeed, latestDate), to: sut)
        XCTAssertNil(latestInsertionError, "Expect insert success")
        
        expect(sut, toRetrive: .found(feed: latestFeed, timeStamp: latestDate))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let date = Date()
        
        let insertionError = insert((feed, date), to: sut)
        
        XCTAssertNotNil(insertionError, "Expect insert failure")
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expect deletion success")
        expect(sut, toRetrive: .empty)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        
        insert((uniqueImageFeed().local, Date()), to: sut)
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expect deletion success")
        expect(sut, toRetrive: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionURL = cacheDirectory() // use any firsts url that has no set up path component
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNotNil(deletionError, "Expect deletion success")
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
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
        XCTAssertEqual(completedOperationsOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in wrong order")
    }
    
    // MARK: Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpesificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func testSpesificStoreURL() -> URL {
        return cacheDirectory().appending(path: "\(type(of: self)).store")
    }
    
    private func cacheDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func deleteCache(from sut: FeedStore) -> Error? {
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
    private func insert(_ cache: (feed: [LocalFeedImage], timeStamp: Date), to sut: FeedStore) -> Error? {
        let exp = expectation(description: "Waiting for insertion")
        var insertionError: Error?
        sut.insert(cache.feed, timeStamp: cache.timeStamp){ receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3.0)
        
        return insertionError
    }
    
    private func expect(_ sut: FeedStore, toRetriveTwice expectedResult: RetrievedCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrive: expectedResult, file: file, line: line)
        expect(sut, toRetrive: expectedResult, file: file, line: line)
    }
    
    private func expect(_ sut: FeedStore, toRetrive expectedResult: RetrievedCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
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
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpesificStoreURL())
    }

}
