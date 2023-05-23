//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Galih Samudra on 15/05/23.
//

import Foundation

struct RemoteFeedItem: Decodable { // make internal representation from FeedItem so it can map into FeedItem without changing FeedItem Implementation
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}

