//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Galih Samudra on 18/05/23.
//

import Foundation

public final class CodableFeedStore: FeedStore {
    
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timeStamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map {
                $0.local
            }
        }
    }
    
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        public var local: LocalFeedImage {
            return LocalFeedImage(id: id,
                                  description: description,
                                  location: location,
                                  url: url)
        }
        
        public init(_ image: LocalFeedImage) {
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.url = image.url
        }
    }
    
    private let storeURL: URL
    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func insert(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
        let storeURL = self.storeURL
        /// put flags `barier` so insert that has concurrency will let thread know that it has a flow that has side effect and let other flow not run before insert ends
        queue.async(flags: .barrier) {
            do {
                let codableFeed = feed.map(CodableFeedImage.init)
                let cache = Cache(feed: codableFeed, timeStamp: timeStamp)
                let encoder = JSONEncoder()
                let encoded = try encoder.encode(cache)
                try encoded.write(to: storeURL)
                
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        
        let storeURL = self.storeURL
        /// because retrieve has no side-effects it is safe to run concurrently
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.empty)
            }
            do {
                let decode = JSONDecoder()
                let cache = try decode.decode(Cache.self, from: data)
                completion(.found(feed: cache.localFeed, timeStamp: cache.timeStamp))
            } catch {
                completion(.failure(error))
            }
            
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
        let storeURL = self.storeURL
        /// put flags `barier` so delete that has concurrency will let thread know that it has a flow that has side effect and let other flow not run before delete ends
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path()) else {
                return completion(nil)
            }
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
        
    }
    
}
