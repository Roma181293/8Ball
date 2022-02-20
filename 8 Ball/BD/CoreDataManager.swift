//
//  CoreDataManager.swift
//  8 Ball
//
//  Created by Roman Topchii on 15.01.2022.
//

import Foundation
import CoreData


class CoreDataManager {
    
    public static let modelName = "8Ball"
    
    public static let model: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    static let shared = CoreDataManager()
    private init(){}
    
    public lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: CoreDataManager.modelName, managedObjectModel: CoreDataManager.model)
        let defaultDirectoryURL = NSPersistentContainer.defaultDirectoryURL()

        let productionStoreURL = defaultDirectoryURL.appendingPathComponent("Default.sqlite")
        let productionStoreDescription = NSPersistentStoreDescription(url: productionStoreURL)

        container.persistentStoreDescriptions = [productionStoreDescription]
        container.loadPersistentStores(completionHandler: { (_, error) in
            guard let error = error as NSError? else { return }
            fatalError("###\(#function): Failed to load persistent stores:\(error)")
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
       
        return container
    }()
    
    
    
    public func saveContext(_ context: NSManagedObjectContext) throws {
        if context.hasChanges {
            do {
                try context.save()
                
            } catch let error{
                context.rollback()
                throw error
            }
        }
    }
}

