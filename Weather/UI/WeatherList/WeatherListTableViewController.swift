//
//  ContentView.swift
//  Weather
//
//  Created by Alex Yuh-Rern Wang on 9/13/23.
//

import SwiftUI
import Foundation
import Combine

struct WeatherListView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> WeatherListTableViewController {
        WeatherListTableViewController()
    }
    
    func updateUIViewController(_ uiViewController: WeatherListTableViewController, context: Context) {
        
    }
}

class WeatherListTableViewController: UITableViewController {
    
    private var subscriptions = Set<AnyCancellable>()
    var viewModel: WeatherListViewModel = WeatherListViewModel()
    
    let historyCellIdentifier = "historyCell"
    
    init() {
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    func bind() {
        
    }
    
    // MARK: - TableView Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewModel.sections[section] {
        case .currentWeather:
            return 1
        case .history:
            // First item in locationIds is shown in current weather
            return max(1, viewModel.locations.count - 1)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.sections[indexPath.section] {
        case .currentWeather:
            return UITableViewCell()
        case .history:
            let cell: UITableViewCell = {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: historyCellIdentifier) else {
                    return UITableViewCell(style: .default, reuseIdentifier: historyCellIdentifier)
                }
                return cell
            }()
            
            var content = cell.defaultContentConfiguration()
            
            if viewModel.locations.count <= 1 {
                content.text = "Nothing here yet."
            } else {
                let offset = indexPath.row + 1
                content.text = viewModel.locations[offset].name
            }
            
            cell.contentConfiguration = content
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
