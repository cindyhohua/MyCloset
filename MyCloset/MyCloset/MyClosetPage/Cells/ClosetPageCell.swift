//
//  ClosetCell.swift
//  MyCloset
//
//  Created by 賀華 on 2023/12/30.
//

import UIKit

class ClosetPageCell: UITableViewCell {
    var selectMine = false
    var index = 0
    let checkButton = UIButton()
    let clothButton = UIButton()
    var buttonTapped: (() -> Void)?
    let circularImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.roundedFont(ofSize: 18)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(circularImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(checkButton)
        contentView.addSubview(clothButton)
        circularImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(3)
            make.leading.equalTo(contentView).offset(16)
            make.centerY.equalTo(contentView)
            make.width.height.equalTo(50)
            make.bottom.equalTo(contentView).offset(-3)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(circularImageView.snp.trailing).offset(16)
            make.centerY.equalTo(contentView)
        }
        
        checkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        checkButton.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.trailing.equalTo(contentView).offset(-15)
            make.width.height.equalTo(50)
        }
        checkButton.isHidden = true
        
        clothButton.setImage(UIImage(systemName: "tshirt.fill"), for: .normal)
        clothButton.tintColor = .lightBrown()
        clothButton.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).offset(-16)
            make.width.height.equalTo(70)
            make.centerY.equalTo(contentView)
        }
        clothButton.addTarget(self, action: #selector(clothButtonTapped), for: .touchUpInside)
    }
    
    @objc func clothButtonTapped() {
        buttonTapped?()
    }
    
    func configure(with imageData: Data, name: String, clothOrNot: Bool) {
        circularImageView.image = UIImage(data: imageData)
        nameLabel.text = name
        if clothOrNot == true {
            clothButton.setImage(UIImage(named: "編輯")?.withTintColor(.lightLightBrown()), for: .normal)
        } else {
            clothButton.setImage(UIImage(named: "已建")?.withTintColor(.lightBrown()), for: .normal)
        }
    }
    
    func configureWithoutImage(name: String) {
        circularImageView.image = UIImage(named: "download20231105155350")
        nameLabel.text = name
    }
}
