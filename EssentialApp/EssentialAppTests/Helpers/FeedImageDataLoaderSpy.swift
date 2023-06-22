//
//  FeedImageDataLoaderSpy.swift
//  EssentialAppTests
//
//  Created by Galih Samudra on 22/06/23.
//

import EssentialFeed

final class FeedImageDataLoaderSpy: FeedImageDataLoader {
    private struct Task: FeedImageDataLoaderTask {
        let completion: () -> Void
        func cancel() {
            completion()
        }
    }
    private(set) var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
    private(set) var cancelledURLs = [URL]()
    var loadedURLs: [URL] {
        return messages.map { $0.url }
    }
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
        messages.append((url, completion))
        return Task { [weak self] in
            self?.cancelledURLs.append(url)
        }
    }
    
    func complete(with data: Data, at index: Int = 0) {
        messages[index].completion(.success(data))
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
}
