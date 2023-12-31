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
        let iview = UIImageView()
        iview.contentMode = .scaleAspectFill
        iview.clipsToBounds = true
        iview.layer.cornerRadius = 5
        iview.backgroundColor = UIColor.white
        iview.layer.shadowColor = UIColor.black.cgColor
        iview.layer.shadowOpacity = 0.5
        iview.layer.shadowOffset = CGSize(width: 0, height: 3)
        iview.layer.shadowRadius = 2
        return iview
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(image)
        image.image = UIImage(named: "placeHolder")
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
