//
//  AnswersTableViewController.swift
//  8 Ball
//
//  Created by Roman Topchii on 15.01.2022.
//

import UIKit
import CoreData


protocol AnswerListRefreshProtocol {
    func refreshData()
}

class AnswersTableViewController: UITableViewController {

    let cdm = CoreDataManager.shared
    let context = CoreDataManager.shared.persistentContainer.viewContext
    
    lazy var fetchedResultsController : NSFetchedResultsController<Answer> = {
        let fetchRequest : NSFetchRequest<Answer> = NSFetchRequest<Answer>(entityName: Answer.entity().name!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false)]
        fetchRequest.fetchBatchSize = 20
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        return frc
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("Answers", comment: "")
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AnswerCell_ID")
        
        let addButton = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(self.addAnswer))
        addButton.image = UIImage(systemName: "plus")
        self.navigationItem.rightBarButtonItem = addButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    @objc private func addAnswer(){
        let vc = AnswerEditorViewController()
        vc.delegate = self
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects  ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: .value1, reuseIdentifier: "AnswerCell_ID")
        if cell == nil {
            cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell_ID", for: indexPath)
        }
        let answer = fetchedResultsController.object(at: indexPath)
        var type = ""
        switch answer.type {
        case AnswerType.affirmative.rawValue: type =  "🙂"
        case AnswerType.neutral.rawValue: type = "😐"
        case AnswerType.contrary.rawValue: type = "🙁"
        case AnswerType.unknown.rawValue: type = "😳"
        default: type = "🤷‍♂️"
        }
        
        cell.textLabel?.text = type + "  " + (answer.title ?? "")
        cell.detailTextLabel?.text = answer.createdByUser ? "🧒" : "🤖"
        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let answer = fetchedResultsController.object(at: indexPath)
        if answer.createdByUser {
            let vc = AnswerEditorViewController()
            vc.answer = answer
            vc.delegate = self
            vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                try AnswerManager.deleteAnswer(fetchedResultsController.object(at: indexPath), context: context)
                try cdm.saveContext(context)
                try fetchedResultsController.performFetch()
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            catch let error {
                errorHandler(error: error)
            }
        }
    }
}

extension AnswersTableViewController: AnswerListRefreshProtocol {
    func refreshData(){
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        }
        catch let error {
           errorHandler(error: error)
        }
    }
}
