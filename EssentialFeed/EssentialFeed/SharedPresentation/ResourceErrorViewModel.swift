//
//  ResourceErrorViewModel.swift
//  EssentialFeed
//
//  Created by Galih Samudra on 13/06/23.
//

public struct ResourceErrorViewModel {
    public let message: String?
    
    static var noError: ResourceErrorViewModel {
        return ResourceErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> ResourceErrorViewModel {
        return ResourceErrorViewModel(message: message)
    }
}
