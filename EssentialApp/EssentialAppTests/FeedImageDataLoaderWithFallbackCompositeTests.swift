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
        return Task()
    }
    
    
}

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    func test_init_doesNotLoadImageData() {
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        _ = FeedImageDataLoaderWithFallbackComposite(primaryLoader: primaryLoader, fallbackLoader: fallbackLoader)
        
        XCTAssertTrue(primaryLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }
    
    // MARK: Helpers
    
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
    }
    
}
