//
//  SharedLocalizationTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 05/07/23.
//

import XCTest

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

func assertLocalizedKeyAndValuesExist(in presentationBundle: Bundle, _ table: String, file: StaticString = #filePath, line: UInt = #line) {
    let localizationBundles = allLocalizationBundles(in: presentationBundle, file: file, line: line)
    let localizationStringKeys = allLocalizedStringKeys(in: localizationBundles, table: table, file: file, line: line)
    
    localizationBundles.forEach { (bundle, localization) in
        localizationStringKeys.forEach { key in
            let localizedString = bundle.localizedString(forKey: key, value: nil, table: table)
            if localizedString == key {
                let language = Locale.current.localizedString(forLanguageCode: localization) ?? ""
                XCTFail("Missing \(language) (\(localization)) localized string for key: `\(key)`, in table: `\(table)`", file: file, line: line)
            }
        }
    }
}
