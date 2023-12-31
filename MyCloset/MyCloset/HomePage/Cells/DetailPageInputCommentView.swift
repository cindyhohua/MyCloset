//
//  DetailPageInputCommentCell.swift
//  MyCloset
//
//  Created by 賀華 on 2023/12/1.
//

import UIKit
import SnapKit

protocol DetailPageInputCommentDelegate: AnyObject {
    func didTapPostComment()
}

class DetailPageInputCommentView: UIView {
    var postId: String?
    var posterId: String?
    weak var delegate: DetailPageInputCommentDelegate?
    
    private let commentTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Add a comment..."
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let postButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Post", for: .normal)
        button.tintColor = .brown
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(commentTextField)
        addSubview(postButton)
        
        commentTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().dividedBy(1.25)
        }
        
        postButton.snp.makeConstraints { make in
            make.leading.equalTo(commentTextField.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
        }

        postButton.addTarget(self, action: #selector(postButtonTapped), for: .touchUpInside)
    }
    
    @objc private func postButtonTapped() {
        guard let comment = commentTextField.text, !comment.isEmpty else {
            return
        }
        FirebaseStorageManager.shared.addComment(
            postId: self.postId ?? "", comment: comment,
            posterId: posterId ?? "") { error in
            if let error = error {
                print(error.localizedDescription)
            }
            self.delegate?.didTapPostComment()
            self.commentTextField.text = nil
        }
        
    }
}
