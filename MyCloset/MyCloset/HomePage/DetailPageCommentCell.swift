//
//  DetailPageCommentCell.swift
//  MyCloset
//
//  Created by 賀華 on 2023/12/1.
//

import UIKit
import SnapKit

class OthersCommentCell: UITableViewCell {
    let nameButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor.brown, for: .normal)
        return button
    }()
    
    let commentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .lightGray
        label.font = UIFont.roundedFont(ofSize: 14)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(nameButton)
        contentView.addSubview(commentLabel)
        contentView.addSubview(timeLabel)
        
        nameButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
        
        commentLabel.snp.makeConstraints { make in
            make.top.equalTo(nameButton.snp.bottom).offset(2)
            make.leading.equalToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(commentLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
}

