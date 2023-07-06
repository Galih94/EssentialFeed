//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Galih Samudra on 13/06/23.
//

public struct FeedImageViewModel {
    public let description: String?
    public let location: String?
    
    public var hasLocation: Bool {
        return location != nil
    }
}
