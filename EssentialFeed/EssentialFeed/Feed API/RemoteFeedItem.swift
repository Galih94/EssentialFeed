//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Galih Samudra on 15/05/23.
//

import Foundation

internal struct RemoteFeedItem: Decodable { // make internal representation from FeedItem so it can map into FeedItem without changing FeedItem Implementation
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}

