//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Galih Samodra Wicaksono on 04/05/23.
//

import Foundation

protocol HTTPClient {
    func get(from url: URL)
}

class RemoteFeedLoader {
    let client: HTTPClient
    let url: URL
    init (url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    func load() {
        client.get(from: url)
    }
}
