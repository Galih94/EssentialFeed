//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Galih Samudra on 22/06/23.
//

public protocol FeedImageDataCache {
    func save(_ data: Data,for url: URL) throws
}
