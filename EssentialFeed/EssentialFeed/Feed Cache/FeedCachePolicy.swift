//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Galih Samudra on 16/05/23.
//

import Foundation

internal final class FeedCachePolicy { // moved business ruless from LocalFeedLoader so it can be re-used later
    private static  let calendar = Calendar(identifier: .gregorian)
    private static  var maxCacheAgeInDays: Int {
        return 7
    }
    private init() {}
    internal static func validate(_ timeStamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timeStamp) else { return false  }
        return date < maxCacheAge
    }
}

