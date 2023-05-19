//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 17/05/23.
//

import XCTest
import EssentialFeed

final class CodableFeedStoreTests: XCTestCase, FailableFeedStore {
    
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
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
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
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()

        let insertionRrror = insert((uniqueImageFeed().local, Date()), to: sut)
        
        XCTAssertNil(insertionRrror, "Expect insert success")
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let insertionRrror = insert((uniqueImageFeed().local, Date()), to: sut)
        
        XCTAssertNil(insertionRrror, "Expect insert success")
    }
    
    func test_insert_overridePreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        
        let firstCache = (uniqueImageFeed().local, Date())
        insert(firstCache, to: sut)
        
        let latestFeed = uniqueImageFeed().local
        let latestDate = Date()
        insert((latestFeed, latestDate), to: sut)
        
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
    
    func test_insert_hasNoSideEffectOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let date = Date()
        
        insert((feed, date), to: sut)
        
        expect(sut, toRetrive: .empty)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expect delete success")
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expect delete success")
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        deleteCache(from: sut)
        
        expect(sut, toRetrive: .empty)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        deleteCache(from: sut)
        
        expect(sut, toRetrive: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionURL = cacheDirectory() // use any firsts url that has no set up path component
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNotNil(deletionError, "Expect deletion success")
    }
    
    func test_delete_hasNoSideEffectOnDeletionError() {
        let noDeletePermissionURL = cacheDirectory() // use any firsts url that has no set up path component
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        deleteCache(from: sut)
        
        expect(sut, toRetrive: .empty)
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
