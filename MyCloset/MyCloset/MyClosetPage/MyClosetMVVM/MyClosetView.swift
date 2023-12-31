//
//  MyClosetView.swift
//  MyCloset
//
//  Created by 賀華 on 2023/12/30.
//

import UIKit
import SnapKit
import CoreData
import FirebaseAuth

class MyClosetPageViewController:
    UIViewController, UITabBarControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    var tableView = UITableView()
    var viewModel = MyClosetPageViewModel()
    var segmentIndex = 0
    let codeSegmented = SegmentView(
        frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 44),
        buttonTitle: ["Tops", "Bottoms", "Accessories"])

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureNavigationBar()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    private func configureViewController() {
        view.backgroundColor = .white
        tabBarController?.delegate = self
        
        codeSegmented.delegate = self
        view.addSubview(codeSegmented)
        codeSegmented.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.leading.trailing.equalTo(view)
            make.height.equalTo(44)
        }
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ClosetPageCell.self, forCellReuseIdentifier: "ClosetPageCell")
        tableView.tableFooterView = UIView() // To hide empty cell separators
        tableView.snp.makeConstraints { make in
            make.top.equalTo(codeSegmented.snp.bottom).offset(2)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
    }

    private func configureNavigationBar() {
        let addButton = UIBarButtonItem(title: "+ add", style: .plain, target: self, action: #selector(addButtonTapped))
        addButton.tintColor = UIColor.lightBrown()
        navigationItem.rightBarButtonItem = addButton

        navigationItem.title = "My Closet"
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.lightBrown(),
            NSAttributedString.Key.font: UIFont.roundedFont(ofSize: 20)]
    }

    private func loadData() {
        viewModel.fetchAllCategoriesAndSubcategories()
        viewModel.makeSectionArray(for: 0)
        tableView.reloadData()
    }

    // MARK: - Actions

    @objc private func addButtonTapped() {
        let nextViewController = AddMyClosetViewController()
        navigationController?.pushViewController(nextViewController, animated: true)
    }

    // MARK: - UITabBarControllerDelegate
    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController) -> Bool {
        if viewController.tabBarItem.tag == 2 || viewController.tabBarItem.tag == 3 {
            if Auth.auth().currentUser == nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                present(loginViewController, animated: true)
                return false
            } else {
                return true
            }
        } else {
            return true
        }
    }

    // MARK: - UITableViewDelegate and UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].isExpanded ? viewModel.sections[section].items.count : 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ClosetPageCell",
            for: indexPath) as? ClosetPageCell else {
            fatalError("Can't find ClosetPageCell")
        }
        if let imageData = viewModel.sections[indexPath.section].items[indexPath.row].image {
            if viewModel.sections[indexPath.section].items[indexPath.row].cloth != nil {
                cell.configure(
                    with: imageData,
                    name: viewModel.sections[indexPath.section].items[indexPath.row].item ?? "",
                    clothOrNot: true)
            } else {
                cell.configure(
                    with: imageData,
                    name: viewModel.sections[indexPath.section].items[indexPath.row].item ?? "",
                    clothOrNot: false)
            }
            cell.buttonTapped = { [weak self] in
                let item = self?.viewModel.sections[indexPath.section].items[indexPath.row]
                print("Button tapped in cell with item: \(item?.item ?? "")")
                switch (item?.category)! {
                case "Tops":
                    let secondViewController = TopsChosenViewController()
                    secondViewController.cloth = item
                    self?.navigationController?.pushViewController(secondViewController, animated: true)
                case "Bottoms":
                    let secondViewController = BottomsViewController()
                    secondViewController.cloth = item
                    self?.navigationController?.pushViewController(secondViewController, animated: true)
                case "Accessories":
                    let secondViewController = AccessoriesViewController()
                    secondViewController.cloth = item
                    self?.navigationController?.pushViewController(secondViewController, animated: true)
                default: print("default")
                }
            }
        } else {
            cell.configureWithoutImage(name: viewModel.sections[indexPath.section].items[indexPath.row].item ?? "")
        }
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.lightLightBrown()
        let titleLabel = UILabel()
        titleLabel.text = viewModel.sections[section].title
        titleLabel.textColor = UIColor.brown
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.frame = CGRect(x: 16, y: 0, width: view.frame.width - 32, height: 44)
        headerView.addSubview(titleLabel)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerTapped(_:)))
        headerView.addGestureRecognizer(tapGesture)
        headerView.tag = section
        return headerView
    }
    
    @objc func headerTapped(_ sender: UITapGestureRecognizer) {
        if let section = sender.view?.tag {
            viewModel.sections[section].isExpanded.toggle()
            tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndexPath = tableView.indexPathForSelectedRow
        tableView.deselectRow(at: selectedIndexPath!, animated: true)
        let secondViewController = MyClosetDetailPageViewController()
        secondViewController.cloth = viewModel.sections[indexPath.section].items[indexPath.row]
        navigationController?.pushViewController(secondViewController, animated: true)
    }
}

// MARK: - SegmentControlDelegate

extension MyClosetPageViewController: SegmentControlDelegate {
    func changeToIndex(_ manager: SegmentView, index: Int) {
        segmentIndex = index
        viewModel.makeSectionArray(for: index)
        tableView.reloadData()
    }
}
