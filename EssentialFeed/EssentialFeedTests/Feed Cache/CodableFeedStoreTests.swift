//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 17/05/23.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timeStamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map {
                $0.local
            }
        }
    }
    
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        public var local: LocalFeedImage {
            return LocalFeedImage(id: id,
                                  description: description,
                                  location: location,
                                  url: url)
        }
        
        public init(_ image: LocalFeedImage) {
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.url = image.url
        }
    }
    
    private let storeURL: URL
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func insert(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        do {
            let codableFeed = feed.map(CodableFeedImage.init)
            let cache = Cache(feed: codableFeed, timeStamp: timeStamp)
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(cache)
            try encoded.write(to: storeURL)
            
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        do {
            let decode = JSONDecoder()
            let cache = try decode.decode(Cache.self, from: data)
            completion(.found(feed: cache.localFeed, timeStamp: cache.timeStamp))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion) {
        completion(nil)
        
    }
    
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
    }
    
    // MARK: Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpesificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func testSpesificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appending(path: "\(type(of: self)).store")
    }
    
    private func deleteCache(from sut: CodableFeedStore) -> Error? {
        var deletionError: Error?
        
        let exp = expectation(description: "Waiting for deletion")
        sut.deleteCachedFeed { receivedDeletionError in
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    
    @discardableResult
    private func insert(_ cache: (feed: [LocalFeedImage], timeStamp: Date), to sut: CodableFeedStore) -> Error? {
        let exp = expectation(description: "Waiting for insertion")
        var insertionError: Error?
        sut.insert(cache.feed, timeStamp: cache.timeStamp){ receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return insertionError
    }
    
    private func expect(_ sut: CodableFeedStore, toRetriveTwice expectedResult: RetrievedCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrive: expectedResult, file: file, line: line)
        expect(sut, toRetrive: expectedResult, file: file, line: line)
    }
    
    private func expect(_ sut: CodableFeedStore, toRetrive expectedResult: RetrievedCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
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
        
        wait(for: [exp], timeout: 1.0)
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
