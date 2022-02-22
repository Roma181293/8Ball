//
//  AnswersTableViewController.swift
//  8 Ball
//
//  Created by Roman Topchii on 15.01.2022.
//

import UIKit
import CoreData


protocol AnswerListListener {
    func fetchData()
}

class AnswerListTableViewController: UITableViewController {
    
    private var answerListProvider: AnswerListProvider!
    private var router: AnswerListRouter!
    
    private let coreDataManager = CoreDataManager.shared
    private let context = CoreDataManager.shared.persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        router = AnswerListRouter(viewController: self)
        answerListProvider = AnswerManager(delegate: self, context: context)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AnswerCell_ID")
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    
    @objc private func addAnswer(){
        router.route(to: .addAnswer(delegate: self))
    }
    
    private func configureUI() {
        self.navigationItem.title = NSLocalizedString("Answers", comment: "")
        
        let addButton = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(self.addAnswer))
        addButton.image = UIImage(systemName: "plus")
        self.navigationItem.rightBarButtonItem = addButton
    }
}


// MARK: - Table view data source
extension AnswerListTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return answerListProvider.numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answerListProvider.numberOfRowsInSection(section)
    }
}


// MARK: - Table view delegate
extension AnswerListTableViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: .value1, reuseIdentifier: "AnswerCell_ID")
        if cell == nil {
            cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell_ID", for: indexPath)
        }
        let answer = answerListProvider.answerForIndexPath(indexPath)
        cell.textLabel?.text = (AnswerType(rawValue: answer.type) ?? .unknown).toEmoji() + "  " + (answer.title ?? "")
        cell.detailTextLabel?.text = answer.createdByUser ? "🧒" : "🤖"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let answer = answerListProvider.answerForIndexPath(indexPath)
        if answer.createdByUser {
            router.route(to: .editAnswer(answer: answer, delegate: self))
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                try answerListProvider.deleteAnswerAtIndexPath(indexPath)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            catch let error {
                errorHandler(error: error)
            }
        }
    }
}

extension AnswerListTableViewController: AnswerListListener {
    func fetchData(){
        do {
            try answerListProvider.fetchData()
        }
        catch let error {
            errorHandler(error: error)
        }
    }
}

extension AnswerListTableViewController: AnswerListPresenter {
    func presentData() {
        tableView.reloadData()
    }
}
