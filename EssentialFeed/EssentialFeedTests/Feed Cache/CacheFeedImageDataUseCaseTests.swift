//
//  CacheFeedImageDataUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 16/06/23.
//

import XCTest
import EssentialFeed

final class CacheFeedImageDataUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_saveImageData_requestsImageDataInsertionForURL() {
        let (sut, store) = makeSUT()
        let data = anyData()
        let url = anyURL()
        
        sut.save(data, for: url) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.insert(data: data, for: url)])
    }
    
    func test_saveImageData_failsOnStoreInsertionError() {
        let (sut, store) = makeSUT()
        let data = anyData()
        let url = anyURL()
        let expError = LocalFeedImageDataLoader.SaveError.failed
        
        
        let exp = expectation(description: "Wait for completion")
        sut.save(data, for: url) { result in
            switch result {
            case let .failure(error):
                XCTAssertEqual(error as! LocalFeedImageDataLoader.SaveError, expError)
            default: XCTFail()
            }
            
            exp.fulfill()
        }
        store.completeInsertion(with: expError)
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
    // MARK: -- Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (LocalFeedImageDataLoader, FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
    
}
