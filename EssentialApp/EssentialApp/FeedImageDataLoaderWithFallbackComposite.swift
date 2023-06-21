//
//  FeedImageDataLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Galih Samudra on 21/06/23.
//

import EssentialFeed

public final class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    public final class TaskWrapper: FeedImageDataLoaderTask {
        var wrapper: FeedImageDataLoaderTask?
        public func cancel() {
            wrapper?.cancel()
        }
    }
    
    private let primaryLoader: FeedImageDataLoader
    private let fallbackLoader: FeedImageDataLoader
    
    public init(primaryLoader: FeedImageDataLoader, fallbackLoader: FeedImageDataLoader) {
        self.primaryLoader = primaryLoader
        self.fallbackLoader = fallbackLoader
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
        let task = TaskWrapper()
        task.wrapper = primaryLoader.loadImageData(from: url, completion: { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                task.wrapper = self?.fallbackLoader.loadImageData(from: url, completion: completion)
            }
        })
        return task
    }
    
    
}
