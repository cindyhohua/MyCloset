//
//  DetailPageCell.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/17.
//

import UIKit
import SnapKit
import QuartzCore

protocol LongPressDelegate {
    func longPress()
}

class DetailPageImageCell: UITableViewCell {
    var dollImageURL: String?
    var imageURL: String?
    var labelTexts: [Product]?
    var likeCount: Int?
    var authorId: String?
    var friendList: [String] = []
    var delegate: LongPressDelegate?
    var isLiked: Bool? {
        didSet {
            if isLiked == true {
                self.likeButton.tintColor = .brown
            } else {
                self.likeButton.tintColor = .lightLightBrown()
            }
        }
    }
    var postId: String? {
        didSet {
            FirebaseStorageManager.shared.fetchLike(postId: postId ?? "") { result in
                switch result {
                case .success(let likeInfo):
                    self.likeCount = likeInfo.likeCount
                    let isLiked = likeInfo.isLiked
                    print("Like Count: \(self.likeCount), Is Liked: \(isLiked)")
                    self.isLiked = isLiked
                case .failure(let error):
                    print("Error fetching like info: \(error.localizedDescription)")
                }
            }
        }
    }
    var likeButton = UIButton()
    lazy var imageViewCell: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 5
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    lazy var dollImageViewCell: UIImageView = {
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
        imageViewCell.layer.shadowColor = UIColor.black.cgColor
        imageViewCell.layer.shadowOpacity = 0.5
        imageViewCell.layer.shadowOffset = CGSize(width: 0, height: 3)
        imageViewCell.layer.shadowRadius = 5
        
        contentView.addSubview(dollImageViewCell)
        dollImageViewCell.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(16)
            make.leading.equalTo(contentView).offset(16)
            make.trailing.equalTo(contentView).offset(-16)
            make.height.equalTo(imageViewCell.snp.width).multipliedBy(1.4)
            make.bottom.equalTo(contentView).offset(-16)
        }
        dollImageViewCell.layer.shadowColor = UIColor.black.cgColor
        dollImageViewCell.layer.shadowOpacity = 0.5
        dollImageViewCell.layer.shadowOffset = CGSize(width: 0, height: 3)
        dollImageViewCell.layer.shadowRadius = 5
        dollImageViewCell.isHidden = true
//        dollImageViewCell.addGestureRecognizer(rightSwipeGesture)
        
        contentView.addSubview(likeButton)
        likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        likeButton.imageView?.contentMode = .scaleAspectFit
        likeButton.snp.makeConstraints { make in
            make.bottom.equalTo(imageViewCell.snp.bottom).offset(-16)
            make.leading.equalTo(imageViewCell.snp.leading).offset(16)
            make.width.height.equalTo(50)
        }
        likeButton.tintColor = .lightBrown()
        likeButton.backgroundColor = .white
        likeButton.layer.cornerRadius = 25
        likeButton.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(likeButtonLongPressed(_:)))
        likeButton.addGestureRecognizer(longPressGesture)
        
        imageViewCell.layer.masksToBounds = true
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.5
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
    }
    
    @objc func handleRightSwipe() {
       performFlipAnimationR()
    }
    @objc func handleLeftSwipe() {
        performFlipAnimationL()
    }
    
    var isFlipped = false
    
    func performFlipAnimationR() {
        UIView.transition(with: contentView, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            if self.isFlipped {
                self.imageViewCell.isHidden = false
                self.dollImageViewCell.isHidden = true
            } else {
                self.imageViewCell.isHidden = true
                self.dollImageViewCell.isHidden = false
            }
        }, completion: nil)
        isFlipped.toggle()
    }
    
    func performFlipAnimationL() {
        UIView.transition(with: contentView, duration: 0.5, options: .transitionFlipFromRight, animations: {
            if self.isFlipped {
                self.imageViewCell.isHidden = false
                self.dollImageViewCell.isHidden = true
            } else {
                self.imageViewCell.isHidden = true
                self.dollImageViewCell.isHidden = false
            }
        }, completion: nil)
        isFlipped.toggle()
    }
    
    @objc func likeButtonLongPressed(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            delegate?.longPress()
        }
    }
  
    @objc func likeTapped() {
        FirebaseStorageManager.shared.toggleLike(postId: postId ?? "", authorId: authorId ?? "") { error in
                if let error = error {
                    print("Error toggling like: \(error.localizedDescription)")
                } else {
                    print("Like toggled successfully")
                    if self.isLiked == false {
                        self.playHeartAnimation()
                        print("play animation")
                    }
                    self.isLiked = !(self.isLiked ?? false)
                }
            }
    }
    
    func playHeartAnimation() {
        let heartImageView = UIImageView(image: UIImage(systemName: "heart.fill"))
        let heartAmountLabel = UILabel()
        heartAmountLabel.text = "\((self.likeCount ?? 0) + 1)"
        heartAmountLabel.textColor = .white
        heartAmountLabel.font = UIFont.roundedFont(ofSize: 16)
        heartImageView.tintColor = .red
        heartImageView.contentMode = .scaleAspectFit
        heartImageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        heartImageView.center = likeButton.center
        
        contentView.addSubview(heartImageView)
        heartImageView.addSubview(heartAmountLabel)
        heartImageView.snp.makeConstraints { make in
            make.center.equalTo(imageViewCell)
            make.width.height.equalTo(100)
        }
        heartAmountLabel.snp.makeConstraints { make in
            make.center.equalTo(imageViewCell)
        }

        UIView.animate(withDuration: 0.5, animations: {
            heartImageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            heartImageView.alpha = 0.0
        }
        ) { _ in
            heartImageView.removeFromSuperview()
        }
    }
    
    func configure(with image: String, dollImage: String, buttonPosition: [CGPoint]) {
        self.imageURL = image
        self.dollImageURL = dollImage
        if dollImage != "" {
            dollImageViewCell.kf.setImage(with: URL(string: dollImage))
            let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleRightSwipe))
            rightSwipeGesture.direction = .right
            let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleLeftSwipe))
            rightSwipeGesture.direction = .right
            leftSwipeGesture.direction = .left
            contentView.addGestureRecognizer(rightSwipeGesture)
            contentView.addGestureRecognizer(leftSwipeGesture)
        }
        imageViewCell.kf.setImage(with: URL(string: image))
        var actualPositions: [CGPoint] = []
        actualPositions = buttonPosition.map { convertToActualPosition($0) }
        var xPosition = 0
        for position in actualPositions {
            let button = UIButton(type: .system)
            button.frame = CGRect(x: position.x - 10, y: position.y - 10, width: 20, height: 20)
            button.backgroundColor = .white
            button.layer.cornerRadius = 10
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.lightGray.cgColor
            button.tag = xPosition
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            button.setTitle("", for: .normal)
            imageViewCell.addSubview(button)
            xPosition += 1
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
        tagLabel.layer.cornerRadius = 18
        tagLabel.font = UIFont.systemFont(ofSize: 28)
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
