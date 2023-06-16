//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Galih Samudra on 16/06/23.
//

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
