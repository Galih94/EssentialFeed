//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Galih Samudra on 21/06/23.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error domain", code: 0)
}

func anyURL() -> URL {
    return URL(string: "http://a-url.com")!
}

func anyData() -> Data {
    return Data("any data".utf8)
}

