//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Galih Samodra Wicaksono on 04/05/23.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL)
}

public class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL
    public init (url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    public func load() {
        client.get(from: url)
    }
}
