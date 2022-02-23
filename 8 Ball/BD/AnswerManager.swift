//
//  AnswerManager.swift
//  8 Ball
//
//  Created by Roman Topchii on 15.01.2022.
//

import Foundation
import CoreData

class AnswerManager: EntityListProvider<Answer> {
    
    init(context: NSManagedObjectContext) {
        super.init(delegate: nil, context: context)
    }
    
    required init(delegate: DataListPresentableDelegate?, context: NSManagedObjectContext) {
        super.init(delegate: delegate, context: context)
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
    
    //MARK: - EntityListProvider methods
    override func fetchData() throws {
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdByUser", ascending: true)]
        fetchRequest.predicate = nil
    
        try fetchedResultsController.performFetch()
        delegate?.presentData()
    }
    
    override func deleteEntityAtIndexPath(_ indexPath: IndexPath) throws {
        try deleteAnswer(fetchedResultsController.object(at: indexPath))
        try fetchedResultsController.performFetch()
    }
}
