//
//  DetailPageCell.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/17.
//

import UIKit
import SnapKit
class DetailPageImageCell: UITableViewCell {
    var labelTexts: [Product]?
    lazy var imageViewCell: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 5
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupConstraints() {
        contentView.addSubview(imageViewCell)
        imageViewCell.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(16)
            make.leading.equalTo(contentView).offset(16)
            make.trailing.equalTo(contentView).offset(-16)
            make.height.equalTo(imageViewCell.snp.width).multipliedBy(1.4)
            make.bottom.equalTo(contentView).offset(-16)
        }
    }

    func configure(with image: String, buttonPosition: [CGPoint]) {
        imageViewCell.kf.setImage(with: URL(string: image))
        var actualPositions: [CGPoint] = []
        actualPositions = buttonPosition.map { convertToActualPosition($0) }
        var x = 0
        for position in actualPositions {
            let button = UIButton(type: .system)
            button.frame = CGRect(x: position.x - 10, y: position.y - 10, width: 20, height: 20)
            button.backgroundColor = .white
            button.layer.cornerRadius = 10
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.lightGray.cgColor
            button.tag = x
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            button.setTitle("", for: .normal)
            imageViewCell.addSubview(button)
            x += 1
        }
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        sender.layer.borderWidth = 3
        sender.layer.borderColor = UIColor.lightBrown().cgColor
        UIView.animate(withDuration: 2, animations: {
            sender.layer.borderWidth = 1
            sender.layer.borderColor = UIColor.lightGray.cgColor
        })
        showTagNumberOnImage(labelText: labelTexts?[sender.tag].productStore ?? "")
    }
    
    func showTagNumberOnImage(labelText: String) {
        let tagLabel = UILabel()
        tagLabel.text = "   \(labelText)   "
        tagLabel.backgroundColor = .white
        tagLabel.textColor = UIColor.brown
        tagLabel.clipsToBounds = true
        tagLabel.layer.cornerRadius = 10
        tagLabel.font = UIFont.systemFont(ofSize: 20)
        tagLabel.sizeToFit()
        tagLabel.frame.origin = CGPoint(x: imageViewCell.bounds.width - tagLabel.bounds.width - 8, y: 8)
        imageViewCell.addSubview(tagLabel)

        UIView.animate(withDuration: 3, animations: {
            tagLabel.alpha = 0.0
        }) { (_) in
            tagLabel.removeFromSuperview()
        }
    }
    
    func convertToActualPosition(_ relativePosition: CGPoint) -> CGPoint {
        let actualX = relativePosition.x * (UIScreen.main.bounds.width-32)
        let actualY = relativePosition.y * ((UIScreen.main.bounds.width-32)*1.4)
        return CGPoint(x: actualX, y: actualY)
    }
}

class DetailPageCommentCell: UITableViewCell {
    var contentLabel = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(16)
            make.leading.equalTo(contentView).offset(32)
            make.trailing.equalTo(contentView).offset(-32)
            make.bottom.equalTo(contentView).offset(-16)
        }
    }
    
    func configure(content: String) {
        contentLabel.text = content
        contentLabel.numberOfLines = 0
        contentLabel.font = UIFont.roundedFont(ofSize: 20)
    }
    
}

class DetailPageProductCell: UITableViewCell {
    var productLabel = UILabel()
    func configure(product: Product) {
        contentView.addSubview(productLabel)
        productLabel.numberOfLines = 0
        productLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(16)
            make.leading.equalTo(contentView).offset(32)
            make.trailing.equalTo(contentView).offset(-32)
            make.bottom.equalTo(contentView)
        }
        var text = ""
        if product.productName != "" {
            text += ("品項：" + product.productName + "\n")
        }
        if product.productStore != "" {
            text += ("店家：" + product.productStore + "\n")
        }
        if product.productPrice != "" {
            text += ("價格：" + product.productPrice + "\n")
        }
        if product.productComment != "" {
            text += ("註解：" + product.productComment + "\n")
        }
        productLabel.text = text
    }
}
