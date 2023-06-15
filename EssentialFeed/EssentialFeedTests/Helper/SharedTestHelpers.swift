//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 16/05/23.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error domain", code: 1)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    return Data("any data".utf8)
}
