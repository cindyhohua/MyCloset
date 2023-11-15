//
//  HomePageTableCell.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/14.
//

import UIKit

class HomePageTableCell: UITableViewCell {
    lazy var cellImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 5
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let name = UILabel()
        name.translatesAutoresizingMaskIntoConstraints = false
        name.textColor = .white
        name.font = UIFont.roundedFont(ofSize: 20)
        return name
    }()
    
    lazy var profileImage: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        img.layer.borderWidth = 1
        img.layer.borderColor = UIColor.white.cgColor
        return img
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        contentView.addSubview(cellImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(profileImage)
        cellImageView.image = UIImage(named: "IMG_0691_Original")
        nameLabel.text = "白花油點馬啾"
        profileImage.image = UIImage(named: "download20231105155350")
        
        NSLayoutConstraint.activate([
            cellImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            cellImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cellImageView.heightAnchor.constraint(equalTo: cellImageView.widthAnchor, multiplier: 1.4),
            cellImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            profileImage.leadingAnchor.constraint(equalTo: cellImageView.leadingAnchor, constant: 16),
            profileImage.topAnchor.constraint(equalTo: cellImageView.topAnchor, constant: 16),
            profileImage.widthAnchor.constraint(equalToConstant: 50),
            profileImage.heightAnchor.constraint(equalToConstant: 50),
            
            nameLabel.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 12)
        ])
        
        profileImage.layer.cornerRadius = 25
        profileImage.layer.masksToBounds = true
    }
}
