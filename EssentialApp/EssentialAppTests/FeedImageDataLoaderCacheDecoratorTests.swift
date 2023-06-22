//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Galih Samudra on 22/06/23.
//

import XCTest
import EssentialFeed

final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    
    private let decoratee: FeedImageDataLoader
    
    init(decoratee: FeedImageDataLoader) {
        self.decoratee = decoratee
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
        return decoratee.loadImageData(from: url, completion: completion)
    }
    
    
}

final class FeedImageDataLoaderCacheDecoratorTests: XCTestCase {
    func test_init_doesNotLoadImageData() {
        let ( _, loader) = makeSUT()
        
        XCTAssertTrue(loader.messages.isEmpty, "Expected not send messages on init")
    }
    
    func test_loadImageData_deliversDataOnLoaderSuccess() {
        let ( sut, loader) = makeSUT()
        let data = anyData()
        
        let exp = expectation(description: "Waiting for completion")
        _ = sut.loadImageData(from: anyURL(), completion: { receivedResult in
            switch receivedResult {
            case let .success(receivedData):
                XCTAssertEqual(receivedData, data)
            default: XCTFail("Expected success got \(receivedResult) instead")
            }
            exp.fulfill()
        })
        loader.complete(with: data)
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadImageData_deliversErrorOnLoadDataFailure() {
        let ( sut, loader) = makeSUT()
        
        let exp = expectation(description: "Waiting for completion")
        _ = sut.loadImageData(from: anyURL(), completion: { receivedResult in
            switch receivedResult {
            case .failure: break
            default: XCTFail("Expected failure got \(receivedResult) instead")
            }
            exp.fulfill()
        })
        loader.complete(with: anyNSError())
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: Helper
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (FeedImageDataLoaderCacheDecorator, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }
    
    private final class LoaderSpy: FeedImageDataLoader {
        private struct Task: EssentialFeed.FeedImageDataLoaderTask {
            func cancel() {}
        }
        private(set) var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
            messages.append((url, completion))
            return Task()
        }
        
        func complete(with data: Data, at index: Int = 0) {
            messages[index].completion(.success(data))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
    }
}
