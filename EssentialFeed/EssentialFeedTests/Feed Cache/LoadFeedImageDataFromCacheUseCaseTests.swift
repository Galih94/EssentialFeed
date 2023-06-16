//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 16/06/23.
//

import XCTest
import EssentialFeed

final class LoadFeedImageDataFromCacheUseCaseTests: XCTestCase {

    func test_init_doesOtMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty, "Expected no receivedMessages on initialization")
    }
    
    func test_loadImageData_requestsStoredDataForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve(dataFor: url)])
    }
    
    func test_loadImageData_failOnStoreError() {
        let (sut, store) = makeSUT()
        expect(sut, toCompleteWith: failed()) {
            let retrievalError = anyNSError()
            store.completeRetrieval(with: retrievalError)
        }
    }
    
    func test_loadImageData_deliversNotFoundErrorOnNotFound() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: notFound()) {
            store.completeRetrieval(with: .none)
        }
    }
    
    func test_loadImageData_deliversStoredDataOnFoundData() {
        let (sut, store) = makeSUT()
        let foundData = anyData()
        
        expect(sut, toCompleteWith: .success(foundData)) {
            store.completeRetrieval(with: foundData)
        }
    }
    
    func test_loadImageData_doesNotDeliversResultAfterCancellingTask() {
        let (sut, store) = makeSUT()
        
        var receivedResults = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL(), completion: { result in
            receivedResults.append(result)
        })
        
        task.cancel()
        
        store.completeRetrieval(with: .none)
        store.completeRetrieval(with: anyData())
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty, "Expected no received results after cancelling task got \(receivedResults) intead")
    }
    
    func test_loadImageData_doesNotDeliversResultAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedImageDataStoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        
        var receivedResults = [FeedImageDataLoader.Result]()
        _ = sut?.loadImageData(from: anyURL(), completion: { result in
            receivedResults.append(result)
        })
        sut = nil
        store.completeRetrieval(with: anyData())
        
        XCTAssertTrue(receivedResults.isEmpty, "Expected no received results after instance has been deallocated")
    }
    
    func test_saveImageData_requestsImageDataInsertionForURL() {
        let (sut, store) = makeSUT()
        let data = anyData()
        let url = anyURL()
        
        sut.save(data, for: url) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.insert(data: data, for: url)])
    }
    
    // MARK: Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (LocalFeedImageDataLoader, FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
    
    private func failed() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.LoadError.failed)
    }
    
    private func notFound() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.LoadError.notFound)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let url = anyURL()
        let exp = expectation(description: "Wait for completion")
        _ = sut.loadImageData(from: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            case let (.failure(receivedError as LocalFeedImageDataLoader.LoadError ),
                      .failure(expectedError as LocalFeedImageDataLoader.LoadError)):
                XCTAssertEqual(receivedError, expectedError)
                break
                
            default: XCTFail("Expected result \(expectedResult) got result \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
}
