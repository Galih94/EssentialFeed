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

func makeItemsJSON(items: [[String: Any]]) -> Data {
    let itemsJSON = [
        "items": items
    ]
    
    return try! JSONSerialization.data(withJSONObject: itemsJSON)
}

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}

extension Date {
    public func adding(seconds: TimeInterval) -> Date {
        return  self + seconds
    }
    
    public func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return calendar.date(byAdding: .day, value: days, to: self)!
    }
    
    public func adding(minutes: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return  calendar.date(byAdding: .minute, value: minutes, to: self)!
    }
}
