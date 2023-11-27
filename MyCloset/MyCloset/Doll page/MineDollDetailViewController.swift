//
//  MineDollDetailViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/27.
//

import UIKit
import SnapKit

class MineDollDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var mineDoll: Mine? {
        didSet {
            headerImageView.image = UIImage(data: (mineDoll?.myWearing)!)
            self.tableView.reloadData()
        }
    }
    
    let tableView = UITableView()
    
    let headerImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "YourHeaderImage"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
    }
    
    // MARK: - Setup
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(MineDollClothesViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.tableHeaderView = createTableHeaderView()
        
        let deleteButton = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(deleteButtonTapped))
        deleteButton.tintColor = UIColor.lightBrown()
        let saveButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up.fill"), style: .plain, target: self, action: #selector(saveButtonTapped))
        saveButton.tintColor = UIColor.lightBrown()
        let saveToAlbum = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveToAlbumTapped))
        saveToAlbum.tintColor = UIColor.lightBrown()
        navigationItem.rightBarButtonItems = [saveToAlbum, saveButton, deleteButton]
        let leftButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward.circle"), style: .plain, target: self, action: #selector(backButtonTapped))
            navigationItem.leftBarButtonItem = leftButton
            leftButton.tintColor = UIColor.lightBrown()
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func saveToAlbumTapped() {
        guard let imageToSave = headerImageView.image else {
            print("No image to save.")
            return
        }
        UIImageWriteToSavedPhotosAlbum(imageToSave, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error saving image: \(error.localizedDescription)")
        } else {
            print("Image saved successfully.")
        }
    }
    
    @objc func saveButtonTapped() {
        guard let imageToExport = headerImageView.image else {
            print("No image to save.")
            return
        }
        
        let activityViewController = UIActivityViewController(activityItems: [imageToExport], applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(activityViewController, animated: true, completion: nil)
    }
    
    
    @objc func deleteButtonTapped() {
        if let uid = mineDoll?.name {
            CoreDataManager.shared.deleteMine(uuid: uid)
            navigationController?.popViewController(animated: true)
        }
    }
    
    func createTableHeaderView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width*1.2))
        headerView.addSubview(headerImageView)
        headerImageView.contentMode = .scaleAspectFill
        NSLayoutConstraint.activate([
            headerImageView.topAnchor.constraint(equalTo: headerView.topAnchor),
            headerImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            headerImageView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            headerImageView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])
        
        return headerView
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mineDoll?.wearing?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? MineDollClothesViewCell else {
            fatalError("Cant find cell")
        }
        cell.label.text = mineDoll?.wearing?[indexPath.row] as? String
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let itemName = mineDoll?.wearing?[indexPath.row] as? String {
            if let result = CoreDataManager.shared.fetchSpecificClothes(name: itemName) {
                let secondViewController = MyClosetDetailPageViewController()
                secondViewController.cloth = result
                self.navigationController?.pushViewController(secondViewController, animated: true)
            }
        }
    }
}

import UIKit

class MineDollClothesViewCell: UITableViewCell {

    let label = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(label)
        label.textColor = .brown
        label.font = UIFont.systemFont(ofSize: 20)
        label.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.leading.equalTo(contentView).offset(30)
            make.top.equalTo(contentView).offset(8)
            make.bottom.equalTo(contentView).offset(-8)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


