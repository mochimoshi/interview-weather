//
//  ContentView.swift
//  Weather
//
//  Created by Alex Wang on 9/13/23.
//

import Foundation

import UIKit
import SwiftUI
import Combine

import CachedImage

// This view is faster to write in pure SwiftUI
// but for the purposes of this exercise and to mix in some UIKit code
// we'll use a UITableViewController
struct WeatherListView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> WeatherListTableViewController {
        WeatherListTableViewController()
    }
    
    func updateUIViewController(_ uiViewController: WeatherListTableViewController, context: Context) {
        // No updates needed here
    }
}

class WeatherListTableViewController: UITableViewController {
    
    private var subscriptions = Set<AnyCancellable>()
    var viewModel: WeatherListViewModel = WeatherListViewModel()
    
    var loadingProgress = UIProgressView()
    
    let currentWeatherIdentifier = "currentWeatherCell"
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
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // A funky side effect of UIViewControllerRepresentable.
        // The navigation controller is not actually available at viewDidLoad
        setupNavToolbar()
    }
    
    func bind() {
        viewModel.$locations
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &subscriptions)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    // Whoops, adding subviews to UITableViewController is....finnicky.
                    // This honestly can also be a UIViewController with a UITableView instead
                    // Due to time constraints, we'll first do a quick workaround and show
                    // loading progress in the top right navbar instead. (It's less intrusive too.)
                    let progressView = UIActivityIndicatorView(style: .medium)
                    progressView.startAnimating()
                    
                    self?.navigationController?.navigationBar.topItem?.rightBarButtonItems = [
                        .init(customView: progressView)
                    ]
                } else {
                    self?.setupNavToolbar()
                    self?.tableView.reloadData()
                }
            }
            .store(in: &subscriptions)
    }
    
    func setupViews() {
        tableView.separatorStyle = .none
    }
    
    func setupNavToolbar() {
        navigationController?.navigationBar.topItem?.rightBarButtonItems = [
            .init(
                title: "Current Weather",
                style: .plain,
                target: self,
                action: #selector(getWeatherForCurrentLocation)
            ),
            .init(
                title: "Add",
                style: .plain,
                target: self,
                action: #selector(addCity)
            )
        ]
    }
    
    @objc func addCity() {
        let alert = UIAlertController(
            title: "Add Location",
            message: "Enter a location name",
            preferredStyle: .alert
        )
        alert.addTextField()
        
        let submit = UIAlertAction(
            title: "Submit",
            style: .default
        ) { action in
            // Validate and add city
            guard let location = alert.textFields?.first?.text else { return }
            
            Task { @MainActor in
                do {
                    try await self.viewModel.getWeather(name: location)
                } catch let error {
                    print("Error: \(error)")
                    self.showErrorAlert(error: error)
                }
            }
        }
        
        let cancel = UIAlertAction(
            title: "Cancel",
            style: .cancel
        )
        
        alert.addAction(submit)
        
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
    
    @objc func getWeatherForCurrentLocation() {
        Task { @MainActor in
            do {
                try await self.viewModel.getUserLocationWeather()
            } catch let error {
                print("Error: \(error)")
                self.showErrorAlert(error: error)
            }
        }
    }
    
    func showErrorAlert(error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel))
        
        present(alert, animated: true)
    }
}

// MARK: - TableView Methods
extension WeatherListTableViewController {
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
            let cell: UITableViewCell = {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: currentWeatherIdentifier) else {
                    return UITableViewCell(style: .default, reuseIdentifier: currentWeatherIdentifier)
                }
                return cell
            }()
            
            cell.selectionStyle = .none
            
            guard let currentLocation = viewModel.locations.first else {
                var content = cell.defaultContentConfiguration()
                content.text = "Add a location to start"
                cell.contentConfiguration = content
                return cell
            }
            
            let formattedWeather = viewModel.formatWeather(weather: currentLocation)
            cell.contentConfiguration = UIHostingConfiguration {
                // TODO: This can be pulled out into its own file
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(formattedWeather.displayName)
                            .font(Font.title2)
                            .fontWeight(.bold)
                        
                        Text(formattedWeather.condition)
                        
                        HStack {
                            Text("Currently: \(formattedWeather.temperatures.current)")
                                .fontWeight(.medium)
                            Text("(Feels like \(formattedWeather.temperatures.feelsLike))")
                        }
                        HStack {
                            Text("High: \(formattedWeather.temperatures.high)")
                            Text("Low: \(formattedWeather.temperatures.low)")
                        }
                    }
                    Spacer()
                    
                    // This should be using URLCache for images
                    // There seems to be some issues with using SwiftUI in a UITableViewCell and
                    // AsyncImage, where on first load the image download is cancelled prematurely.
                    // Example: https://developer.apple.com/forums/thread/718480
                    // For now, we'll use a 3rd party library, which is not ideal
                    
                    CachedImage(url: formattedWeather.icon) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 48.0, height: 48.0)
                    } placeholder: {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                }
            }

            
            return cell
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
                cell.selectionStyle = .none
            } else {
                let offset = indexPath.row + 1
                content.text = viewModel.locations[offset].displayName
                cell.selectionStyle = .default
            }
            
            cell.contentConfiguration = content
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch viewModel.sections[section] {
        case .currentWeather:
            return nil
        case .history:
            return "Previously Searched"
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        switch viewModel.sections[indexPath.section] {
        case .currentWeather:
            break
        case .history:
            guard viewModel.locations.count > 1 else { return }
            
            let offset = indexPath.row + 1
            Task { @MainActor in
                try? await self.viewModel.loadPreviousLocation(
                    weather: self.viewModel.locations[offset]
                )
            }
        }
    }
}
