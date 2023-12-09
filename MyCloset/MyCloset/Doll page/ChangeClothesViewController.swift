//
//  ChangeClothesViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/21.
//

import UIKit
import SnapKit

class ChangeClothesViewController: UIViewController {
    var tableView = UITableView()
    var imageViewDoll = UIImageView()
    var imageViewChanging = UIImageView()
    var imageArray: [UIImage] = []
    var currentIndex = 0
    var timer: Timer?
    
    let buttonTitle = ["Tops", "Bottoms", "Accessories"]
    var clothes = CoreDataManager.shared.fetchAllCategoriesAndSubcategories()
    var sectionAll: [[Section]] = []
    var sections: [Section] = []
    var dollParts: [String: UIImageView] = [:]
    var segmentesIndex: Int = 0
    var selectedItems: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        makeSectionArray()
        tableView.reloadData()
        let image1 = UIImage(named: "changing01") ?? UIImage()
        let image2 = UIImage(named: "changing02") ?? UIImage()
        imageArray = [image1, image2]
        timer = Timer.scheduledTimer(
            timeInterval: 0.5, target: self, selector: #selector(switchImage),
            userInfo: nil, repeats: true)
    }
    
    @objc func switchImage() {
            imageViewChanging.image = imageArray[currentIndex]
            currentIndex += 1
            if currentIndex >= imageArray.count {
                currentIndex = 0
            }
        }
        deinit {
            timer?.invalidate()
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sections = []
        sectionAll = []
        clothes = CoreDataManager.shared.fetchAllCategoriesAndSubcategories()
        makeSectionArray()
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.imageViewChanging.isHidden = false
        }
        let hair = CoreDataManager.shared.fetchHair()
        if hair == nil {
            imageViewDoll.image = UIImage(named: "doll")
            DispatchQueue.main.async {
                self.imageViewChanging.isHidden = true
            }
        } else {
            let colorui = UIColor(
                red: hair?.color[0] ?? 0, green: hair?.color[1] ?? 0,
                blue: hair?.color[2] ?? 0, alpha: 1)
            let dollImage = mergeImagesDoll(
                imageSB: hair?.hairB ?? [],
                imageS: hair?.hair ?? [], color: colorui)
            imageViewDoll.image = dollImage
            DispatchQueue.main.async {
                self.imageViewChanging.isHidden = true
            }
        }
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
            } else {
                sectionAll.append([])
            }
        }
        if !sectionAll.isEmpty {
            self.sections = sectionAll[0]
        }
        self.tableView.reloadData()
    }
    
}

extension ChangeClothesViewController : UITableViewDelegate, UITableViewDataSource {
    
    func setup() {
        tabBarController?.tabBar.backgroundColor = .white
        view.backgroundColor = .white
        navigationItem.title = "Change clothes"
        navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor.lightBrown(),
         NSAttributedString.Key.font: UIFont.roundedFont(ofSize: 20)]
        // Set up doll parts
        view.addSubview(imageViewDoll)
        view.addSubview(imageViewChanging)
        imageViewChanging.image = UIImage(named: "changing01")
//        imageViewChanging.isHidden = true
        setupConstraints(for: imageViewDoll)
        setupConstraints(for: imageViewChanging)
        addGestures(imageView: imageViewDoll)

