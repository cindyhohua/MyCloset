//
//  ProfileAuthTableViewCell.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/23.
//
import UIKit
import SnapKit

class ProfileAuthCollectionViewCell: UICollectionReusableView {
    var author: Author? {
        didSet {
            // Update UI elements when the author is set
            updateUI()
        }
    }

    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = UIScreen.main.bounds.width / 4
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()

    var wordLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    var heightLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    var weightLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(wordLabel)
        addSubview(heightLabel)
        addSubview(weightLabel)

        profileImageView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(20) // Adjust the offset as needed
                make.width.equalTo(UIScreen.main.bounds.width / 2)
                make.height.equalTo(profileImageView.snp.width)
            }

            nameLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(profileImageView.snp.bottom).offset(16)
            }

            wordLabel.snp.makeConstraints { make in
                make.top.equalTo(nameLabel.snp.bottom).offset(6)
                make.centerX.equalToSuperview()
            }
            wordLabel.numberOfLines = 0

            heightLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(wordLabel.snp.bottom).offset(6)
                make.leading.trailing.equalTo(nameLabel)
            }

            weightLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(heightLabel.snp.bottom).offset(6)
                make.leading.trailing.equalTo(nameLabel)
                make.bottom.lessThanOrEqualToSuperview().offset(-16)
            }
    }

    private func updateUI() {
        // Update UI elements based on the 'author' property
        if let imageURL = author?.image {
            profileImageView.kf.setImage(with: URL(string: imageURL))
        }
        nameLabel.text = author?.name
        wordLabel.text = author?.littleWords
        heightLabel.text = author?.height
        weightLabel.text = author?.weight
        // You might want to update the profile image here as well, based on the 'author' property.
    }
}


//import UIKit
//import Kingfisher
//
//class ProfileAuthCollectionViewCell: UICollectionReusableView {
//    var author: Author?
//    lazy var profileImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.layer.cornerRadius = UIScreen.main.bounds.width/4
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        imageView.isUserInteractionEnabled = true
//        return imageView
//    }()
//
//    var nameLabel = UILabel()
//    var wordLabel = UILabel()
//    var heightLabel = UILabel()
//    var weightLabel = UILabel()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func setupConstraints() {
//        addSubview(profileImageView)
//        profileImageView.image = UIImage(named: "Image")
//        profileImageView.contentMode = .scaleAspectFill
//        profileImageView.snp.makeConstraints { make in
//            make.top.equalTo(self.snp.top).offset(16)
//            make.centerX.equalTo(self)
//            make.height.width.equalTo(UIScreen.main.bounds.width/2)
//        }
//
//        addSubview(nameLabel)
//        addSubview(wordLabel)
//        addSubview(heightLabel)
//        addSubview(weightLabel)
//
//        nameLabel.snp.makeConstraints { make in
//            make.centerX.equalTo(self)
//            make.top.equalTo(profileImageView.snp.bottom).offset(16)
//            make.bottom.lessThanOrEqualTo(self.snp.bottom).offset(-8)
//        }
//        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
//
//        wordLabel.numberOfLines = 0
//        wordLabel.snp.makeConstraints { make in
//            make.centerX.equalTo(self)
//            make.top.equalTo(nameLabel.snp.bottom).offset(8)
//            make.leading.equalTo(self).offset(20)
//            make.trailing.equalTo(self).offset(-20)
//            make.bottom.lessThanOrEqualTo(self.snp.bottom).offset(-8)
//        }
//
//        heightLabel.snp.makeConstraints { make in
//            make.centerX.equalTo(self)
//            make.top.equalTo(wordLabel.snp.bottom).offset(8)
//            make.bottom.lessThanOrEqualTo(self.snp.bottom).offset(-8)
//        }
//
//        weightLabel.snp.makeConstraints { make in
//            make.centerX.equalTo(self)
//            make.top.equalTo(heightLabel.snp.bottom).offset(8)
//            make.bottom.lessThanOrEqualTo(self.snp.bottom).offset(-8)
//        }
//    }
//
//
//    func configure() {
//        if let image = author?.image {
//            if image.isEmpty == false {
//                profileImageView.kf.setImage(with: URL(string: image))
//            }
//        }
//        if let name = author?.name {
//            nameLabel.text = name
//        }
//        if let word = author?.littleWords {
//            wordLabel.text = word
//        }
//        if let height = author?.height {
//            heightLabel.text = height
//        }
//        if let weight = author?.weight {
//            weightLabel.text = weight
//        }
////        setupConstraints()
//    }
//}

