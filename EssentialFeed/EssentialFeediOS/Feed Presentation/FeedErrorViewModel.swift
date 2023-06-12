//
//  FeedErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by Galih Samudra on 12/06/23.
//

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
