//
//  DollPageViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/18.
//

import UIKit
import SnapKit

class PaperDollBottomsViewController: UIViewController{
    var cloth: ClothesStruct?

    var dollParts: [String: UIImageView] = [:]
    
    var imageViewDoll = UIImageView()
    
    var imageViewReal = UIImageView()

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
    
    let codeSegmented = SegmentView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44), buttonTitle: ["褲頭","褲子","顏色"])

    var neckline: [DollCloth] = [
        DollCloth(outer: "褲頭1", bottom: "B褲頭1", name: "neckline"),
        DollCloth(outer: "褲頭2", bottom: "B褲頭2", name: "neckline"),
        DollCloth(outer: "褲頭3", bottom: "B褲頭3", name: "neckline"),
        DollCloth(outer: "褲頭4", bottom: "B褲頭4", name: "neckline")
    ]
    
    var sleeve: [DollCloth] = [
        DollCloth(outer: "褲子1", bottom: "B褲子1", name: "sleeve"),
        DollCloth(outer: "褲子2", bottom: "B褲子2", name: "sleeve"),
        DollCloth(outer: "褲子3", bottom: "B褲子3", name: "sleeve"),
        DollCloth(outer: "褲子4", bottom: "B褲子4", name: "sleeve"),
        DollCloth(outer: "褲子5", bottom: "B褲子5", name: "sleeve"),
        DollCloth(outer: "褲子6", bottom: "B褲子6", name: "sleeve"),
        DollCloth(outer: "褲子7", bottom: "B褲子7", name: "sleeve"),
        DollCloth(outer: "褲子8", bottom: "B褲子8", name: "sleeve"),
        DollCloth(outer: "褲子9", bottom: "B褲子9", name: "sleeve"),
        DollCloth(outer: "褲子10", bottom: "B褲子10", name: "sleeve"),
        DollCloth(outer: "褲子11", bottom: "B褲子11", name: "sleeve"),
        DollCloth(outer: "褲子12", bottom: "B褲子12", name: "sleeve"),
        DollCloth(outer: "褲子13", bottom: "B褲子13", name: "sleeve"),
        DollCloth(outer: "褲子14", bottom: "B褲子14", name: "sleeve"),
        DollCloth(outer: "褲子15", bottom: "B褲子15", name: "sleeve"),
        DollCloth(outer: "褲子16", bottom: "B褲子16", name: "sleeve")
    ]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupCV()
        outfitss = [neckline, sleeve]
        outfits = outfitss?[0]
        selected = [neckline[0], sleeve[0]]
    }

    func setupViews() {
        tabBarController?.tabBar.backgroundColor = .white
        view.backgroundColor = .white
        let addButton = UIBarButtonItem(title: "save", style: .plain, target: self, action: #selector(addButtonTapped))
        addButton.tintColor = UIColor.lightBrown()
        navigationItem.rightBarButtonItem = addButton
        let leftButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward.circle"), style: .plain, target: self, action: #selector(backButtonTapped))
            navigationItem.leftBarButtonItem = leftButton
            leftButton.tintColor = UIColor.lightBrown()
        navigationItem.title = "My Closet"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightBrown(), NSAttributedString.Key.font: UIFont.roundedFont(ofSize: 20)]
        // Set up doll parts
        view.addSubview(imageViewDoll)
        imageViewDoll.image = UIImage(named: "doll")
        setupConstraints(for: imageViewDoll)
        addGestures(imageView: imageViewDoll)

        setupDollPart(imageView: &dollParts["bottom"], imageName: "上衣", tintColor: nil)
        //tops
        setupDollPart(imageView: &dollParts["Bsleeve"], imageName: sleeve[0].bottom, tintColor: selectedColor)
        setupDollPart(imageView: &dollParts["Bneckline"], imageName: neckline[0].bottom, tintColor: selectedColor)
        setupDollPart(imageView: &dollParts["sleeve"], imageName: sleeve[0].outer, tintColor: nil)
        setupDollPart(imageView: &dollParts["neckline"], imageName: neckline[0].outer, tintColor: nil)
        
        view.addSubview(imageViewReal)
        if let clothImage = cloth?.image {
            imageViewReal.image = UIImage(data: clothImage)
            imageViewReal.contentMode = .scaleAspectFill
        }
        imageViewReal.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(5)
            make.trailing.equalTo(view).offset(-5)
            make.width.height.equalTo(120)
        }
        imageViewReal.clipsToBounds = true
        imageViewReal.layer.cornerRadius = 60
    }
    
    @objc func addButtonTapped() {
        let nextViewController = AddMyClosetViewController()
        navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    func setupDollPart(imageView: inout UIImageView?, imageName: String, tintColor: UIColor?) {
        imageView = UIImageView()
        imageView?.isUserInteractionEnabled = true
        imageView?.contentMode = .scaleAspectFit
        imageView?.image = (tintColor == nil) ? UIImage(named: imageName) : UIImage(named: imageName)?.withTintColor(tintColor ?? .white)
        imageViewDoll.addSubview(imageView!)
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
}


extension PaperDollBottomsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SegmentControlDelegate, ColorPickerViewDelegate {
    func didSelectColor(_ color: UIColor) {
        selectedColor = color
        guard let selected = selected else { return }
        
        for part in selected {
            guard let bImageView = dollParts["B" + part.name] else { continue }
            bImageView.image = UIImage(named: part.bottom)?.withTintColor(color)
        }
    }
    
    func changeToIndex(_ manager: SegmentView, index: Int) {
        if index < outfitss?.count ?? 0 {
            outfits = outfitss?[index]
            collectionView.reloadData()
            colorPickerView.removeFromSuperview()
        } else if index == 2 {
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
            codeSegmented.topAnchor.constraint(equalTo: dollParts["bottom"]!.bottomAnchor, constant: -20),
            codeSegmented.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            codeSegmented.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            codeSegmented.heightAnchor.constraint(equalToConstant: 44)
        ])

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: codeSegmented.bottomAnchor, constant: 1),
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
        let cellWidth = (collectionView.frame.width - 30) / 3
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Handle the selection of an outfit
        if let selectedOutfit = outfits?[indexPath.item] {
            updateDollImage(with: selectedOutfit)
        }
    }
    
    func updateDollImage(with cloth: DollCloth) {
        guard let bImageView = dollParts["B" + cloth.name] else { return }
        guard let imageView = dollParts[cloth.name] else { return }

        bImageView.image = UIImage(named: cloth.bottom)?.withTintColor(selectedColor)
        imageView.image = UIImage(named: cloth.outer)

        switch cloth.name {
        case "neckline": selected?[0] = cloth
        case "sleeve": selected?[1] = cloth
        default: break
        }
    }

}


