//
//  MyClosetDetailPageViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/18.
//

import UIKit
import SnapKit

class MyClosetDetailPageViewController: UIViewController {
    var cloth: ClothesStruct?
    var dollButton = UIButton()
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 15
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    var descriptionLabel = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let leftButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward.circle"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = leftButton
        leftButton.tintColor = UIColor.brown
        let rightButton = UIBarButtonItem(image: UIImage(systemName: "pencil.circle"), style: .plain, target: self, action: #selector(editButtonTapped))
        navigationItem.rightBarButtonItem = rightButton
        rightButton.tintColor = UIColor.brown
        navigationItem.title = (cloth?.category)! + "/" + (cloth?.subcategory)!
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.brown, NSAttributedString.Key.font: UIFont.roundedFont(ofSize: 20)]
        setup()
    }

    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func editButtonTapped() {
        print("edit")
    }
    
    func setup() {
        view.addSubview(imageView)
        view.addSubview(descriptionLabel)
        view.addSubview(dollButton)
        if let image = cloth?.image {
            imageView.image = UIImage(data: image)
        }
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalTo(view).offset(50)
            make.trailing.equalTo(view).offset(-50)
            make.height.equalTo(imageView.snp.width)
        }
        
        var text = ""
        if let item = cloth?.item {
            text += ("品項： " + item + "\n")
        }
        if let store = cloth?.store {
            text += ("店家： " + store + "\n")
        }
        if let price = cloth?.price {
            text += ("價格： " + price + "\n")
        }
        if let content = cloth?.content {
            text += ("其他： " + content + "\n")
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(50)
            make.centerX.equalTo(view)
            make.leading.equalTo(view).offset(50)
            make.trailing.equalTo(view).offset(-50)
        }
        descriptionLabel.text = text
        descriptionLabel.numberOfLines = 0
    
        dollButton.setTitle("紙娃娃試穿", for: .normal)
        dollButton.setTitleColor(.brown, for: .normal)
        dollButton.addTarget(self, action: #selector(dollButtonTapped), for: .touchUpInside)
        dollButton.backgroundColor = UIColor.lightLightBrown()
        dollButton.layer.cornerRadius = 10
        dollButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(50)
            make.width.equalTo(150)
            make.height.equalTo(40)
            make.centerX.equalTo(view)
        }
    }
    @objc func dollButtonTapped() {
        switch (cloth?.category)! {
        case "Tops":
            let secondViewController = TopsChosenViewController()
            secondViewController.cloth = cloth
            navigationController?.pushViewController(secondViewController, animated: true)
        case "Bottoms":
            let secondViewController = PaperDollBottomsViewController()
            secondViewController.cloth = cloth
            navigationController?.pushViewController(secondViewController, animated: true)
        case "Accessories": print("Accessories")
        default: print("default")
        }
        
    }
}


