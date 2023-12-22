//
//  NewPostImageHeaderCell.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/16.
//

import UIKit
import SnapKit

class NewPostImageCell: UITableViewCell {
    lazy var imageViewCell: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 5
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var dollImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 40
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
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
        contentView.addSubview(dollImageView)
        dollImageView.snp.makeConstraints { make in
            make.leading.equalTo(imageViewCell.snp.leading).offset(16)
            make.bottom.equalTo(imageViewCell.snp.bottom).offset(-16)
            make.height.width.equalTo(80)
        }
        dollImageView.image = UIImage(named: "placeHolder")
        
    }

    func configure(with image: UIImage, buttonPosition: [CGPoint]) {
        imageViewCell.image = image
        var xPosition = 1
        for position in buttonPosition {
            let button = UIButton(type: .system)
            button.frame = CGRect(x: position.x - 10, y: position.y - 10, width: 20, height: 20)
            button.backgroundColor = .white
            button.layer.cornerRadius = 10
            button.setTitle("\(xPosition)", for: .normal)
            imageViewCell.addSubview(button)
            xPosition += 1
        }
    }
}

class PlaceholderTextView: UIView {
    let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.roundedFont(ofSize: 20)
        textView.layer.cornerRadius = 5
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        return textView
    }()
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "輸入文字內容"
        label.font = UIFont.roundedFont(ofSize: 20)
        label.textColor = UIColor.lightGray
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
        addSubview(textView)
        addSubview(placeholderLabel)
        
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
        
        placeholderLabel.snp.makeConstraints { make in
            make.top.equalTo(textView).offset(8)
            make.leading.equalTo(textView).offset(5)
        }
        
        // 监听UITextView的文本变化
        textView.delegate = self
    }
}

extension PlaceholderTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

class NewPostCommentCell: UITableViewCell {
    let textView: PlaceholderTextView = {
        let textView = PlaceholderTextView()
        return textView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
            make.height.equalTo(80)
        }
    }

    func getText() -> String? {
        return textView.textView.text
    }
}

// 品項輸入

protocol NewPostProductCellDelegate: AnyObject {
    func textFieldDidChange(text: String?, in cell: NewPostProductCell)
}

class NewPostProductCell: UITableViewCell {
    weak var delegate: NewPostProductCellDelegate?
    var numberLabel = UILabel()
    var fromClosetButton = UIButton()
    lazy var nameLabel: UITextField = {
        return createTextField(placeholder: "輸入品項")
    }()

    lazy var storeLabel: UITextField = {
        return createTextField(placeholder: "輸入店家（必填）")
    }()

    lazy var priceLabel: UITextField = {
        return createTextField(placeholder: "輸入價錢")
    }()

    lazy var commentsLabel: UITextField = {
        return createTextField(placeholder: "輸入註解")
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setup

    private func setupUI() {
        contentView.addSubview(numberLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(storeLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(commentsLabel)
        contentView.addSubview(fromClosetButton)
        fromClosetButton.setTitle("從衣櫃輸入", for: .normal)
        fromClosetButton.setTitleColor(UIColor.brown, for: .normal)
        setupConstraints()
    }

    private func setupConstraints() {
        numberLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(8)
            make.leading.equalTo(contentView).offset(16)
        }
        fromClosetButton.snp.makeConstraints { make in
            make.centerY.equalTo(numberLabel)
            make.trailing.equalTo(contentView).offset(-16)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(numberLabel.snp.bottom).offset(8)
            make.leading.equalTo(contentView).offset(16)
            make.trailing.equalTo(contentView).offset(-16)
        }
        storeLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.leading.equalTo(contentView).offset(16)
            make.trailing.equalTo(contentView).offset(-16)
        }
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(storeLabel.snp.bottom).offset(8)
            make.leading.equalTo(contentView).offset(16)
            make.trailing.equalTo(contentView).offset(-16)
        }
        priceLabel.keyboardType = .numberPad
        commentsLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(8)
            make.leading.equalTo(contentView).offset(16)
            make.trailing.equalTo(contentView).offset(-16)
            make.bottom.equalTo(contentView).offset(-16)
        }

    }

    private func createTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return textField
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
            delegate?.textFieldDidChange(text: textField.text, in: self)
        }
}
