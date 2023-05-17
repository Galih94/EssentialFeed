//
//  LocalFeedItem.swift
//  EssentialFeed
//
//  Created by Galih Samudra on 15/05/23.
//

import Foundation

// Local representation of FeedItem in Feed Store
public struct LocalFeedImage: Equatable, Codable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL
    
    public init(id: UUID, description: String?, location: String?, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
}
