//
//  DollPageCVCell.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/19.
//

import UIKit
class OutfitCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "OutfitCollectionViewCell"

    let outfitImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .redraw
        imageView.clipsToBounds = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    func setupViews() {
        contentView.addSubview(outfitImageView)
        outfitImageView.translatesAutoresizingMaskIntoConstraints = false
        outfitImageView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalTo(contentView)
        }
    }

    func configure(with outfit: DollCloth) {
        let outerImage = UIImage(named: "\(outfit.outer)")
        let bottomImage = UIImage(named: "\(outfit.bottom)")
        outfitImageView.image = UIImage(named: "download20231105155350")
//        outfitImageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
    }
}


import UIKit

protocol ColorPickerViewDelegate: AnyObject {
    func didSelectColor(_ color: UIColor)
}

class ColorPickerView: UIView, UIColorPickerViewControllerDelegate {
    weak var delegate: ColorPickerViewDelegate?

    private lazy var colorPickerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Pick Color", for: .normal)
        button.setTitleColor(.brown, for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(showColorPicker), for: .touchUpInside)
        return button
    }()

    @objc private func showColorPicker() {
        let colorPicker = UIColorPickerViewController()
        colorPicker.delegate = self
        colorPicker.modalPresentationStyle = .popover
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            rootViewController.present(colorPicker, animated: true, completion: nil)
        }
    }

    // MARK: - UIColorPickerViewControllerDelegate

    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        delegate?.didSelectColor(viewController.selectedColor)
        colorPickerButton.backgroundColor = viewController.selectedColor
        viewController.dismiss(animated: true, completion: nil)
    }

    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        delegate?.didSelectColor(viewController.selectedColor)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        addSubview(colorPickerButton)
        colorPickerButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorPickerButton.topAnchor.constraint(equalTo: topAnchor),
            colorPickerButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            colorPickerButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            colorPickerButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

