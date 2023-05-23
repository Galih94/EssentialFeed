//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 15/05/23.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    enum ReceivedMessage: Equatable {
        case deleteCacheFeed
        case insert([LocalFeedImage], Date)
        case retrieve
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    private var deletionCompletion = [DeletionCompletion]()
    private var insertionCompletion = [InsertionCompletion]()
    private var retrievalCompletion = [RetrievalCompletion]()
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletion.append(completion)
        receivedMessages.append(.deleteCacheFeed)
    }
    
    public func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletion[index](.failure(error))
    }
    
    public func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletion[index](.success(()))
    }
    
    public func insert(_ feed: [EssentialFeed.LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletion.append(completion)
        receivedMessages.append(.insert(feed, timeStamp))
    }
    
    public func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletion[index](.failure(error))
    }
    
    public func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletion[index](.success(()))
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalCompletion.append(completion)
        receivedMessages.append(.retrieve)
    }
    
    public func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletion[index](.failure(error))
    }
    
    public func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalCompletion[index](.success(.none))
    }
    
    public func completeRetrieval(with feed: [LocalFeedImage], timeStamp: Date, at index: Int = 0) {
        retrievalCompletion[index](.success(CachedFeed(feed: feed, timeStamp: timeStamp)))
    }
}
