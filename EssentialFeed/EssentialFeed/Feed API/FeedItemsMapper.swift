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
        let items: [RemoteFeedItem]
    }
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard let root = try? JSONDecoder().decode(Root.self, from: data),
                response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
}
