//
//  DollPageViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/18.
//

import UIKit
import SnapKit

class PaperDollViewController: UIViewController {

    let dollImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let topsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let topsBImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let bottomBImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let bottomImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        return collectionView
    }()

    let outfits: [(outer: String, bottom: String)] = [
        ("outfit1", "pants1"),
        ("outfit1B", "pants1B"),
        // Add more outfit pairs as needed
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    func setupViews() {
        view.backgroundColor = .white

        // Set up dollImageView constraints
        view.addSubview(dollImageView)
        dollImageView.image = UIImage(named: "doll")
        dollImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dollImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            dollImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dollImageView.widthAnchor.constraint(equalToConstant: view.bounds.width),
            dollImageView.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        view.addSubview(bottomBImageView)
        bottomBImageView.image = UIImage(named: "pants1B")?.withTintColor(.brown)
        bottomBImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomBImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            bottomBImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomBImageView.widthAnchor.constraint(equalToConstant: view.bounds.width),
            bottomBImageView.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        view.addSubview(bottomImageView)
        bottomImageView.image = UIImage(named: "pants1")
        bottomImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            bottomImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomImageView.widthAnchor.constraint(equalToConstant: view.bounds.width),
            bottomImageView.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        view.addSubview(topsBImageView)
        topsBImageView.image = UIImage(named: "outfit1B")?.withTintColor(.lightLightBrown())
        topsBImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topsBImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            topsBImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            topsBImageView.widthAnchor.constraint(equalToConstant: view.bounds.width),
            topsBImageView.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        view.addSubview(topsImageView)
        topsImageView.image = UIImage(named: "outfit1")
        topsImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topsImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            topsImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            topsImageView.widthAnchor.constraint(equalToConstant: view.bounds.width),
            topsImageView.heightAnchor.constraint(equalToConstant: 400)
        ])
        

        // Set up collectionView constraints
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: dollImageView.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 100)
        ])

        // Set the collectionView's dataSource and delegate
        collectionView.dataSource = self
        collectionView.delegate = self

        // Register UICollectionViewCell for the collectionView
        collectionView.register(OutfitCollectionViewCell.self, forCellWithReuseIdentifier: OutfitCollectionViewCell.reuseIdentifier)

        // Initial display of doll image
        
//        updateDollImage()
    }

    func updateDollImage() {
        // Set the dollImageView's image based on selected outfits
        let outer = outfits[0].outer
        let bottom = outfits[0].bottom
        
//        let imageName = "\(outer)_\(bottom)"
//        dollImageView.image = UIImage(named: imageName)
    }
}

extension PaperDollViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return outfits.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OutfitCollectionViewCell.reuseIdentifier, for: indexPath) as! OutfitCollectionViewCell
        let outfit = outfits[indexPath.item]
        cell.configure(with: outfit)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Handle the selection of an outfit
        let selectedOutfit = outfits[indexPath.item]
        updateDollImage(with: selectedOutfit)
    }
    
    func updateDollImage(with: (outer: String, bottom: String)) {
        print(with.outer)
        print(with.bottom)
    }
}

class OutfitCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "OutfitCollectionViewCell"

    let outfitImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    func setupViews() {
        addSubview(outfitImageView)
        outfitImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            outfitImageView.topAnchor.constraint(equalTo: topAnchor),
            outfitImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            outfitImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            outfitImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func configure(with outfit: (outer: String, bottom: String)) {
        // Configure the cell with the outfit images
        let outerImage = UIImage(named: "\(outfit.outer)_outer")
        let bottomImage = UIImage(named: "\(outfit.bottom)_bottom")
        outfitImageView.image = combineImages(outerImage: outerImage, bottomImage: bottomImage)
    }

    func combineImages(outerImage: UIImage?, bottomImage: UIImage?) -> UIImage? {
        // Combine outer and bottom images
        guard let outerImage = outerImage, let bottomImage = bottomImage else {
            return nil
        }

        UIGraphicsBeginImageContextWithOptions(outerImage.size, false, UIScreen.main.scale)

        outerImage.draw(in: CGRect(origin: CGPoint.zero, size: outerImage.size))
        bottomImage.draw(in: CGRect(origin: CGPoint.zero, size: bottomImage.size))

        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return combinedImage
    }
}

