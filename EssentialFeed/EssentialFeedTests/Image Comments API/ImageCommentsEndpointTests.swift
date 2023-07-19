//
//  ImageCommentsEndpointTests.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 19/07/23.
//

import XCTest
import EssentialFeed

final class ImageCommentsEndpointTests: XCTestCase {
    func test_imageComments_endpointURL() {
        let imageID = UUID(uuidString: "2239CBA2-CB35-4392-ADC0-24A37D38E010")!
        let baseURL = URL(string: "http://base-url.com")!
        
        let received = ImageCommentsEndpoint.get(imageID).url(baseURL: baseURL)
        XCTAssertEqual(received, URL(string: "http://base-url.com/v1/image/2239CBA2-CB35-4392-ADC0-24A37D38E010/comments")!)
    }
}
