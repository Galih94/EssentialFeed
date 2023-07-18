//
//  FeedViewControllerTests+LoaderSpy.swift
//  EssentialFeediOSTests
//
//  Created by Galih Samudra on 31/05/23.
//

import EssentialFeed
import EssentialFeediOS
import Combine

extension FeedUIIntegrationTests {
    
    class LoaderSpy: FeedImageDataLoader {
        // MARK: -- FeedLoader
        private var feedRequests = [PassthroughSubject<Paginated<FeedImage>, Error>]()
        var loadFeedCallCount: Int {
            return feedRequests.count
        }
        
        private(set) var loadMoreCallCount: Int = 0
        
        public func loadPublisher() -> AnyPublisher<Paginated<FeedImage>, Error> {
            let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
            feedRequests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            feedRequests[index].send(Paginated(items: feed, loadMore: { [weak self] _ in
                self?.loadMoreCallCount += 1
            }))
        }
        
        func completeFeedLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "any domain", code: 1)
            feedRequests[index].send(completion: .failure(error))
        }
        
        // MARK: -- FeedImageLoader
        
        private struct TaskSpy: FeedImageDataLoaderTask {
            let cancelCallback: () -> Void
            func cancel() {
                cancelCallback()
            }
        }
        
        var loadedImageURLs: [URL] {
            return imageRequests.map{ $0.url }
        }
        
        private var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        private(set) var cancelledImageURLs = [URL]()
        
        func loadImageData(from url: URL, completion: @escaping(FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            
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
