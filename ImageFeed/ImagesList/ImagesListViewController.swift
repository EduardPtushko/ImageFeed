//
//  ViewController.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 24.07.2026.
//

import Kingfisher
import OSLog
import UIKit

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListViewPresenterProtocol? { get set }
    func insertRows(at indices: IndexSet)
    func showSingleViewImage(imageURLString: String)
    func showProgressHUD()
    func dismissProgressHUD()
    func updateRow(at index: Int)
}

final class ImagesListViewController: UIViewController
        & ImagesListViewControllerProtocol
{

    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(resource: .ypBlack)
        tableView.separatorStyle = .none
        return tableView
    }()

    var presenter: ImagesListViewPresenterProtocol?

    // MARK: - Private Properties

    private func setupUI() {
        view.addSubview(tableView)
    }

    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            ImagesListCell.self,
            forCellReuseIdentifier: ImagesListCell.reuseIdentifier
        )
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConstraints()
        setupTable()

        tableView.contentInset = UIEdgeInsets(
            top: 12,
            left: 0,
            bottom: 12,
            right: 0
        )
        presenter?.viewDidLoad()
    }

}

// MARK: - Private Methods

extension ImagesListViewController {
    func insertRows(at indices: IndexSet) {
        let indexPaths = indices.map { IndexPath(row: $0, section: 0) }

        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }

    func showSingleViewImage(imageURLString: String) {
        let viewController = SingleImageViewController()

        viewController.imageUrl = imageURLString
        viewController.modalPresentationStyle = .fullScreen

        present(viewController, animated: true)
    }

    func showProgressHUD() {
        UIBlockingProgressHUD.show()
    }

    func dismissProgressHUD() {
        UIBlockingProgressHUD.dismiss()
    }

    func updateRow(at index: Int) {
        let indexPath = IndexPath(row: index, section: 0)

        if let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell {
            if let presenter {
                let count = presenter.photosCount()
                if index < count {
                    presenter.configureCell(cell, at: indexPath.row)
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        presenter?.photosCount() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        )

        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }

        imageListCell.delegate = self
        presenter?.configureCell(imageListCell, at: indexPath.row)

        return imageListCell
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        presenter?.didTapOnTableRow(at: indexPath.row)
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        presenter?.calculateHeightForRow(
            at: indexPath.row,
            tableViewWidth: tableView.bounds.width
        ) ?? 0
    }

    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        presenter?.willDisplayCell(indexRow: indexPath.row)
    }
}
// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    func imagesListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.didTapCellLike(index: indexPath.row)
    }
}

#Preview {
    ImagesListViewController()
}
