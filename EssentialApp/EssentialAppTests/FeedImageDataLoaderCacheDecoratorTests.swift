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
        
        expect(sut, toCompleteWith: .success(data)) {
            loader.complete(with: data)
        }
    }
    
    func test_loadImageData_deliversErrorOnLoadDataFailure() {
        let ( sut, loader) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(anyNSError())) {
            loader.complete(with: anyNSError())
        }
    }
    
    func test_cancelLoadImageData_cancelsLoaderTask() {
        let ( sut, loader) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(loader.cancelledURLs, [url], "Expected to cancel URL loading from loader")
    }
    
    func test_loadImageData_loadsFromLoader() {
        let ( sut, loader) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        
        XCTAssertEqual(loader.loadedURLs, [url], "Expected to load URL from loader")
    }
    
    // MARK: Helper
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (FeedImageDataLoaderCacheDecorator, FeedImageDataLoaderSpy) {
        let loader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }
    
    private func expect(_ sut: FeedImageDataLoaderCacheDecorator, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line ) {
        let exp = expectation(description: "Waiting for completion")
        _ = sut.loadImageData(from: anyURL(), completion: { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData)
            case (.failure, .failure): break
            default: XCTFail("Expected \(expectedResult) got \(receivedResult) instead")
            }
            exp.fulfill()
        })
        action()
        wait(for: [exp], timeout: 1.0)
    }
}
