//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Galih Samudra on 16/06/23.
//

public protocol FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws
    func retrieve(dataForURL url: URL) throws -> Data?
}
