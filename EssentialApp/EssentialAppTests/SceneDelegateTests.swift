//
//  SceneDelegateTests.swift
//  EssentialAppTests
//
//  Created by Galih Samudra on 24/06/23.
//

import XCTest
import EssentialFeediOS
@testable import EssentialApp

final class SceneDelegateTests: XCTestCase {
    func test_configureWindow_setsWindowAsKeyAndVisible() {
        let window = UIWindowSpy()
        let sut = SceneDelegate()
        sut.window = window
        
        sut.configureWindow()
        
        XCTAssertEqual(window.makeKeyAndVisibleCallCount, 1, "Expected window to be the key window")
        XCTAssertFalse(window.isHidden, "Expected window to be visible")
    }
    
    func test_configureWindow_configureRootsViewController() {
        let sut = SceneDelegate()
        sut.window = UIWindow()
        
        sut.configureWindow()
         
        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topController = rootNavigation?.topViewController
        
        XCTAssertNotNil(rootNavigation, "Expected a navigation controller as root, got \(String(describing: root)) instead")
        XCTAssertTrue(topController is ListViewController, "Expected a feed view controller as top view controller, got \(String(describing: topController)) instead")
    }

    // MARK: Helpers
    private class UIWindowSpy: UIWindow {
        var makeKeyAndVisibleCallCount = 0
        override func makeKeyAndVisible() {
            super.makeKeyAndVisible()
            makeKeyAndVisibleCallCount = 1
        }
    }
    
}
