//
//  MyClosetPageViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/17.
//

import UIKit
import SnapKit
import CoreData
struct Section {
    var title: String
    var isExpanded: Bool
    var items: [ClothesStruct]
}

class MyClosetPageViewController: UIViewController {
    var tableView = UITableView()
    let buttonTitle = ["Tops","Bottoms","Accessories"]
    var clothes = CoreDataManager.shared.fetchAllCategoriesAndSubcategories()
    var sectionAll : [[Section]] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        clothes = CoreDataManager.shared.fetchAllCategoriesAndSubcategories()
        makeSectionArray()
        tableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sections = []
        sectionAll = []
        clothes = CoreDataManager.shared.fetchAllCategoriesAndSubcategories()
        makeSectionArray()
        tableView.reloadData()
    }
    
    @objc func addButtonTapped() {
        let nextViewController = AddMyClosetViewController()
        navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @objc func heartButtonTapped() {
        print("heart")
    }
    
    func makeSectionArray() {
        for title in buttonTitle {
            if let subcategories = clothes[title] {
                var sectionsForCategory: [Section] = []
                for (_, subcategory) in subcategories.enumerated() {
                    let items = CoreDataManager.shared.fetchClothesFor(category: title, subcategory: subcategory)
                    let section = Section(title: "\(subcategory)", isExpanded: false, items: items)
                    sectionsForCategory.append(section)
                }
                sectionAll.append(sectionsForCategory)
            }
        }
        self.sections = sectionAll[0]
        self.tableView.reloadData()
    }
    
    
    var sections: [Section] = []
    
}

extension MyClosetPageViewController : UITableViewDelegate, UITableViewDataSource {
    
    func setup() {
        view.backgroundColor = .white
        let addButton = UIBarButtonItem(title: "+ add", style: .plain, target: self, action: #selector(addButtonTapped))
        addButton.tintColor = UIColor.lightBrown()
        navigationItem.rightBarButtonItem = addButton
        let leftButton = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(heartButtonTapped))
        navigationItem.leftBarButtonItem = leftButton
        leftButton.tintColor = UIColor.lightBrown()
        navigationItem.title = "My Closet"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightBrown(), NSAttributedString.Key.font: UIFont.roundedFont(ofSize: 20)]
        let codeSegmented = SegmentView(frame: CGRect(x: 0, y: 100, width: self.view.frame.width, height: 44), buttonTitle: buttonTitle)
        codeSegmented.backgroundColor = UIColor.white
        codeSegmented.delegate = self
        view.addSubview(codeSegmented)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ClosetPageCell.self, forCellReuseIdentifier: "ClosetPageCell")
        tableView.tableFooterView = UIView() // To hide empty cell separators
        tableView.snp.makeConstraints { make in
            make.top.equalTo(codeSegmented.snp.bottom).offset(2)
            make.leading.trailing.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].isExpanded ? sections[section].items.count : 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClosetPageCell", for: indexPath) as? ClosetPageCell else {
            fatalError("Cant find cell")
        }
        if let imageData = sections[indexPath.section].items[indexPath.row].image {
            cell.configure(with: imageData , name: sections[indexPath.section].items[indexPath.row].item ?? "")
        } else {
            cell.configureWithoutImage(name: sections[indexPath.section].items[indexPath.row].item ?? "")
        }
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.lightLightBrown()

        let titleLabel = UILabel()
        titleLabel.text = sections[section].title
        titleLabel.textColor = UIColor.brown
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.frame = CGRect(x: 16, y: 0, width: view.frame.width - 32, height: 44)
        headerView.addSubview(titleLabel)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerTapped(_:)))
        headerView.addGestureRecognizer(tapGesture)

        headerView.tag = section
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(sections[indexPath.section].items[indexPath.row].cloth)
        let selectedIndexPath = tableView.indexPathForSelectedRow
        tableView.deselectRow(at: selectedIndexPath!, animated: true)
        let secondViewController = MyClosetDetailPageViewController()
        secondViewController.cloth = sections[indexPath.section].items[indexPath.row]
        navigationController?.pushViewController(secondViewController, animated: true)
    }

    @objc func headerTapped(_ sender: UITapGestureRecognizer) {
        if let section = sender.view?.tag {
            sections[section].isExpanded.toggle()
            tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        }
    }
}

extension MyClosetPageViewController: SegmentControlDelegate {
    func changeToIndex(_ manager: SegmentView, index: Int) {
        self.sections = self.sectionAll[index]
        self.tableView.reloadData()
    }
}

class ClosetPageCell: UITableViewCell {
    let circularImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.roundedFont(ofSize: 18)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(circularImageView)
        contentView.addSubview(nameLabel)

        circularImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(3)
            make.leading.equalTo(contentView).offset(16)
            make.centerY.equalTo(contentView)
            make.width.height.equalTo(50)
            make.bottom.equalTo(contentView).offset(-3)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(circularImageView.snp.trailing).offset(16)
            make.centerY.equalTo(contentView)
        }
    }

    func configure(with imageData: Data, name: String) {
        circularImageView.image = UIImage(data: imageData)
        nameLabel.text = name
    }
    
    func configureWithoutImage(name: String) {
        circularImageView.image = UIImage(named: "download20231105155350")
        nameLabel.text = name
    }
}

