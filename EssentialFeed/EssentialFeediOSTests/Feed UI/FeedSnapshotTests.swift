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
    
    func test_feedWithContent() {
        let sut = makeSUT()
        
        sut.display(feedWithContent())
        
        assert(snapshot: sut.snapshot(for: .iPhone14Pro(style: .light)), named: "FEED_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone14Pro(style: .dark)), named: "FEED_WITH_CONTENT_dark")
        assert(snapshot: sut.snapshot(for: .iPhone14Pro(style: .light, contentSize: .extraExtraExtraLarge)), named: "FEED_WITH_CONTENT_light_extraExtraExtraLarge")
    }
    
    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()
        
        sut.display(feedWithFailedImageLoading())
        
        assert(snapshot: sut.snapshot(for: .iPhone14Pro(style: .light)), named: "FEED_WITH_FAILED_IMAGE_LOADING_light")
        assert(snapshot: sut.snapshot(for: .iPhone14Pro(style: .dark)), named: "FEED_WITH_FAILED_IMAGE_LOADING_dark")
    }

    func test_feedWithLoadMoreIndicator() {
        let sut = makeSUT()
        
        sut.display(feedWithLoadMoreIndicator())
        
        assert(snapshot: sut.snapshot(for: .iPhone14Pro(style: .light)), named: "FEED_WITH_LOAD_MORE_INDICATOR_light")
        assert(snapshot: sut.snapshot(for: .iPhone14Pro(style: .dark)), named: "FEED_WITH_LOAD_MORE_INDICATOR_dark")
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
    
    private func feedWithLoadMoreIndicator() -> [CellController] {
        let stub = feedWithContent().last!
        let cellController = FeedImageCellController(
            viewModel: stub.viewModel,
            delegate: stub,
            selection: { })
        stub.controller = cellController
        
        let loadMore = LoadMoreCellController()
        loadMore.display(ResourceLoadingViewModel(isLoading: true))
        return [
            CellController(id: UUID(), cellController),
            CellController(id: UUID(), loadMore)
        ]
    }
}

private extension ListViewController {
    func display(_ stubs: [ImageStub]) {
        let cells: [CellController] = stubs.map { stub in
            let cellController = FeedImageCellController(
                viewModel: stub.viewModel,
                delegate: stub,
                selection: { })
            stub.controller = cellController
            return CellController(id: UUID(), cellController)
        }
        display(cells)
    }
}

private class ImageStub: FeedImageCellControllerDelegate {
    weak var controller: FeedImageCellController?
    let viewModel: FeedImageViewModel
    let image: UIImage?
    
    init(description: String?, location: String?, image: UIImage?) {
        self.viewModel = FeedImageViewModel(
            description: description,
            location: location)
        self.image = image
    }
    func didRequestImage() {
        controller?.display(ResourceLoadingViewModel(isLoading: false))
        if let image = self.image {
            controller?.display(image)
            controller?.display(ResourceErrorViewModel(message: .none))
        } else {
            controller?.display(ResourceErrorViewModel(message: "any error"))
        }
    }
    
    func didCancelImage() {}
}
