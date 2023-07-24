//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Galih Samudra on 16/06/23.
//

public final class LocalFeedImageDataLoader {
    
    private let store: FeedImageDataStore
    public init(store: FeedImageDataStore) {
        self.store = store
    }
}

extension LocalFeedImageDataLoader: FeedImageDataCache {
    public enum SaveError: Error {
        case failed
    }
    
    public func save(_ data: Data, for url: URL) throws {
        do {
            try store.insert(data, for: url)
        } catch {
            throw SaveError.failed
        }
    }
    
//    public func save(_ data: Data,for url: URL, completion: @escaping (SaveResult) -> Void) {
//        completion(SaveResult{
//            return try store.insert(data, for: url)
//        }.mapError{ _ in SaveError.failed })
//    }
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {
    private final class LoadImageDataTask: FeedImageDataLoaderTask {
        
        private var completion: ((FeedImageDataLoader.Result) -> Void )?
        
        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletion()
        }
        
        private func preventFurtherCompletion() {
            completion = nil
        }
    }
    
    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        let task = LoadImageDataTask(completion)
        task.complete(with: Swift.Result{
            try store.retrieve(dataForURL: url)
        }.mapError{ _ in
            LoadError.failed
        }.flatMap{ data in
            data.map { .success($0)} ?? .failure(LoadError.notFound)
        })
        return task
    }
}
