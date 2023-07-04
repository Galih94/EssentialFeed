//
//  FeedImageDataMapper.swift
//  EssentialFeed
//
//  Created by Galih Samudra on 04/07/23.
//

public final class FeedImageDataMapper {
    public enum Error: Swift.Error {
        case invalidData
    }
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> Data {
        guard response.isOK, !data.isEmpty else {
            throw Error.invalidData
        }
        return data
    }
}
