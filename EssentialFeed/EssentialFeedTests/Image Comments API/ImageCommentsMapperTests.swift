//
//  LoadImageCommentFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 03/07/23.
//

import XCTest
import EssentialFeed

final class ImageCommentsMapperTests: XCTestCase {
    func test_map_throwsErrorOnNon2xxHTTPResponse() throws {
        let samples = [150, 199, 300, 400, 500]
        let json = makeItemsJSON(items: [])
        
        try samples.forEach { code in
            let response = HTTPURLResponse(statusCode: code)
            XCTAssertThrowsError(try ImageCommentsMapper.map(json, from: response))
        }
    }
    
    func test_map_throwsErrorOn2xxHTTPResponseWithInvalidJSON() throws {
        let samples = [200, 201, 250, 280, 299]
        let invalidJSON = Data("invalid json".utf8)

        try samples.forEach { code in
            let response = HTTPURLResponse(statusCode: code)
            XCTAssertThrowsError(try ImageCommentsMapper.map(invalidJSON, from: response))
        }
    }
    
    func test_map_deliversNoItemsOn2xxHTTPResponseWithEmptyJSONList() throws {
        let samples = [200, 201, 250, 280, 299]
        let emptyListJSON = makeItemsJSON(items: [])
         
        try samples.forEach { code in
            let response = HTTPURLResponse(statusCode: code)
            let result = try ImageCommentsMapper.map(emptyListJSON, from: response)
            XCTAssertEqual(result, [])
        }
    }

    func test_map_deliversItemsOn2xxHTTPResponseWithJSONItems() throws {
        let item1 = makeItem(
            id: UUID(),
            message: "a message",
            createdAt: (date: Date(timeIntervalSince1970: 1598627222), iso8601String: "2020-08-28T15:07:02+00:00"),
            username: "a username")
        
        let item2 = makeItem(
            id: UUID(),
            message: "another message",
            createdAt: (date: Date(timeIntervalSince1970: 1598627222), iso8601String: "2020-08-28T15:07:02+00:00"),
            username: "another username")
        
        let json = makeItemsJSON(items: [item1.json, item2.json])
        let samples = [200, 201,  250, 280, 299]
        
        try samples.forEach { code in
            let response = HTTPURLResponse(statusCode: code)
            let result = try ImageCommentsMapper.map(json, from: response)
            XCTAssertEqual(result, [item1.model, item2.model])
        }
    }
    
    // MARK: - Helpers
    
    private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), username: String) -> (model: ImageComment, json: [String: Any]) {
        let item = ImageComment(
            id: id,
            message: message,
            createdAt: createdAt.date,
            username: username)
        let json: [String: Any] = [
            "id": id.uuidString,
            "message": message,
            "created_at": createdAt.iso8601String,
            "author": [ "username": username ]
        ]
        return (item, json)
    }
}
