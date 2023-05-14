//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Galih Samudra on 14/05/23.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func insert(_ items: [FeedItem], timeStamp: Date, completion: @escaping InsertionCompletion)
    func deleteCachedCompletion(completion: @escaping DeletionCompletion)
}
