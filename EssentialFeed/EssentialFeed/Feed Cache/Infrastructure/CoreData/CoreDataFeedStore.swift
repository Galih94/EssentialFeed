//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Galih Samudra on 19/05/23.
//

import Foundation
import CoreData

public final class CoreDataFeedStore: FeedStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func insert(_ feed: [EssentialFeed.LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timeStamp = timeStamp
                managedCache.feed = ManagedFeedImage.image(from: feed, in: context)
                
                try context.save()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            do {
                try ManagedCache.find(in: context).map( context.delete(_:) ).map( context.save )
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            completion(Result(catching: {
                try ManagedCache.find(in: context).map {
                    let feed = $0.localFeed
                    let timeStamp = $0.timeStamp
                    return (CachedFeed(feed: feed, timeStamp: timeStamp))
                }
            }))
        }
    }
    
    // MARK: Helpers
    
    private func perform(action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform {
            action(context)
        }
    }
    
}
