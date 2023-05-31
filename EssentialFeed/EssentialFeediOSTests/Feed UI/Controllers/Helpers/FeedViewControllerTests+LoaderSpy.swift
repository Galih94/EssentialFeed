//
//  FeedViewControllerTests+LoaderSpy.swift
//  EssentialFeediOSTests
//
//  Created by Galih Samudra on 31/05/23.
//

import EssentialFeed
import EssentialFeediOS

extension FeedViewControllerTests {
    
    class LoaderSpy: FeedLoader, FeedImageLoader {
        // MARK: -- FeedLoader
        private var feedRequests = [(FeedLoader.Result) -> ()]()
        var loadFeedCallCount: Int {
            return feedRequests.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedRequests.append(completion)
        }
        
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            feedRequests[index](.success(feed))
        }
        
        func completeFeedLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "any domain", code: 1)
            feedRequests[index](.failure(error))
        }
        
        // MARK: -- FeedImageLoader
        
        private struct TaskSpy: FeedImageLoaderTask {
            let cancelCallback: () -> Void
            func cancel() {
                cancelCallback()
            }
        }
        
        var loadedImageURLs: [URL] {
            return imageRequests.map{ $0.url }
        }
        
        private var imageRequests = [(url: URL, completion: (FeedImageLoader.Result) -> Void)]()
        private(set) var cancelledImageURLs = [URL]()
        
        func loadImageData(from url: URL, completion: @escaping(FeedImageLoader.Result) -> Void) -> FeedImageLoaderTask {
            
            imageRequests.append((url, completion))
            return TaskSpy { [weak self] in
                self?.cancelledImageURLs.append(url)
            }
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].completion(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "any domain", code: 1)
            imageRequests[index].completion(.failure(error))
        }
        
    }
    
}
