//
//  AnswerManager.swift
//  8 Ball
//
//  Created by Roman Topchii on 15.01.2022.
//

import Foundation
import CoreData

protocol DataListPresentableDelegate {
    func presentData()
}

protocol AnswerListProvider {
    init(delegate: DataListPresentableDelegate, context: NSManagedObjectContext)
    func fetchData() throws
    func deleteAnswerAtIndexPath(_ indexPath: IndexPath) throws
    func numberOfRowsInSection(_ section: Int) -> Int
    func numberOfSections() -> Int
    func answerForIndexPath(_ indexPath: IndexPath) -> Answer
}

class AnswerManager: AnswerListProvider {
    
    private let delegate: DataListPresentableDelegate?
    private let context: NSManagedObjectContext
    private let coreDataManager = CoreDataManager.shared
    
    private var fetchRequest : NSFetchRequest<Answer> = {
        let fetchRequest = NSFetchRequest<Answer>(entityName: Answer.entity().name!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false)]
        fetchRequest.fetchBatchSize = 20
        return fetchRequest
    }()
    
    private lazy var fetchedResultsController : NSFetchedResultsController<Answer> = {
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
    func getOrCreateAnswer(_ answerString: String, type: AnswerType, createdByUser: Bool) -> Answer {
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
    
    private func isAnswerExist(_ answerString: String, type: AnswerType, createdByUser: Bool) -> Bool {
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdByUser", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "title = %@ && createdByUser = %@", argumentArray: [answerString, createdByUser])
        
        if let answers = try? context.fetch(fetchRequest), answers.isEmpty == false {
            return false
        }
        return true
    }
    
    func createAnswer(_ answerString: String, type: AnswerType, createdByUser: Bool) throws {
        guard isAnswerExist(answerString, type: type, createdByUser: createdByUser) else {
            throw AnswerError.answerAlreadyExists
        }
        getOrCreateAnswer(answerString, type: type, createdByUser: createdByUser)
        try coreDataManager.saveContext(context)
    }
    
    func editAnswer(_ answer: Answer, answerTitle: String, type: AnswerType) throws {
        guard (answer.predictionHistory?.allObjects as? [PredictionHistory])?.isEmpty == true else {throw AnswerError.answerUsedInPrediction}
        if answer.title != answerTitle {
            guard isAnswerExist(answerTitle, type: type, createdByUser: answer.createdByUser) else {
                throw AnswerError.answerAlreadyExists
            }
        }
        answer.title = answerTitle
        answer.type = Int16(type.rawValue)
        try coreDataManager.saveContext(context)
    }
    
    func deleteAnswer(_ answer: Answer) throws {
        guard answer.predictionHistory?.allObjects.isEmpty == true else {
            throw AnswerError.answerUsedInPrediction
        }
        context.delete(answer)
        try coreDataManager.saveContext(context)
    }
    
    func getRandomAnswer() -> Answer? {
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

//MARK: - AnswerListProvider methods
extension AnswerManager {
    func fetchData() throws {
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdByUser", ascending: true)]
        fetchRequest.predicate = nil
    
        try fetchedResultsController.performFetch()
        delegate?.presentData()
    }
    
    func deleteAnswerAtIndexPath(_ indexPath: IndexPath) throws {
        try deleteAnswer(fetchedResultsController.object(at: indexPath))
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
