//
//  ProfileTableViewCell.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/23.
//

import UIKit
import SnapKit

class ProfileCollectionViewCell: UICollectionViewCell {
    let image: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 5
        iv.backgroundColor = UIColor.white
        iv.layer.shadowColor = UIColor.black.cgColor
        iv.layer.shadowOpacity = 0.5
        iv.layer.shadowOffset = CGSize(width: 0, height: 3)
        iv.layer.shadowRadius = 2
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(image)
        image.image = UIImage(named: "AppIcon")
        image.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalTo(contentView)
        }
        image.layer.masksToBounds = true
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.5
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
