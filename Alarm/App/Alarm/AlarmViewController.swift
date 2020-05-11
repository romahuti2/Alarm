//
//  MainViewController.swift
//  Alarm
//
//  Created by Hipteam on 09.05.2020.
//  Copyright © 2020 Roman Huti. All rights reserved.
//

import UIKit

class AlarmViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    var viewModel: AlarmViewModelType!
    
    private var parameters: [Parameter] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        setupBindings()
    }
    
    func setupBindings() {
        viewModel.transform()
        viewModel.stateText.bindAndFire { (observer, value) in
            self.stateLabel.text = value
        }
        viewModel.parameters.bindAndFire { (observer, value) in
            self.parameters = value
            self.tableView.reloadData()
        }
        viewModel.playButtonTitle.bind { (obserer, value) in
            self.playButton.setTitle(value, for: .normal)
        }
    }
    
    @IBAction func playPause(_ sender: UIButton) {
        viewModel.playPause()
    }
    
}

extension AlarmViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parameters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ParameterTableCell.className) as! ParameterTableCell
        let parameter = parameters[indexPath.row]
        cell.configure(parameter: parameter)
        return cell
    }
}

extension AlarmViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = ParameterType(rawValue: indexPath.row) else {
            return
        }
        switch type {
        case .alarmTime:
            viewModel.selectAlarmTime()
        case .sleepTime:
            viewModel.selectSleepTime()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