        let codeSegmented = SegmentView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44), buttonTitle: buttonTitle)
        view.addSubview(codeSegmented)
        codeSegmented.backgroundColor = UIColor.lightLightBrown()
        codeSegmented.delegate = self
        codeSegmented.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            codeSegmented.topAnchor.constraint(equalTo: imageViewDoll.bottomAnchor, constant: -20),
            codeSegmented.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            codeSegmented.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            codeSegmented.heightAnchor.constraint(equalToConstant: 44)
        ])
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ClosetPageCell.self, forCellReuseIdentifier: "ClosetPageCell")
        tableView.tableFooterView = UIView()
        tableView.snp.makeConstraints { make in
            make.top.equalTo(codeSegmented.snp.bottom).offset(1)
            make.leading.trailing.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        let mineButton = UIBarButtonItem(
            title: "Mine", style: .plain, target: self,
            action: #selector(mineButtonTapped))
        let hairButton = UIBarButtonItem(
            title: "   Hair", style: .plain, target: self,
            action: #selector(hairButtonTapped))
        mineButton.tintColor = UIColor.lightBrown()
        hairButton.tintColor = UIColor.lightBrown()
        navigationItem.leftBarButtonItems = [mineButton, hairButton]
        let saveButton = UIBarButtonItem(
            title: "save", style: .plain, target: self,
            action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem = saveButton
        saveButton.tintColor = UIColor.lightBrown()
    }
    
    @objc func hairButtonTapped() {
        let secondViewController = PaperDollHairViewController()
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    @objc func mineButtonTapped() {
        let secondViewController = MineDollViewController()
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    @objc func saveButtonTapped() {
        if let dollImage = imageViewDoll.asImage() {
            guard let imageData = dollImage.jpegData(compressionQuality: 0.5) else {
                return
            }
            let name = UUID().uuidString
            CoreDataManager.shared.saveMineData(image: imageData, selectedItem: self.selectedItems, uuid: name)
        }
    }
    
    func setupConstraints(for imageView: UIImageView) {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: view.bounds.width),
            imageView.heightAnchor.constraint(equalToConstant: 400)
        ])
    }
    
    func addGestures(imageView: UIImageView) {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(pinchGesture)
        imageView.addGestureRecognizer(panGesture)
    }
    
    @objc func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        guard let imageView = gesture.view as? UIImageView else { return }
        
        if gesture.state == .changed {
            let pinchScale: CGFloat = gesture.scale
            imageView.transform = imageView.transform.scaledBy(x: pinchScale, y: pinchScale)
            gesture.scale = 1.0
        }
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let imageView = gesture.view as? UIImageView else { return }
        
        if gesture.state == .changed {
            let translation = gesture.translation(in: imageView.superview)
            imageView.center = CGPoint(x: imageView.center.x + translation.x, y: imageView.center.y + translation.y)
            gesture.setTranslation(CGPoint.zero, in: imageView.superview)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].isExpanded ? sections[section].items.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ClosetPageCell",
            for: indexPath) as? ClosetPageCell else {
            fatalError("Cant find cell")
        }
        if let imageData = sections[indexPath.section].items[indexPath.row].image {
            cell.configure(
                with: imageData ,
                name: sections[indexPath.section].items[indexPath.row].item ?? "")
            cell.index = segmentesIndex
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
        if !(sections[indexPath.section].items[indexPath.row].cloth?.isEmpty ?? true) {
            imageViewChanging.isHidden = false
            let name = sections[indexPath.section].items[indexPath.row].item ?? ""
            removeImageViewFromDoll(name: name)
            if selectedItems.contains(name) == false {
                selectedItems.append(name)
            }
            print(selectedItems)
            addButtonTag(items: selectedItems)
            DispatchQueue.global().async {
                self.addImageViewToDoll(name: name,
                     imageNameArrayB: self.sections[indexPath.section].items[indexPath.row].clothB ?? [],
                     imageNameArray: self.sections[indexPath.section].items[indexPath.row].cloth ?? [],
                     color: self.sections[indexPath.section].items[indexPath.row].color ?? [1.0, 1.0, 1.0])
            }
        }
    }
    
    func addButtonTag(items: [String]) {
        clearButtons()
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .trailing
        stackView.spacing = 8
        
        for item in items {
            let button = UIButton()
            button.setTitle(item, for: .normal)
            button.setTitleColor(.brown, for: .normal)
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            button.backgroundColor = UIColor.lightLightBrown()
            button.layer.cornerRadius = 15
            let titleWidth = button.titleLabel?.intrinsicContentSize.width ?? 0
            button.translatesAutoresizingMaskIntoConstraints = false
            button.widthAnchor.constraint(equalToConstant: titleWidth + 20).isActive = true
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
            button.addGestureRecognizer(longPressGesture)
            button.layer.borderColor = UIColor.white.cgColor
            button.layer.borderWidth = 2
            
            stackView.addArrangedSubview(button)
        }
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailingMargin).offset(-16)
        }
    }
    
    @objc func longPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            guard let button = gesture.view as? UIButton else {
                return
            }
            selectedItems.removeAll { $0 == button.currentTitle }
            removeImageViewFromDoll(name: button.currentTitle!)
            addButtonTag(items: selectedItems)
        }
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        imageViewDoll.bringSubviewToFront(dollParts[sender.currentTitle ?? ""]! )
    }
    
    func clearButtons() {
        for subview in view.subviews {
            if let stackView = subview as? UIStackView {
                stackView.removeFromSuperview()
            }
        }
    }
    
    func addImageViewToDoll(name: String, imageNameArrayB: [String], imageNameArray: [String], color: [CGFloat]) {
        let colorui = UIColor(red: color[0], green: color[1], blue: color[2], alpha: 1)
        if let image = mergeImages(imageSB: imageNameArrayB, imageS: imageNameArray, color: colorui) {
            DispatchQueue.main.async {
                self.setupDollPart(imageView: &self.dollParts[name], imageName: image)
                self.imageViewChanging.isHidden = true
            }
        } else {
            print("圖片合成失敗")
            DispatchQueue.main.async {
                self.imageViewChanging.isHidden = true
            }
        }
    }
    
    func removeImageViewFromDoll(name: String) {
        dollParts[name]?.removeFromSuperview()
    }
    
    func mergeImages(imageSB: [String], imageS: [String], color: UIColor) -> UIImage? {
        var totalSize = CGSize.zero
        let image = UIImage(named: imageS[0])
        totalSize.width = max(totalSize.width, image?.size.width ?? 0)
        totalSize.height = image?.size.height ?? 0
        
        UIGraphicsBeginImageContextWithOptions(totalSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        for string in imageSB {
            let image = UIImage(named: string)?.withTintColor(color)
            image?.draw(at: CGPoint(x: 0, y: 0))
        }
        for string in imageS {
            let image = UIImage(named: string)
            image?.draw(at: CGPoint(x: 0, y: 0))
        }
        let mergedImage = UIGraphicsGetImageFromCurrentImageContext()
        return mergedImage
    }
        
    func mergeImagesDoll(imageSB: [String], imageS: [String], color: UIColor) -> UIImage? {
        print("qqqqq",imageSB, imageS, color)
        var totalSize = CGSize.zero
        let image = UIImage(named: "無")?.withTintColor(color)
        totalSize.width = max(totalSize.width, image?.size.width ?? 0)
        totalSize.height = image?.size.height ?? 0
        
        UIGraphicsBeginImageContextWithOptions(totalSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        UIImage(named: imageSB[1])?.withTintColor(color).draw(at: CGPoint(x: 0, y: 0))
        UIImage(named: imageS[1])?.draw(at: CGPoint(x: 0, y: 0))
        UIImage(named: "娃娃2B")?.draw(at: CGPoint(x: 0, y: 0))
        UIImage(named: "娃娃2")?.draw(at: CGPoint(x: 0, y: 0))
        UIImage(named: imageSB[0])?.withTintColor(color).draw(at: CGPoint(x: 0, y: 0))
        UIImage(named: imageS[0])?.draw(at: CGPoint(x: 0, y: 0))
        let mergedImage = UIGraphicsGetImageFromCurrentImageContext()
        return mergedImage
    }
        
    func setupDollPart(imageView: inout UIImageView?, imageName: UIImage) {
        imageView = UIImageView()
        imageView?.isUserInteractionEnabled = true
        imageView?.contentMode = .scaleAspectFit
        imageView?.image = imageName
        imageViewDoll.addSubview(imageView!)
        setupConstraints(for: imageView!)
    }
    
    @objc func headerTapped(_ sender: UITapGestureRecognizer) {
        if let section = sender.view?.tag {
            sections[section].isExpanded.toggle()
            tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        }
    }
}

extension ChangeClothesViewController: SegmentControlDelegate {
    func changeToIndex(_ manager: SegmentView, index: Int) {
        segmentesIndex = index
        //        if index >= 0 && index < sectionAll.count && !self.sectionAll[index].isEmpty {
        self.sections = self.sectionAll[index]
        self.tableView.reloadData()
        //        }
    }
}


