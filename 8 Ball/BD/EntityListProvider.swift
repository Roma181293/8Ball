//
//  EntityListProvider.swift
//  8 Ball
//
//  Created by Roman Topchii on 23.02.2022.
//

import Foundation
import CoreData

protocol DataListPresentableDelegate {
    func presentData()
}

class EntityListProvider<Entity: NSManagedObject> {
    
    public let delegate: DataListPresentableDelegate?
    public let context: NSManagedObjectContext
    public let coreDataManager = CoreDataManager.shared
    
    public var fetchRequest : NSFetchRequest<Entity> = {
        let fetchRequest = NSFetchRequest<Entity>(entityName: Entity.entity().name!)
        return fetchRequest
    }()
    
    lazy var fetchedResultsController : NSFetchedResultsController<Entity> = {
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    required init(delegate: DataListPresentableDelegate?, context: NSManagedObjectContext) {
        self.delegate = delegate
        self.context = context
    }
    
    func fetchData() throws {
    }
    
    open func deleteEntityAtIndexPath(_ indexPath: IndexPath) throws {
        
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects  ?? 0
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    open func entityForIndexPath(_ indexPath: IndexPath) -> Entity {
        fetchedResultsController.object(at: indexPath)
    }
}
