//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Galih Samudra on 22/06/23.
//

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>
    func save(_ feed : [FeedImage], completion: @escaping (Result) -> Void)
}
