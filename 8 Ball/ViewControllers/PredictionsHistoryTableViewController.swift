//
//  PredictionsHistoryTableViewController.swift
//  8 Ball
//
//  Created by Roman Topchii on 16.01.2022.
//

import UIKit
import CoreData

class PredictionsHistoryTableViewController: UITableViewController {
    
    let cdm = CoreDataManager.shared
    let context = CoreDataManager.shared.persistentContainer.viewContext
    
    lazy var fetchedResultsController : NSFetchedResultsController<PredictionHistory> = {
        let fetchRequest : NSFetchRequest<PredictionHistory> = NSFetchRequest<PredictionHistory>(entityName: PredictionHistory.entity().name!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.fetchBatchSize = 20
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        return frc
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("Predictions history", comment: "")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PredictionHistCell_ID")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
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
        var cell = UITableViewCell(style: .subtitle , reuseIdentifier: "PredictionHistCell_ID")
        if cell == nil {
            cell = tableView.dequeueReusableCell(withIdentifier: "PredictionHistCell_ID", for: indexPath)
        }
        let prediction = fetchedResultsController.object(at: indexPath)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        cell.textLabel?.text = dateFormatter.string(from: prediction.date ?? Date()) + "\n" + (prediction.question ?? "") + "?"
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        if let answer = prediction.answer {
            var type = ""
            switch answer.type {
            case AnswerType.affirmative.rawValue: type =  "🙂"
            case AnswerType.neutral.rawValue: type = "😐"
            case AnswerType.contrary.rawValue: type = "🙁"
            case AnswerType.unknown.rawValue: type = "😳"
            default: type = "🤷‍♂️"
            }
            cell.detailTextLabel?.text = type + " " + (answer.title ?? "")
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                try PredictionHistoryManager.deletePrediction(fetchedResultsController.object(at: indexPath), context: context)
                try cdm.saveContext(context)
                try fetchedResultsController.performFetch()
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            catch let error {
                errorHandler(error: error)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
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
