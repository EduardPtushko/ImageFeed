//
//  ViewController.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 24.07.2026.
//

import UIKit

final class ImagesListViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 200
        tableView.backgroundColor = UIColor(resource: .ypBlack)
        tableView.separatorStyle = .none
        return tableView
    }()

    // MARK: - Properties

    private let photosName: [String] = Array(0..<20).map { "\($0)" }

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

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

    private let showSingleImageSegueIdentifier = "ShowSingleImage"

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
    }

}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        photosName.count
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

        imageListCell.configure(
            image: UIImage(named: photosName[indexPath.row]),
            date: dateFormatter.string(from: Date()),
            isLiked: indexPath.row % 2 == 0
        )

        return imageListCell
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {

        let viewController = SingleImageViewController()
        let image = UIImage(named: photosName[indexPath.row])
        viewController.image = image
        viewController.modalPresentationStyle = .fullScreen

        present(viewController, animated: true)
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }
        guard image.size.width > 0 else { return 0 }

        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth =
            tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight =
            image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

#Preview {
    ImagesListViewController()
}
