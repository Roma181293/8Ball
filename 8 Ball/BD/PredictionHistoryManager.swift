//
//  PredictionHistoryManager.swift
//  8 Ball
//
//  Created by Roman Topchii on 15.01.2022.
//

import Foundation
import CoreData

protocol PredictionHistoryListProvider {
    init(delegate: DataListPresentableDelegate, context: NSManagedObjectContext)
    func fetchData() throws
    func deleteEntityAtIndexPath(_ indexPath: IndexPath) throws
    func numberOfRowsInSection(_ section: Int) -> Int
    func numberOfSections() -> Int
    func entityForIndexPath(_ indexPath: IndexPath) -> PredictionHistory
}

class PredictionHistoryManager: PredictionHistoryListProvider {
    
    private let delegate: DataListPresentableDelegate?
    private let context: NSManagedObjectContext
    private let coreDataManager = CoreDataManager.shared
    
    private var fetchRequest : NSFetchRequest<PredictionHistory> = {
        let fetchRequest = NSFetchRequest<PredictionHistory>(entityName: PredictionHistory.entity().name!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.fetchBatchSize = 20
        return fetchRequest
    }()
    
    private lazy var fetchedResultsController : NSFetchedResultsController<PredictionHistory> = {
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    required init(delegate: DataListPresentableDelegate, context: NSManagedObjectContext) {
        self.delegate = delegate
        self.context = context
    }
    
    init(context: NSManagedObjectContext) {
        self.delegate = nil
        self.context = context
    }
    
    //MARK: - Single entity methods
    func createPrediction(question: String, answer: Answer) throws {
        let prediction = PredictionHistory(context: context)
        prediction.answer = answer
        prediction.date = Date()
        prediction.question = question
        try coreDataManager.saveContext(context)
    }
    
    func deletePrediction(_ prediction: PredictionHistory) throws {
        context.delete(prediction)
        try coreDataManager.saveContext(context)
    }
}

//MARK: - PredictionHistoryListProvider methods
extension PredictionHistoryManager {
    func fetchData() throws {
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.predicate = nil
        
        try fetchedResultsController.performFetch()
        delegate?.presentData()
    }
    
    func deleteEntityAtIndexPath(_ indexPath: IndexPath) throws {
        try deletePrediction(fetchedResultsController.object(at: indexPath))
        try fetchedResultsController.performFetch()
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects  ?? 0
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func entityForIndexPath(_ indexPath: IndexPath) -> PredictionHistory {
        fetchedResultsController.object(at: indexPath)
    }
}
