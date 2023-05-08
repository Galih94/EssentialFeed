//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Galih Samodra Wicaksono on 08/05/23.
//

import Foundation

internal final class FeedItemsMapper {
    
    private static var OK_200: Int { return 200 }
    private struct Root: Decodable {
        let items: [Item]
        
        var feed: [FeedItem] {
            return items.map({ $0.item })
        }
    }

    private struct Item: Decodable { // make internal representation from FeedItem so it can map into FeedItem without changing FeedItem Implementation
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            return FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard let root = try? JSONDecoder().decode(Root.self, from: data),
                response.statusCode == OK_200 else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        return .success(root.feed)
    }
}
