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
    
    private var retrievalResult: FeedImageDataStore.RetrievalResult?
    private var insertionResult: Result<Void,Error>?
    private(set) var receivedMessages = [Message]()
    
    func retrieve(dataForURL url: URL) throws -> Data? {
        receivedMessages.append( .retrieve(dataFor: url) )
        return try retrievalResult?.get()
    }
    
    func insert(_ data: Data, for url: URL) throws {
        receivedMessages.append(.insert(data: data, for: url))
        try insertionResult?.get()
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalResult = .failure(error)
    }
    
    func completeRetrieval(with data: Data?, at index: Int = 0) {
        retrievalResult = .success(data)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionResult = .failure(error)
    }
    
    func completeInsertion(at index: Int = 0) {
        insertionResult = .success(())
    }
}
