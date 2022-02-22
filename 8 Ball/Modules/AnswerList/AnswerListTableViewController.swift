//
//  AnswersTableViewController.swift
//  8 Ball
//
//  Created by Roman Topchii on 15.01.2022.
//

import UIKit
import CoreData


protocol AnswerListListener {
    func refreshData()
}

class AnswerListTableViewController: UITableViewController {
    
    private let coreDataManager = CoreDataManager.shared
    private let context = CoreDataManager.shared.persistentContainer.viewContext
    
    private var router: AnswerListRouter!
    
    private lazy var fetchedResultsController : NSFetchedResultsController<Answer> = {
        let fetchRequest : NSFetchRequest<Answer> = NSFetchRequest<Answer>(entityName: Answer.entity().name!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false)]
        fetchRequest.fetchBatchSize = 20
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        router = AnswerListRouter(viewController: self)
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
        router.route(to: .addAnswer(delegate: self))
    }
}


// MARK: - Table view data source
extension AnswerListTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects  ?? 0
    }
}


// MARK: - Table view delegate
extension AnswerListTableViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: .value1, reuseIdentifier: "AnswerCell_ID")
        if cell == nil {
            cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell_ID", for: indexPath)
        }
        let answer = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = (AnswerType(rawValue: answer.type) ?? .unknown).toEmoji() + "  " + (answer.title ?? "")
        cell.detailTextLabel?.text = answer.createdByUser ? "🧒" : "🤖"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let answer = fetchedResultsController.object(at: indexPath)
        if answer.createdByUser {
            router.route(to: .editAnswer(answer: answer, delegate: self))
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                try AnswerManager.deleteAnswer(fetchedResultsController.object(at: indexPath), context: context)
                try coreDataManager.saveContext(context)
                try fetchedResultsController.performFetch()
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            catch let error {
                errorHandler(error: error)
            }
        }
    }
}

extension AnswerListTableViewController: AnswerListListener {
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
