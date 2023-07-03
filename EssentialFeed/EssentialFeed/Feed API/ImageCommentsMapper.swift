//
//  ImageCommentsMapper.swift
//  EssentialFeed
//
//  Created by Galih Samudra on 03/07/23.
//

import Foundation

final class ImageCommentsMapper {
    
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard let root = try? JSONDecoder().decode(Root.self, from: data),
              response.isOK else {
            throw RemoteImageCommentsLoader.Error.invalidData
        }
        
        return root.items
    }
}
