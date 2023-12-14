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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(profileImageView)
        
        let stackView = UIStackView(arrangedSubviews: [nameLabel, wordLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 6 // 設定 name 和 word 之間的垂直間距
        addSubview(stackView)
        
        profileImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
            make.width.equalTo(UIScreen.main.bounds.width / 2)
            make.height.equalTo(profileImageView.snp.width)
        }
        
        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(profileImageView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    private func updateUI() {
        if let imageURL = author?.image {
            profileImageView.kf.setImage(with: URL(string: imageURL))
        }
        nameLabel.text = author?.name
        if let littleWords = author?.littleWords {
            wordLabel.text = littleWords
        } else {
            wordLabel.text = nil
        }
    }
}
