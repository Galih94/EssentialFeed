//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Galih Samodra Wicaksono on 08/05/23.
//

import Foundation

final class FeedItemsMapper {
    
    private struct Root: Decodable {
        private let items: [RemoteFeedItem]
        
        private struct RemoteFeedItem: Decodable { // make internal representation from FeedItem so it can map into FeedItem without changing FeedItem Implementation
            let id: UUID
            let description: String?
            let location: String?
            let image: URL
        }

        
        var images: [FeedImage] {
            return items.map {
                FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image)
            }
        }
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [FeedImage] {
        guard let root = try? JSONDecoder().decode(Root.self, from: data),
              response.isOK else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.images
    }
}
