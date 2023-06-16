//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 16/06/23.
//

import XCTest
import EssentialFeed

protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}

final class LocalFeedImageDataLoader: FeedImageDataLoader {
    private struct Task: FeedImageDataLoaderTask {
        func cancel() {}
    }
    
    public enum Error: Swift.Error {
        case failed
    }
    
    private let store: FeedImageDataStore
    init(store: FeedImageDataStore) {
        self.store = store
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        store.retrieve(dataForURL: url) { result in
            completion(.failure(Error.failed))
        }
        return Task()
    }
}

final class LocalFeedImageDataLoaderTests: XCTestCase {

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
        let url = anyURL()
        let expectedError = LocalFeedImageDataLoader.Error.failed
        
        let exp = expectation(description: "Wait for completion")
        _ = sut.loadImageData(from: url) { result in
            switch result {
            case let .failure(error):
                XCTAssertEqual(error as? LocalFeedImageDataLoader.Error, expectedError)
            default: XCTFail()
            }
            exp.fulfill()
        }
        store.complete(with: expectedError)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (LocalFeedImageDataLoader, StoreSpy) {
        let store = StoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
    
    private class StoreSpy: FeedImageDataStore {
        enum Message: Equatable {
            case retrieve(dataFor: URL)
        }
        
        private var completions = [(FeedImageDataStore.Result) -> Void]()
        private(set) var receivedMessages = [Message]()
        
        func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.Result) -> Void) {
            receivedMessages.append( .retrieve(dataFor: url) )
            completions.append(completion)
        }
        
        func complete(with error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }
        
    }
}
