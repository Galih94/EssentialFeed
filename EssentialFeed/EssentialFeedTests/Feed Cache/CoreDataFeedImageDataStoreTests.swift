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
        let bundle = Bundle(for: CoreDataFeedStore.self)
        let storeUrl = URL(filePath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeUrl, bundle: bundle)
        
        
        let url = anyURL()
        let exp = expectation(description: "Wait for retrieval")
        sut.retrieve(dataForURL: url) { result in
            switch result {
            case let .success(data):
                XCTAssertEqual(data, .none)
            default: XCTFail("Expected found empty data got \(result) isntead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

}
