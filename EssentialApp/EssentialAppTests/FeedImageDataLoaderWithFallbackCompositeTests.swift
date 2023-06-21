//
//  FeedImageDataLoaderWithFallbackComposite.swift
//  EssentialAppTests
//
//  Created by Galih Samudra on 21/06/23.
//

import XCTest
import EssentialFeed

final class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    final class Task: EssentialFeed.FeedImageDataLoaderTask {
        func cancel() {}
    }
    
    private let primaryLoader: FeedImageDataLoader
    private let fallbackLoader: FeedImageDataLoader
    
    init(primaryLoader: FeedImageDataLoader, fallbackLoader: FeedImageDataLoader) {
        self.primaryLoader = primaryLoader
        self.fallbackLoader = fallbackLoader
    }
    
    
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
        _ = primaryLoader.loadImageData(from: url, completion: { [weak self] result in
            switch result {
            case .success: break
            case .failure:
                _ = self?.fallbackLoader.loadImageData(from: url, completion: { _ in })
            }
        })
        return Task()
    }
    
    
}

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    func test_init_doesNotLoadImageData() {
        let (_, primaryLoader, fallbackLoader) = makeSUT()
        
        XCTAssertTrue(primaryLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }
    
    func test_loadImageData_loadsFromPrimaryLoaderFirst() {
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        _ = sut.loadImageData(from: url, completion: { _ in })
        
        XCTAssertEqual(primaryLoader.loadedURLs, [url],  "Expected loaded URLs in the primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty,  "Expected no loaded URLs in the fallback loader")
    }
    
    func test_loadImageData_loadsFromFallbackOnPrimaryLoaderFailure() {
        let url = anyURL()
        
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        _ = sut.loadImageData(from: url, completion: { _ in })
        primaryLoader.complete(with: anyNSError())
        
        XCTAssertEqual(primaryLoader.loadedURLs, [url],  "Expected loaded URLs in the primary loader")
        XCTAssertEqual(fallbackLoader.loadedURLs, [url],  "Expected loaded URLs in the fallback loader")
    }
    
    // MARK: Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (FeedImageDataLoaderWithFallbackComposite, LoaderSpy, LoaderSpy ) {
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        let sut = FeedImageDataLoaderWithFallbackComposite(primaryLoader: primaryLoader, fallbackLoader: fallbackLoader)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        return (sut, primaryLoader, fallbackLoader)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been dealocated, potential memory leak", file: file, line: line)
        }
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://a-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error domain", code: 0)
    }
    
    private class LoaderSpy: FeedImageDataLoader {
        private var message = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        var loadedURLs: [URL] {
            return message.map{$0.url}
        }
        
        private struct Task: FeedImageDataLoaderTask {
            func cancel() {}
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
            message.append((url, completion))
            return Task()
        }
        
        func complete(with error: Error, at index: Int = 0) {
            message[index].completion(.failure(error))
        }
    }
    
}
