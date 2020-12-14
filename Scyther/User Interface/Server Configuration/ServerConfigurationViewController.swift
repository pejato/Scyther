//
//  ServerConfigurationViewController.swift
//  Scyther
//
//  Created by Brandon Stillitano on 11/12/20.
//

import UIKit

internal class ServerConfigurationViewController: UIViewController {
    // MARK: - Data
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var viewModel: ServerConfigurationViewModel?

    // MARK: - Init
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupUI() {
        //Setup Table View
        tableView.delegate = self
        tableView.dataSource = self

        //Register Table View Cells
        tableView.register(DefaultCell.self, forCellReuseIdentifier: RowStyle.default.rawValue)
        tableView.register(CheckmarkCell.self, forCellReuseIdentifier: RowStyle.checkmarkAccessory.rawValue)

        //Add Table View
        view.addSubview(tableView)
    }

    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|",
                                                           options: .directionLeadingToTrailing,
                                                           metrics: nil,
                                                           views: ["subview": tableView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|",
                                                           options: .directionLeadingToTrailing,
                                                           metrics: nil,
                                                           views: ["subview": tableView]))
    }

    // MARK: - Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIView.setAnimationsEnabled(false)
        UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
        UIView.setAnimationsEnabled(true)
    }

    // MARK: - Configure
    internal func configure(with viewModel: ServerConfigurationViewModel) {
        self.viewModel = viewModel
        self.viewModel?.delegate = self
        self.viewModel?.prepareObjects()

        title = viewModel.title
        navigationItem.title = viewModel.title
    }
}

extension ServerConfigurationViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.numberOfSections ?? 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel?.title(forSection: section) ?? nil
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numbeOfRows(inSection: section) ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Check for Cell
        guard let row = viewModel?.row(at: indexPath) else {
            return UITableViewCell()
        }

        // Setup Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: row.cellReuseIdentifier,
                                                 for: indexPath)
        cell.textLabel?.text = viewModel?.title(for: row, indexPath: indexPath)
        cell.detailTextLabel?.text = row.detailText
        cell.accessoryView = row.accessoryView

        // Setup Accessory
        switch row.style {
        case .checkmarkAccessory:
            guard let checkRow: CheckmarkRow = row as? CheckmarkRow else {
                break
            }
            cell.accessoryType = checkRow.checked ? .checkmark : .none
        default:
            break
        }

        return cell
    }

}

extension ServerConfigurationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect Cell
        defer { tableView.deselectRow(at: indexPath, animated: true) }

        // Check for Cell
        guard let row = viewModel?.row(at: indexPath) else {
            return
        }
        row.actionBlock?()
    }
}

extension ServerConfigurationViewController: ServerConfigurationViewModelProtocol {
    func viewModelShouldReloadData() {
        self.tableView.reloadData()
    }
}