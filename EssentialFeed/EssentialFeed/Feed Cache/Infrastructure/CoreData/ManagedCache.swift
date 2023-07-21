//
//  ManagedCache.swift
//  EssentialFeed
//
//  Created by Galih Samudra on 19/05/23.
//

import CoreData

@objc(ManagedCache) // set name ManagedCache.entity().name
class ManagedCache: NSManagedObject {
    @NSManaged var timeStamp: Date
    @NSManaged var feed: NSOrderedSet
    
}

extension ManagedCache {
    var localFeed: [LocalFeedImage] {
        return feed.compactMap { ($0 as? ManagedFeedImage)?.local }
    }
    
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    
    static func deleteCache(in context: NSManagedObjectContext) throws  {
        try find(in: context).map(context.delete).map(context.save)
    }
    
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try deleteCache(in: context)
        return ManagedCache(context: context)
    }
}
