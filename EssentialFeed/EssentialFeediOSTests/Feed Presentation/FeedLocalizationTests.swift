//
//  FeedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by Galih Samudra on 07/06/23.
//

import XCTest
import EssentialFeed

final class FeedLocalizationTests: XCTestCase {

    func test_localizedStrings_haveKeysAndValuesForAkkSupportedLocalizations() {
        let table = "Feed"
        let presentationBundle = Bundle(for: FeedPresenter.self)
        let localizationBundles = allLocalizationBundles(in: presentationBundle)
        let localizationStringKeys = allLocalizedStringKeys(in: localizationBundles, table: table)
        
        localizationBundles.forEach { (bundle, localization) in
            localizationStringKeys.forEach { key in
                let localizedString = bundle.localizedString(forKey: key, value: nil, table: table)
                if localizedString == key {
                    let language = Locale.current.localizedString(forLanguageCode: localization) ?? ""
                    XCTFail("Missing \(language) (\(localization)) localized string for key: `\(key)`, in table: `\(table)`")
                }
            }
        }
    }
    
    // MARK: -- Helpers
    private typealias LocalizedBundle = (bundle: Bundle, localization: String)
    
    private func allLocalizationBundles(in bundle: Bundle, file: StaticString = #filePath, line: UInt = #line) -> [LocalizedBundle] {
        return bundle.localizations.compactMap { localization in
            guard let path = bundle.path(forResource: localization, ofType: "lproj"),
                  let localizedBundle = Bundle(path: path) else {
                XCTFail("Could not find bundle for localization \(localization)", file: file, line: line)
                return nil
            }
            return (localizedBundle, localization)
        }
    }
    
    private func allLocalizedStringKeys(in bundle: [LocalizedBundle], table: String, file: StaticString = #filePath, line: UInt = #line) -> Set<String> {
        return bundle.reduce([]) { accumulation, current in
            guard let path = current.bundle.path(forResource: table, ofType: "strings"),
                  let strings = NSDictionary(contentsOfFile: path),
                  let keys = strings.allKeys as? [String] else {
                XCTFail("Could not find bundle for localization \(current.localization)", file: file, line: line)
                return accumulation
            }
            return accumulation.union(Set(keys))
        }
    }

}
