//
//  PredictionsHistoryTableViewController.swift
//  8 Ball
//
//  Created by Roman Topchii on 16.01.2022.
//

import UIKit

class PredictionHistoryListTableViewController: UITableViewController {
    
    private var predictionHistoryListProvider: EntityListProvider<PredictionHistory>!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        predictionHistoryListProvider = PredictionHistoryManager(delegate: self, context: CoreDataManager.shared.persistentContainer.viewContext)
        
        self.navigationItem.title = NSLocalizedString("Predictions history", comment: "")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PredictionHistCell_ID")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    
    private func fetchData(){
        do {
            try predictionHistoryListProvider.fetchData()
        }
        catch let error {
            errorHandler(error: error)
        }
    }
}

// MARK: - Table view data source
extension PredictionHistoryListTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return predictionHistoryListProvider.numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return predictionHistoryListProvider.numberOfRowsInSection(section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: .subtitle , reuseIdentifier: "PredictionHistCell_ID")
        if cell == nil {
            cell = tableView.dequeueReusableCell(withIdentifier: "PredictionHistCell_ID", for: indexPath)
        }
        let prediction = predictionHistoryListProvider.entityForIndexPath(indexPath)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        cell.textLabel?.text = dateFormatter.string(from: prediction.date ?? Date()) + "\n" + (prediction.question ?? "") + "?"
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        if let answer = prediction.answer {
            
            cell.detailTextLabel?.text = (AnswerType(rawValue: Int(answer.type)) ?? .unknown).toEmoji() + " " + (answer.title ?? "")
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
        }
        return cell
    }
}

// MARK: - Table view delegate
extension PredictionHistoryListTableViewController {
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                try predictionHistoryListProvider.deleteEntityAtIndexPath(indexPath)
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
}


extension PredictionHistoryListTableViewController: DataListPresentableDelegate {
    func presentData() {
        tableView.reloadData()
    }
}
