//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 16/06/23.
//

import EssentialFeed

final class FeedImageDataStoreSpy: FeedImageDataStore {
    enum Message: Equatable {
        case retrieve(dataFor: URL)
        case insert(data: Data, for: URL)
    }
    
    private var completions = [(FeedImageDataStore.RetrievalResult) -> Void]()
    private(set) var receivedMessages = [Message]()
    
    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        receivedMessages.append( .retrieve(dataFor: url) )
        completions.append(completion)
    }
     
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        receivedMessages.append(.insert(data: data, for: url))
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        completions[index](.failure(error))
    }
    
    func completeRetrieval(with data: Data?, at index: Int = 0) {
        completions[index](.success(data))
    }
    
}
