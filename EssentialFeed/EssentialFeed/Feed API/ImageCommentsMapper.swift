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
              isOK(response) else {
            throw RemoteImageCommentsLoader.Error.invalidData
        }
        
        return root.items
    }
    
    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        return (200...299).contains(response.statusCode)
    }
}
