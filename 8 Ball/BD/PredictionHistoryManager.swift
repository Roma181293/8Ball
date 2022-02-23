//
//  PredictionHistoryManager.swift
//  8 Ball
//
//  Created by Roman Topchii on 15.01.2022.
//

import Foundation
import CoreData

class PredictionHistoryManager: EntityListProvider<PredictionHistory> {
    
    init(context: NSManagedObjectContext) {
        super.init(delegate: nil, context: context)
    }
    
    required init(delegate: DataListPresentableDelegate?, context: NSManagedObjectContext) {
        super.init(delegate: delegate, context: context)
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
    
    //MARK: - EntityListProvider methods
    override func fetchData() throws {
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.predicate = nil
        
        try fetchedResultsController.performFetch()
        delegate?.presentData()
    }
    
    override func deleteEntityAtIndexPath(_ indexPath: IndexPath) throws {
        try deletePrediction(fetchedResultsController.object(at: indexPath))
        try fetchedResultsController.performFetch()
    }
}
