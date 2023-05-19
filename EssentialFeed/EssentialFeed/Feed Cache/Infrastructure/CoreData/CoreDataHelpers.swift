//
//  CoreDataHelpers.swift
//  EssentialFeed
//
//  Created by Galih Samudra on 19/05/23.
//

import CoreData

extension NSPersistentContainer {
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistanceStores(Swift.Error)
    }
    
    static func load(modelName name: String, url: URL , in bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObject.with(name: name, in: bundle) else {
            throw LoadingError.modelNotFound
        }
        
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        
        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
        
        try loadError.map {
            throw LoadingError.failedToLoadPersistanceStores( $0 )
        }
        return container
    }
}

extension NSManagedObject {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}
