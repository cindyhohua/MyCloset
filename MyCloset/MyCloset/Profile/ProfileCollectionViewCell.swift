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
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(image)
        image.image = UIImage(named: "Image")
        image.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalTo(contentView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
