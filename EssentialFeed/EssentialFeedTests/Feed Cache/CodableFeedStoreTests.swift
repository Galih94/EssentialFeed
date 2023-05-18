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
        let codableFeed = feed.map(CodableFeedImage.init)
        let cache = Cache(feed: codableFeed, timeStamp: timeStamp)
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        
        completion(nil)
    }
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        let decode = JSONDecoder()
        let cache = try! decode.decode(Cache.self, from: data)
        completion(.found(feed: cache.localFeed, timeStamp: cache.timeStamp))
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

    func test_retrieveAfterInsertingFromEmptyCache_deliversInsertedValue() {
        let sut = makeSUT()
        let timeStamp = Date()
        let feed  = uniqueImageFeed().local

        let exp = expectation(description: "Waiting for retrieval")
        sut.insert(feed, timeStamp: timeStamp){ insertionError in
            XCTAssertNil(insertionError, "Expected no error")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        expect(sut, toRetrive: .found(feed: feed, timeStamp: timeStamp)) // expect after exp.fulfill so expect runs after insert callback done
    }
    
    func test_retrieve_hasNoSdeEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let timeStamp = Date()
        let feed  = uniqueImageFeed().local

        let exp = expectation(description: "Waiting for insertion")
        sut.insert(feed, timeStamp: timeStamp){ insertionError in
            XCTAssertNil(insertionError, "Expected no error")
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        expect(sut, toRetriveTwice: .found(feed: feed, timeStamp: timeStamp))
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: testSpesificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func testSpesificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appending(path: "\(type(of: self)).store")
    }
    
    private func expect(_ sut: CodableFeedStore, toRetriveTwice expectedResult: RetrievedCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrive: expectedResult, file: file, line: line)
        expect(sut, toRetrive: expectedResult, file: file, line: line)
    }
    
    private func expect(_ sut: CodableFeedStore, toRetrive expectedResult: RetrievedCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Waiting for retrieval")
        sut.retrieve { result in
            switch (result, expectedResult) {
            case (.empty, .empty):
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
