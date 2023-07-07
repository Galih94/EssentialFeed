//
//  ListSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Galih Samudra on 07/07/23.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

final class ListSnapshotTests: XCTestCase {

    func test_emptyList() {
        let sut = makeSUT()
        sut.display(emptyList())
        
        assert(snapshot: sut.snapshot(for: .iPhone14Pro(style: .light)), named: "EMPTY_LIST_light")
        assert(snapshot: sut.snapshot(for: .iPhone14Pro(style: .dark)), named: "EMPTY_LIST_dark")
    }

    // MARK: Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controlller = storyboard.instantiateInitialViewController() as! ListViewController
        controlller.loadViewIfNeeded()
        controlller.tableView.showsVerticalScrollIndicator = false
        controlller.tableView.showsHorizontalScrollIndicator = false
        
        trackForMemoryLeaks(controlller, file: file, line: line)
        
        return controlller
    }
    
    private func emptyList() -> [CellController] {
        return []
    }
}
