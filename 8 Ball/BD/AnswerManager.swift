//
//  AnswerManager.swift
//  8 Ball
//
//  Created by Roman Topchii on 15.01.2022.
//

import Foundation
import CoreData

protocol AnswerListPresenter {
    func presentData()
    func errorHandler(error: Error)
}

protocol AnswerListProvider {
    init(delegate: AnswerListPresenter, context: NSManagedObjectContext)
    func fetchData() throws
    func deleteAnswerAtIndexPath(_ indexPath: IndexPath) throws
    func numberOfRowsInSection(_ section: Int) -> Int
    func numberOfSections() -> Int
    func answerForIndexPath(_ indexPath: IndexPath) -> Answer
}

class AnswerManager: AnswerListProvider {
    
    private let delegate: AnswerListPresenter
    private let context: NSManagedObjectContext
    
    private lazy var fetchedResultsController : NSFetchedResultsController<Answer> = {
        let fetchRequest : NSFetchRequest<Answer> = NSFetchRequest<Answer>(entityName: Answer.entity().name!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false)]
        fetchRequest.fetchBatchSize = 20
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    required init(delegate: AnswerListPresenter, context: NSManagedObjectContext) {
        self.delegate = delegate
        self.context = context
    }
    
    func fetchData() throws {
        try fetchedResultsController.performFetch()
        delegate.presentData()
    }
    
    func deleteAnswerAtIndexPath(_ indexPath: IndexPath) throws {
        try AnswerManager.deleteAnswer(fetchedResultsController.object(at: indexPath), context: context)
        try CoreDataManager.shared.saveContext(context)
        try fetchedResultsController.performFetch()
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects  ?? 0
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func answerForIndexPath(_ indexPath: IndexPath) -> Answer {
        fetchedResultsController.object(at: indexPath)
    }
}

extension AnswerManager {
    static func getOrCreateAnswer(_ answerString: String, type: AnswerType, createdByUser: Bool, context: NSManagedObjectContext) -> Answer {
        let fetchRequest : NSFetchRequest<Answer> = NSFetchRequest<Answer>(entityName: Answer.entity().name!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdByUser", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "title = %@ && type = %i && createdByUser = %@", argumentArray: [answerString, type.rawValue as CVarArg, createdByUser])
        
        if let answers = try? context.fetch(fetchRequest), answers.isEmpty == false {
            return answers.last!
        }
        else {
            let answer = Answer(context: context)
            answer.type = Int16(type.rawValue)
            answer.title = answerString
            answer.createdByUser = createdByUser
            return answer
        }
    }
    
    private static func isAnswerExist(_ answerString: String, type: AnswerType, createdByUser: Bool, context: NSManagedObjectContext) -> Bool {
        
        let fetchRequest : NSFetchRequest<Answer> = NSFetchRequest<Answer>(entityName: Answer.entity().name!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdByUser", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "title = %@ && createdByUser = %@", argumentArray: [answerString, createdByUser])
        
        if let answers = try? context.fetch(fetchRequest), answers.isEmpty == false {
            return false
        }
        return true
    }
    
    static func createAnswer(_ answerString: String, type: AnswerType, createdByUser: Bool, context: NSManagedObjectContext) throws {
        guard isAnswerExist(answerString, type: type, createdByUser: createdByUser, context: context) else {
            throw AnswerError.answerAlreadyExists
        }
        getOrCreateAnswer(answerString, type: type, createdByUser: createdByUser, context: context)
    }
    
    static func editAnswer(_ answer: Answer, answerTitle: String, type: AnswerType, context: NSManagedObjectContext) throws {
        if answer.title != answerTitle {
            guard isAnswerExist(answerTitle, type: type, createdByUser: answer.createdByUser, context: context) else {
                throw AnswerError.answerAlreadyExists
            }
        }
        answer.title = answerTitle
        answer.type = Int16(type.rawValue)
    }
    
    static func deleteAnswer(_ answer: Answer, context: NSManagedObjectContext) throws {
        guard answer.predictionHistory?.allObjects.isEmpty == true else {
            throw AnswerError.answerUsedInPrediction
        }
        context.delete(answer)
    }
    
    static func getRandomAnswer(context: NSManagedObjectContext) -> Answer? {
        let fetchRequest : NSFetchRequest<Answer> = NSFetchRequest<Answer>(entityName: Answer.entity().name!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdByUser", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "createdByUser = TRUE")
        
        if let answers = try? context.fetch(fetchRequest){
            return answers.randomElement()
        }
        else {
            return nil
        }
    }
}
