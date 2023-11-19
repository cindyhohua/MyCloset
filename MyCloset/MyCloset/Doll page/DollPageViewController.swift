//
//  DollPageViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/18.
//

import UIKit
import SnapKit
struct DollCloth {
    let outer: String
    let bottom: String
    let name: String
}

class PaperDollViewController: UIViewController{

    var dollParts: [String: UIImageView] = [:]

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    var colorPickerView = ColorPickerView()
    
    var outfitss: [[DollCloth]]?
    var outfits: [DollCloth]?
    
    var selected: [DollCloth]?
    var selectedColor: UIColor = .white
    
    let codeSegmented = SegmentView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44), buttonTitle: ["領口","袖子","衣襬","圖案","顏色"])

    let neckline: [DollCloth] = [
        DollCloth(outer: "領口1", bottom: "B領口1", name: "neckline"),
        DollCloth(outer: "領口2", bottom: "B領口2", name: "neckline"),
        DollCloth(outer: "領口3", bottom: "B領口3", name: "neckline"),
        DollCloth(outer: "領口4", bottom: "B領口4", name: "neckline")
    ]
    
    let sleeve: [DollCloth] = [
        DollCloth(outer: "袖子1", bottom: "B袖子1", name: "sleeve"),
        DollCloth(outer: "袖子2", bottom: "B袖子2", name: "sleeve"),
        DollCloth(outer: "袖子3", bottom: "B袖子3", name: "sleeve"),
        DollCloth(outer: "袖子4", bottom: "B袖子4", name: "sleeve")
    ]
    
    let hem: [DollCloth] = [
        DollCloth(outer: "衣襬1", bottom: "B衣襬1", name: "hem"),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupCV()
        outfitss = [neckline, sleeve, hem]
        outfits = outfitss?[0]
        selected = [neckline[0], sleeve[0], hem[0]]
    }

    func setupViews() {
        view.backgroundColor = .white
        let addButton = UIBarButtonItem(title: "+ add", style: .plain, target: self, action: #selector(addButtonTapped))
        addButton.tintColor = UIColor.lightBrown()
        navigationItem.rightBarButtonItem = addButton
        let leftButton = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(heartButtonTapped))
        navigationItem.leftBarButtonItem = leftButton
        leftButton.tintColor = UIColor.lightBrown()
        navigationItem.title = "My Closet"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightBrown(), NSAttributedString.Key.font: UIFont.roundedFont(ofSize: 20)]
        // Set up doll parts
        setupDollPart(imageView: &dollParts["doll"], imageName: "doll", tintColor: nil)
        //bottom
        setupDollPart(imageView: &dollParts["Bbottom"], imageName: "B下身2", tintColor: selectedColor)
        setupDollPart(imageView: &dollParts["bottom"], imageName: "下身2", tintColor: nil)
        //tops
        setupDollPart(imageView: &dollParts["Bsleeve"], imageName: "B袖子1", tintColor: selectedColor)
        setupDollPart(imageView: &dollParts["Bneckline"], imageName: "B領口1", tintColor: selectedColor)
        setupDollPart(imageView: &dollParts["Bhem"], imageName: "B衣襬1", tintColor: selectedColor)
        setupDollPart(imageView: &dollParts["sleeve"], imageName: "袖子1", tintColor: nil)
        setupDollPart(imageView: &dollParts["neckline"], imageName: "領口1", tintColor: nil)
        setupDollPart(imageView: &dollParts["hem"], imageName: "衣襬1", tintColor: nil)
    }
    
    @objc func addButtonTapped() {
        let nextViewController = AddMyClosetViewController()
        navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @objc func heartButtonTapped() {
        print("heart")
    }

    func setupDollPart(imageView: inout UIImageView?, imageName: String, tintColor: UIColor?) {
        imageView = UIImageView()
        imageView?.contentMode = .scaleAspectFit
        if tintColor == nil {
            imageView?.image = UIImage(named: imageName)
        } else {
            imageView?.image = UIImage(named: imageName)?.withTintColor(tintColor ?? .white)
        }
        view.addSubview(imageView!)
        setupConstraints(for: imageView!)
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
}


extension PaperDollViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SegmentControlDelegate, ColorPickerViewDelegate {
    func didSelectColor(_ color: UIColor) {
        selectedColor = color
        if let bImageView = dollParts["B"+(selected?[0].name ?? "")] {
            bImageView.image = UIImage(named: (selected?[0].bottom)!)?.withTintColor(color)
        }
        if let bImageView = dollParts["B"+(selected?[1].name ?? "")] {
            bImageView.image = UIImage(named: (selected?[1].bottom)!)?.withTintColor(color)
        }
        if let bImageView = dollParts["B"+(selected?[2].name ?? "")] {
            bImageView.image = UIImage(named: (selected?[2].bottom)!)?.withTintColor(color)
        }
        
        
    }
    
    func changeToIndex(_ manager: SegmentView, index: Int) {
        if index < outfitss?.count ?? 0 {
            outfits = outfitss?[index]
            collectionView.reloadData()
            colorPickerView.removeFromSuperview()
        } else if index == 4 {
            view.addSubview(colorPickerView)
            colorPickerView.backgroundColor = .blue
            colorPickerView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                colorPickerView.topAnchor.constraint(equalTo: collectionView.topAnchor),
                colorPickerView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
                colorPickerView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
                colorPickerView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor)
            ])
        }
    }

    func setupCV() {
        colorPickerView.delegate = self
        codeSegmented.backgroundColor = UIColor.lightLightBrown()
        codeSegmented.delegate = self
        view.addSubview(codeSegmented)
        view.addSubview(collectionView)
        codeSegmented.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            codeSegmented.topAnchor.constraint(equalTo: dollParts["doll"]!.bottomAnchor, constant: -20),
            codeSegmented.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            codeSegmented.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            codeSegmented.heightAnchor.constraint(equalToConstant: 44)
        ])

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: codeSegmented.bottomAnchor, constant: 2),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.register(OutfitCollectionViewCell.self, forCellWithReuseIdentifier: OutfitCollectionViewCell.reuseIdentifier)

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10

        let cellWidth = (UIScreen.main.bounds.width - layout.minimumInteritemSpacing * 2 - layout.sectionInset.left - layout.sectionInset.right) / 3
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth)

        layout.sectionInset = UIEdgeInsets(top: 10, left: (UIScreen.main.bounds.width - cellWidth * 3 - layout.minimumInteritemSpacing * 2) / 2, bottom: 10, right: (UIScreen.main.bounds.width - cellWidth * 3 - layout.minimumInteritemSpacing * 2) / 2)

        collectionView.collectionViewLayout = layout
    }

    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return outfits?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OutfitCollectionViewCell.reuseIdentifier, for: indexPath) as! OutfitCollectionViewCell
        if let outfit = outfits?[indexPath.item] {
            cell.configure(with: outfit)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.width - 30) / 3 // 考慮到兩側的 insets 和間距
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Handle the selection of an outfit
        if let selectedOutfit = outfits?[indexPath.item] {
            updateDollImage(with: selectedOutfit)
        }
    }
    
    func updateDollImage(with: DollCloth) {
        if let bImageView = dollParts["B"+with.name] {
            bImageView.image = UIImage(named: with.bottom)?.withTintColor(selectedColor)
        }
        if let imageView = dollParts[with.name] {
            imageView.image = UIImage(named: with.outer)
        }
        if with.name == "neckline" {
            selected?[0] = with
        } else if with.name == "sleeve" {
            selected?[1] = with
        } else if with.name == "hem" {
            selected?[2] = with
        }
    }
}

