//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 06/07/23.
//

import XCTest
import EssentialFeed

final class ImageCommentsPresenterTests: XCTestCase {
    
    func test_title_isLocalized() {
        XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
    }
    
    func test_map_createsViewModel() {
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")
        let comments = [
            ImageComment(
                id: UUID(),
                message: "a massage",
                createdAt: now.adding(minutes: -5, calendar: calendar),
                username: "a username"),
            ImageComment(
                id: UUID(),
                message: "another massage",
                createdAt: now.adding(days: -1, calendar: calendar),
                username: "another username")
        ]
        let viewModel = ImageCommentsPresenter.map(
            comments,
            currentDate: now,
            calendar: calendar,
            locale: locale
        )
        XCTAssertEqual(viewModel.comments, [
            ImageCommentViewModel(
                messsage: "a massage",
                date: "5 minutes ago",
                username: "a username"),
            ImageCommentViewModel(
                messsage: "another massage",
                date: "1 day ago",
                username: "another username")
        ])
    }
    
    // MARK: -- Helpers
    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }

}
