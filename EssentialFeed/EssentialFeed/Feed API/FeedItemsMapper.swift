//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Galih Samodra Wicaksono on 08/05/23.
//

import Foundation

final class FeedItemsMapper {
    
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard let root = try? JSONDecoder().decode(Root.self, from: data),
              response.isOK else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
}
