//
//  ImageCommentsEndpoint.swift
//  EssentialFeed
//
//  Created by Galih Samudra on 11/07/23.
//

public enum ImageCommentsEndpoint {
    case get(UUID)
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case let .get(id):
            return baseURL.appending(path: "/v1/image/\(id)/comments")
        }
    }
}
