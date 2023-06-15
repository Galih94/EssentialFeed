//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 15/06/23.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int {
        return 200
    }
        
    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
