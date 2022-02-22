//
//  SettingsTableViewController.swift
//  8 Ball
//
//  Created by Roman Topchii on 15.01.2022.
//

import UIKit

enum SettingsList: String{
    case useCustomAnswers = "Use custom answers"
    case answers = "Answers"
    case predictionHistory = "Prediction history"
}

protocol PredictionSettingsConfiguration {
    func useCustomAnswers(_ useCustomAnswers: Bool)
    func isCustomAnswers() -> Bool
}

class SettingsTableViewController: UITableViewController {
    
    private let data : [SettingsList] = [.useCustomAnswers, .answers, .predictionHistory]
    private var router: SettingsRouter?
    
    private var useCustomAnswers: Bool = false {
        didSet {
            if useCustomAnswers {
                NotificationCenter.default.post(name: .changePredictionProvider,
                                                object: nil,
                                                userInfo: ["predictionProvider": DBPredictionService(context: CoreDataManager.shared.persistentContainer.viewContext)])
            }
            else {
                NotificationCenter.default.post(name: .changePredictionProvider,
                                                object: nil,
                                                userInfo: ["predictionProvider": RemotePredictionService(networkDataProvider: NetworkService.init())])
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        router = SettingsRouter(viewController: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeUseCustomAnswers(notification:)), name: .setUseCustomAnswersTo, object: nil)
        NotificationCenter.default.post(name: .getIsUseCustomAnswers, object: nil)
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: .setUseCustomAnswersTo, object: nil)
        NotificationCenter.default.removeObserver(self, name: .getIsUseCustomAnswers, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.navigationItem.title = NSLocalizedString("Settings", comment: "")
    }
    
    @objc private func changeUseCustomAnswers(notification: NSNotification) {
        if let useCustomAnswers = notification.userInfo?["setUseCustomAnswersTo"] as? Bool {
            self.useCustomAnswers = useCustomAnswers
        }
    }
}

// MARK: - Table view data source
extension SettingsTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell_ID", for: indexPath) as! SettingsTableViewCell
        cell.configureCell(for: data[indexPath.row], with: self)
        return cell
    }
}

//MARK: - Table view delegate
extension SettingsTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch data[indexPath.row] {
        case .answers:
            router?.route(to: .answers)
        case .predictionHistory:
            router?.route(to: .predictionHistory)
        default: break
        }
    }
}

//MARK: - PredictionSettingsConfiguration
extension SettingsTableViewController: PredictionSettingsConfiguration {
    func useCustomAnswers(_ useCustomAnswers: Bool) {
        self.useCustomAnswers = useCustomAnswers
    }
    
    func isCustomAnswers() -> Bool {
        return useCustomAnswers
    }
}
