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
        
        expect(sut, toCompleteWith: failed()) {
            store.completeInsertion(with: anyNSError())
        }
    }
    
    func test_saveImageData_succeedsOnSuccessfullStoreInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success(())) {
            store.completeInsertion()
        }
    }
    
    func test_saveImageData_doesNotDeliversResultAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedImageDataStoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        
        var receivedResults = [LocalFeedImageDataLoader.SaveResult]()
        sut?.save(anyData(), for: anyURL(), completion: { receivedResults.append($0) })
        sut = nil
        
        store.completeInsertion()
        
        XCTAssertTrue(receivedResults.isEmpty, "Expected got no result after instance has been deallocated, got \(receivedResults) instead")
    }
    
    // MARK: -- Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (LocalFeedImageDataLoader, FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
    
    private func failed() -> LocalFeedImageDataLoader.SaveResult {
        return .failure(LocalFeedImageDataLoader.SaveError.failed)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: LocalFeedImageDataLoader.SaveResult, when action: @escaping () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        sut.save(anyData(), for: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success(()), .success(())): break
            case let (.failure(receivedError as LocalFeedImageDataLoader.SaveError),
                      .failure(expectedError as LocalFeedImageDataLoader.SaveError) ):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default: XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
}
