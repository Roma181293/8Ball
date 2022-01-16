//
//  SettingsTableViewCell.swift
//  8 Ball
//
//  Created by Roman Topchii on 15.01.2022.
//


import UIKit

class SettingsTableViewCell: UITableViewCell {
    
//    var dataItem: SettingsList!
    
    var delegate: SettingsSetProtocol!
    
    let titleLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let switcher : UISwitch = {
        let switcher = UISwitch()
        switcher.translatesAutoresizingMaskIntoConstraints = false
        return switcher
    }()
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        switcher.isHidden = true
        accessoryType = .none
    }
    
    func configureCell(for dataItem: SettingsList, with delegate: SettingsSetProtocol) {
        self.delegate = delegate
//        self.dataItem = dataItem
        
        
        switcher.isHidden = true
        
        titleLabel.text = NSLocalizedString(dataItem.rawValue, comment: "")
        switch dataItem {
        case .useCustomAnswers:
            switcher.isHidden = false
            switcher.isOn = delegate.isCustomAnswers()
        default:
            accessoryType = .disclosureIndicator
        }
        
        
        contentView.addSubview(titleLabel)
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        contentView.addSubview(switcher)
        switcher.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -22).isActive = true
        switcher.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        switcher.addTarget(self, action: #selector(self.switching(_:)), for: .valueChanged)
    }
    
    @objc func switching(_ sender: UISwitch) {
        delegate.useCustomAnswers(sender.isOn)
    }
}
