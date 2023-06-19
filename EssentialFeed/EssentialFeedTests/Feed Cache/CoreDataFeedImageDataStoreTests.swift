//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 19/06/23.
//

import XCTest
import EssentialFeed

extension CoreDataFeedStore: FeedImageDataStore {
    public func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {}
    
    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        completion(.success(.none))
    }
}

final class CoreDataFeedImageDataStoreTests: XCTestCase {
    
    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let sut = makeSUT()
        
        expect(sut, toCompleteRetrieveWith: .success(.none), for: anyURL())
    }
    
    func test_retrieveImageData_deliversNotFoundWhenStoredDataURLDoesNotMatch() {
        let sut = makeSUT()
        let imageURL = URL(string: "http://image-url.com")!
        let nonMatchingURL = URL(string: "http://another-url.com")!
        
        let data = anyData()
        let exp = expectation(description: "Wait for insertion")
        let image = LocalFeedImage(id: UUID(), description: "any description", location: "any location", url: imageURL)
        sut.insert([image], timeStamp: Date()) { insertImageResult in
            switch insertImageResult {
            case let .failure(error): XCTFail("Expected success got \(error) intead")
            case .success:
                sut.insert(data, for: imageURL) { insertResult in
                    if case let Result.failure(error) = insertResult {
                        XCTFail("Failed insert data \(data) got \(error) intead")
                    }
                }
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        expect(sut, toCompleteRetrieveWith: .success(.none), for: nonMatchingURL)
    }

    // MARK: Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CoreDataFeedStore {
        let bundle = Bundle(for: CoreDataFeedStore.self)
        let storeUrl = URL(filePath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeUrl, bundle: bundle)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: CoreDataFeedStore, toCompleteRetrieveWith expectedResult: FeedImageDataStore.RetrievalResult, for url: URL, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for retrieval")
        sut.retrieve(dataForURL: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            default: XCTFail("Expected \(receivedResult) got \(expectedResult) isntead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}
