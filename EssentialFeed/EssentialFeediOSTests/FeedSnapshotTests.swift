//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Galih Samudra on 26/06/23.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

final class FeedSnapshotTests: XCTestCase {

    func test_emptyFeed() {
        let sut = makeSUT()
        sut.display(emptyFeed())
        
        assert(snapshot: sut.snapshot(), named: "EMPTY_FEED")
    }
    
    func test_feedWithContent() {
        let sut = makeSUT()
        
        sut.display(feedWithContent())
        
        assert(snapshot: sut.snapshot(), named: "FEED_WITH_CONTENT")
    }
    
    func test_feedWithErrorMessage() {
        let sut = makeSUT()
        
        sut.display(.error(message: "This is a\nmulti line\nerror message"))
        
        assert(snapshot: sut.snapshot(), named: "FEED_WITH_ERROR_MESSAGE")
    }
    
    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()
        
        sut.display(feedWithFailedImageLoading())
        
        assert(snapshot: sut.snapshot(), named: "FEED_WITH_FAILED_IMAGE_LOADING")
    }
    
    // MARK: Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controlller = storyboard.instantiateInitialViewController() as! FeedViewController
        controlller.loadViewIfNeeded()
        
        trackForMemoryLeaks(controlller, file: file, line: line)
        
        return controlller
    }
    
    private func emptyFeed() -> [FeedImageCellController] {
        return []
    }
    
    private func feedWithContent() -> [ImageStub]  {
        return [
            ImageStub(
                description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                location: "East Side Gallery\nMemorial in Berlin, Germany",
                image: UIImage.make(withColor: .red)),
            ImageStub(
                description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                location: "Gerth Pier",
                image: UIImage.make(withColor: .green))
        ]
    }
    
    private func feedWithFailedImageLoading() -> [ImageStub]  {
        return [
            ImageStub(
                description: nil,
                location: "Cannon Street, London",
                image: nil),
            ImageStub(
                description: nil,
                location: "Brighton Seafront",
                image: nil)
        ]
    }

    private func assert(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        let snapshotData = makeSnapshotData(snapshot: snapshot)
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        
        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use the `record` method to store a snapshot before asserting", file: file, line: line)
            return
        }
        
        if snapshotData != storedSnapshotData {
            
            let temporarySnapshotURL = URL(filePath: NSTemporaryDirectory() ,directoryHint: .isDirectory).appending(path: snapshotURL.lastPathComponent)
            try? snapshotData?.write(to: temporarySnapshotURL)
            XCTFail("New snapshot does not match stored snapshot, New snapshot URL: \(temporarySnapshotURL), stored snapshot URL: \(snapshotURL)", file: file, line: line)
        }
    }
    
    private func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        let snapshotData = snapshot.pngData()
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        
        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true)
            try snapshotData?.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
        
    }
    
    private func makeSnapshotURL(named name: String, file: StaticString = #file) -> URL {
        return URL(filePath: String(describing: file))
            .deletingLastPathComponent()
            .appending(path: "snapshots")
            .appending(path: "\(name).png")
    }
    
    private func makeSnapshotData(snapshot: UIImage, file: StaticString = #file, line: UInt = #line) -> Data? {
        guard let data = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representataion from snapshot", file: file, line: line)
            return nil
        }
        return data
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

private extension FeedViewController {
    func display(_ stubs: [ImageStub]) {
        let cells: [FeedImageCellController] = stubs.map { stub in
            let cellController = FeedImageCellController(delegate: stub)
            stub.controller = cellController
            return cellController
        }
        display(cells)
    }
}

private class ImageStub: FeedImageCellControllerDelegate {
    weak var controller: FeedImageCellController?
    let viewModel: FeedImageViewModel<UIImage>
    
    init(description: String?, location: String?, image: UIImage?) {
        self.viewModel = FeedImageViewModel(
            description: description,
            location: location,
            image: image,
            isLoading: false,
            shouldRetry: image == nil)
    }
    func didRequestImage() {
        controller?.display(viewModel)
    }
    
    func didCancelImage() {}
}
