//
//  BaseDollPageViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/12/28.
//

import UIKit
import SnapKit
import PencilKit

protocol EditToChangeCloth: AnyObject {
    func editToChangeCloth(cloth: ClothesStruct)
    func hairToChangeCloth()
}

class BaseTopsViewController: UIViewController {
    
    var delegate: EditToChangeCloth?
    
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
    var pencilPickerView = PencilPickerView()
    
    var pencilSelectedColor: UIColor = .white
    var pencilWidth: CGFloat = 5
    let canvasView: PKCanvasView = {
        let canvasView = PKCanvasView()
        canvasView.backgroundColor = .clear
        return canvasView
    }()
    
    var outfitss: [[DollCloth]]?
    var outfits: [DollCloth]?
    
    var selected: [DollCloth]?
    var selectedColor: UIColor = .white
    
    var drawIndex = 4
    var colorChosenIndex = 5
    var cellYPos: CGFloat = 3
    
    var segmentIndex = 0
    
    lazy var codeSegmented = SegmentView(
        frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44),
        buttonTitle: ["領口", "袖子", "衣襬", "圖案", "手繪", "顏色"])

    var neckline: [DollCloth] = [
        DollCloth(outer: "領口1", bottom: "B領口1", name: "neckline"),
        DollCloth(outer: "領口2", bottom: "B領口2", name: "neckline"),
        DollCloth(outer: "領口3", bottom: "B領口3", name: "neckline"),
        DollCloth(outer: "領口4", bottom: "B領口4", name: "neckline")
    ]
    
    var sleeve: [DollCloth] = [
        DollCloth(outer: "袖子1", bottom: "B袖子1", name: "sleeve"),
        DollCloth(outer: "袖子2", bottom: "B袖子2", name: "sleeve"),
        DollCloth(outer: "袖子3", bottom: "B袖子3", name: "sleeve"),
        DollCloth(outer: "袖子4", bottom: "B袖子4", name: "sleeve"),
        DollCloth(outer: "袖子5", bottom: "B袖子5", name: "sleeve")
    ]
    
    var hem: [DollCloth] = [
        DollCloth(outer: "衣襬1", bottom: "B衣襬1", name: "hem"),
        DollCloth(outer: "衣襬2", bottom: "B衣襬2", name: "hem"),
        DollCloth(outer: "衣襬3", bottom: "B衣襬3", name: "hem")
    ]
    
    var pattern: [DollCloth] = [
        DollCloth(outer: "無", bottom: "無", name: "pattern"),
        DollCloth(outer: "圖案1", bottom: "無", name: "pattern"),
        DollCloth(outer: "圖案2", bottom: "無", name: "pattern"),
        DollCloth(outer: "圖案3", bottom: "無", name: "pattern"),
        DollCloth(outer: "圖案4", bottom: "無", name: "pattern")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupCV()
        setupClothes()
    }
    
    func setupClothes() {
        outfitss = [neckline, sleeve, hem, pattern]
        outfits = outfitss?[0]
        selected = [neckline[0], sleeve[0], hem[0], pattern[0]]
        drawIndex = 4
        colorChosenIndex = 5
    }
    
    func setupDollEachPart() {
        setupDollPart(imageView: &dollParts["Bbottom"], imageName: "B下身2", tintColor: selectedColor)
        setupDollPart(imageView: &dollParts["bottom"], imageName: "下身2", tintColor: nil)
        setupDollPart(imageView: &dollParts["Bpattern"], imageName: "無", tintColor: nil)
        setupDollPart(imageView: &dollParts["Bsleeve"], imageName: sleeve[0].bottom, tintColor: selectedColor)
        setupDollPart(imageView: &dollParts["Bneckline"], imageName: neckline[0].bottom, tintColor: selectedColor)
        setupDollPart(imageView: &dollParts["Bhem"], imageName: hem[0].bottom, tintColor: selectedColor)
        setupDollPart(imageView: &dollParts["pattern"], imageName: pattern[0].bottom, tintColor: nil)
        setupDollPart(imageView: &dollParts["sleeve"], imageName: sleeve[0].outer, tintColor: nil)
        setupDollPart(imageView: &dollParts["neckline"], imageName: neckline[0].outer, tintColor: nil)
        setupDollPart(imageView: &dollParts["hem"], imageName: hem[0].outer, tintColor: nil)
    }
    
    func changeClothName(with cloth: DollCloth) {
        switch cloth.name {
        case "neckline": selected?[0] = cloth
        case "sleeve": selected?[1] = cloth
        case "hem": selected?[2] = cloth
        case "pattern": selected?[3] = cloth
        default: break
        }
    }

    func setupViews() {
        tabBarController?.tabBar.backgroundColor = .white
        view.backgroundColor = .white
        let addButton = UIBarButtonItem(title: "save", style: .plain, target: self, action: #selector(addButtonTapped))
        addButton.tintColor = UIColor.lightBrown()
        navigationItem.rightBarButtonItem = addButton
        let leftButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward.circle"),
            style: .plain, target: self, action: #selector(backButtonTapped))
            navigationItem.leftBarButtonItem = leftButton
            leftButton.tintColor = UIColor.lightBrown()
        navigationItem.title = "My Closet"
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.lightBrown(),
            NSAttributedString.Key.font: UIFont.roundedFont(ofSize: 20)]
        // Set up doll parts
        view.addSubview(imageViewDoll)
        imageViewDoll.image = UIImage(named: "doll")
        setupConstraints(for: imageViewDoll)
        addGestures(imageView: imageViewDoll)
        setupDollEachPart()
        
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
        
        imageViewDoll.addSubview(canvasView)
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: imageViewDoll.topAnchor),
            canvasView.leadingAnchor.constraint(equalTo: imageViewDoll.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: imageViewDoll.trailingAnchor),
            canvasView.bottomAnchor.constraint(equalTo: imageViewDoll.bottomAnchor)
        ])
    }
    
    @objc func addButtonTapped() {
        print("add")
        var cloth: [String] = []
        var clothB: [String] = []
        for select in selected! {
            cloth.append(select.outer)
            clothB.append(select.bottom)
        }
        print(cloth, clothB)
        let color = selectedColor
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0

        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        print(red, green, blue)
        print(cloth)
        print(clothB)
        guard let imageData = canvasView.asImage()?.pngData() else {
            return
        }
        CoreDataManager.shared.addClothAndColor(
            category: (self.cloth?.category)!,
            subcategory: (self.cloth?.subcategory)!,
            item: (self.cloth?.item)!, clothArray: cloth,
            clothBArray: clothB, color: [red, green, blue], draw: imageData)
        guard let viewControllers = self.navigationController?.viewControllers else { return }
        for controller in viewControllers {
            if controller is MyClosetPageViewController {
                self.navigationController?.popToViewController(controller, animated: true)
            }
            if controller is ChangeClothesViewController {
                if var clothPass = self.cloth {
                    clothPass.cloth = cloth
                    clothPass.clothB = clothB
                    clothPass.color = [red, green, blue]
                    clothPass.draw = imageData
                    delegate?.editToChangeCloth(cloth: clothPass)
                }
                self.navigationController?.popToViewController(controller, animated: true)
            }
        }
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
        imageView.contentMode = .scaleAspectFill
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
        panGesture.minimumNumberOfTouches = 2
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

extension BaseTopsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SegmentControlDelegate, ColorPickerViewDelegate, PencilPickerViewDelegate {
    func pencilSelectColor(_ color: UIColor) {
        pencilSelectedColor = color
        let newTool = PKInkingTool(.pen, color: color, width: pencilWidth)
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = newTool
    }
    
    func undoAction() {
        print("undo")
        canvasView.undoManager?.undo()
    }
    
    func redoAction() {
        print("redo")
        canvasView.undoManager?.redo()
    }
    
    func thicknessChanged(thickness: CGFloat) {
        pencilWidth = thickness
        print(thickness)
        let newTool = PKInkingTool(.pen, color: pencilSelectedColor, width: thickness)
        canvasView.tool = newTool
    }
    
    func didSelectColor(_ color: UIColor) {
        selectedColor = color
        guard let selected = selected else { return }
        
        for part in selected {
            guard let bImageView = dollParts["B" + part.name] else { continue }
            bImageView.image = UIImage(named: part.bottom)?.withTintColor(color)
        }
    }
    
    func changeToIndex(_ manager: SegmentView, index: Int) {
        segmentIndex = index
        if index < outfitss?.count ?? 0 {
            outfits = outfitss?[index]
            collectionView.reloadData()
            colorPickerView.removeFromSuperview()
            pencilPickerView.removeFromSuperview()
        } else if index == colorChosenIndex {
            view.addSubview(colorPickerView)
            colorPickerView.backgroundColor = .blue
            colorPickerView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                colorPickerView.topAnchor.constraint(equalTo: collectionView.topAnchor),
                colorPickerView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
                colorPickerView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
                colorPickerView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor)
            ])
        } else if index == drawIndex {
            view.addSubview(pencilPickerView)
            pencilPickerView.backgroundColor = .white
            pencilPickerView.delegate = self
            canvasView.tool = PKInkingTool(.pen, color: pencilSelectedColor , width: pencilWidth)
            canvasView.drawingPolicy = .anyInput
            pencilPickerView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                pencilPickerView.topAnchor.constraint(equalTo: collectionView.topAnchor),
                pencilPickerView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
                pencilPickerView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
                pencilPickerView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor)
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
            codeSegmented.topAnchor.constraint(equalTo: dollParts["neckline"]!.bottomAnchor, constant: -20),
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
        collectionView.register(
            OutfitCollectionViewCell.self,
            forCellWithReuseIdentifier: OutfitCollectionViewCell.reuseIdentifier)

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10

        let cellWidth = (UIScreen.main.bounds.width - layout.minimumInteritemSpacing * 2 - layout.sectionInset.left - layout.sectionInset.right) / 3
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth)

        layout.sectionInset = UIEdgeInsets(
            top: 10,
            left: (UIScreen.main.bounds.width - cellWidth * 3 - layout.minimumInteritemSpacing * 2) / 2,
            bottom: 10, right: (UIScreen.main.bounds.width - cellWidth * 3 - layout.minimumInteritemSpacing * 2) / 2)
        
        collectionView.collectionViewLayout = layout
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return outfits?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: OutfitCollectionViewCell.reuseIdentifier,
            for: indexPath) as? OutfitCollectionViewCell {
            if let outfit = outfits?[indexPath.item] {
                cell.configure(with: outfit, yPos: cellYPos)
            }
            return cell
        } else {
            let defaultCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DefaultCell", for: indexPath)
            return defaultCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.width - 30) / 3
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedOutfit = outfits?[indexPath.item] {
            updateDollImage(with: selectedOutfit)
            selected?[segmentIndex] = (outfitss?[segmentIndex][indexPath.item])!
            print(selected)
        }
    }
    
    func updateDollImage(with cloth: DollCloth) {
        guard let bImageView = dollParts["B" + cloth.name] else { return }
        guard let imageView = dollParts[cloth.name] else { return }

        bImageView.image = UIImage(named: cloth.bottom)?.withTintColor(selectedColor)
        imageView.image = UIImage(named: cloth.outer)

        changeClothName(with: cloth)
    }
}


