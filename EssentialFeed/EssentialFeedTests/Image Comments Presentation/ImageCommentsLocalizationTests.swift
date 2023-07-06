//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 06/07/23.
//

import XCTest
import EssentialFeed

final class ImageCommentsLocalizationTests: XCTestCase {

    func test_localizedStrings_haveKeysAndValuesForAkkSupportedLocalizations() {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }
}
