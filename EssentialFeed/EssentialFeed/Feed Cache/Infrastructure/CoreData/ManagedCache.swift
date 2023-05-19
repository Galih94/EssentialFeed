//
//  ManagedCache.swift
//  EssentialFeed
//
//  Created by Galih Samudra on 19/05/23.
//

import CoreData

@objc(ManagedCache) // set name ManagedCache.entity().name
internal class ManagedCache: NSManagedObject {
    @NSManaged var timeStamp: Date
    @NSManaged var feed: NSOrderedSet
    
    var localFeed: [LocalFeedImage] {
        return feed.compactMap { ($0 as? ManagedFeedImage)?.local }
    }
    
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        
        try find(in: context).map(context.delete(_:))
        return ManagedCache(context: context)
    }
}
