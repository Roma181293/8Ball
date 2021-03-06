//
//  AnswerManager.swift
//  8 Ball
//
//  Created by Roman Topchii on 15.01.2022.
//

import Foundation
import CoreData




class AnswerManager {
    
    static func getOrCreateAnswer(_ answerString: String, type: AnswerType, createdByUser: Bool, context: NSManagedObjectContext) -> Answer {
        let fetchRequest : NSFetchRequest<Answer> = NSFetchRequest<Answer>(entityName: Answer.entity().name!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdByUser", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "title = %@ && type = %i && createdByUser = %@", argumentArray: [answerString, type.rawValue as CVarArg, createdByUser])
        
        if let answers = try? context.fetch(fetchRequest), answers.isEmpty == false {
            return answers.last!
        }
        else {
            let answer = Answer(context: context)
            answer.type = type.rawValue
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
    
    static func editAnswer(_ answer: Answer, answerString: String, type: AnswerType, context: NSManagedObjectContext){
        answer.title = answerString
        answer.type = type.rawValue
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
