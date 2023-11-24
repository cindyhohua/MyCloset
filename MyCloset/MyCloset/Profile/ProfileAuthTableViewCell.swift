//
//  ProfileAuthTableViewCell.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/23.
//

import UIKit
import Kingfisher

class ProfileAuthCollectionViewCell: UICollectionReusableView {
    var author: Author?
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = UIScreen.main.bounds.width/4
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    var nameLabel = UILabel()
    var wordLabel = UILabel()
    var heightLabel = UILabel()
    var weightLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        addSubview(profileImageView)
        profileImageView.image = UIImage(named: "Image")
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(16)
            make.centerX.equalTo(self)
            make.height.width.equalTo(UIScreen.main.bounds.width/2)
            
        }
        addSubview(nameLabel)
        addSubview(wordLabel)
        addSubview(heightLabel)
        addSubview(weightLabel)
        nameLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(profileImageView.snp.bottom).offset(16)
        }
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        wordLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(nameLabel.snp.bottom)
        }
        heightLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(wordLabel.snp.bottom)
        }
        weightLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(heightLabel.snp.bottom)
            make.bottom.equalTo(self).offset(-16)
        }
    }
    
    func configure() {
        if let image = author?.image {
            if image.isEmpty == false {
                profileImageView.kf.setImage(with: URL(string: image))
            }
        }
        if let name = author?.name {
            nameLabel.text = name
        }
        if let word = author?.littleWords {
            wordLabel.text = word
        }
        if let height = author?.height {
            heightLabel.text = height
        }
        if let weight = author?.height {
            weightLabel.text = weight
        }
    }
}

