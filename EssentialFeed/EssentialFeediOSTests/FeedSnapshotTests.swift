//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Galih Samudra on 26/06/23.
//

import XCTest
import EssentialFeediOS

final class FeedSnapshotTests: XCTestCase {

    func test_emptyFeed() {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controlller = storyboard.instantiateInitialViewController() as! FeedViewController
        controlller.loadViewIfNeeded()
        
        controlller.display([])
        
        let snapshot = controlller.snapshot()
        record(snapshot: snapshot, named: "EMPTY_FEED")
    }
    
    // MARK: Helpers
    private func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representataion from snapshot", file: file, line: line)
            return
        }
        let snapshotURL = URL(filePath: String(describing: file))
            .deletingLastPathComponent()
            .appending(path: "snapshots")
            .appending(path: "\(name).png")
        
        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true)
            try snapshotData.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
        
    }
}

extension UIViewController {
    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { action in
            view.layer.render(in: action.cgContext )
        }
    }
}
