//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Galih Samudra on 19/05/23.
//

import Foundation
import CoreData

public final class CoreDataFeedStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL) throws {
        let bundle = Bundle(for: CoreDataFeedStore.self)
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    deinit {
        cleanUpReferencesToPersistentStores()
    }
    
    // MARK: Helpers
    
    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait {
            let coordinator =  self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
    
    func perform(action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform {
            action(context)
        }
    }
    
}
