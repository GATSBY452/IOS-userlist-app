//
//  UsersListViewController.swift
//  Userlists
//
//  Created by Yusuf Abbas on 26/06/2026.
//

import Combine
import UIKit


final class UsersListViewController: UIViewController, UITableViewDelegate {
    private enum Section: Hashable {
        case main
    }

    private let viewModel: UsersListViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private var users: [User] = []

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UserCell.self, forCellReuseIdentifier: UserCell.reuseIdentifier)
        table.rowHeight = 64
        table.dataSource = self
        table.delegate = self
        return table
    }()

//    private lazy var dataSource: UITableViewDiffableDataSource<Section, User> = {
//        UITableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, user in
//            let cell = tableView.dequeueReusableCell(
//                withIdentifier: UserCell.reuseIdentifier,
//                for: indexPath
//            ) as! UserCell
//            cell.configure(with: user)
//            return cell
//        }
//    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    init(viewModel: UsersListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Users"
        view.backgroundColor = .systemBackground

        setUpLayout()
        setUpSearch()
        bindViewModel()

        Task { await viewModel.start() }
    }

    private func setUpLayout() {
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setUpSearch() {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search by name, username, or email"
        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func bindViewModel() {
        viewModel.$users
            .receive(on: DispatchQueue.main)
            .sink { [weak self] users in
                self?.apply(users)
            }
            .store(in: &cancellables)

        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state)
            }
            .store(in: &cancellables)
    }

    private func apply(_ users: [User]) {
        self.users = users
        tableView.reloadData()
    }

    private func render(_ state: UsersListViewModel.State) {
        switch state {
        case .idle:
            activityIndicator.stopAnimating()
            emptyStateLabel.isHidden = true
        case .loading:
            activityIndicator.startAnimating()
            emptyStateLabel.isHidden = true
        case .loaded:
            activityIndicator.stopAnimating()
            let isEmpty = viewModel.users.isEmpty
            emptyStateLabel.isHidden = !isEmpty
            if isEmpty { emptyStateLabel.text = "No users found." }
        case .error(let message):
            activityIndicator.stopAnimating()
            emptyStateLabel.isHidden = false
            emptyStateLabel.text = message
        }
    }
}

extension UsersListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: UserCell.reuseIdentifier,
            for: indexPath
        ) as! UserCell
        cell.configure(with: users[indexPath.row])
        return cell
    }
}

extension UsersListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.updateSearch(searchController.searchBar.text ?? "")
    }
}
