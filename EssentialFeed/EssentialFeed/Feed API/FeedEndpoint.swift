//
//  FeedEndpoint.swift
//  EssentialFeed
//
//  Created by Galih Samudra on 19/07/23.
//

public enum FeedEndpoint {
    case get
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case .get: return baseURL.appending(path: "/v1/feed")
        }
    }
}
