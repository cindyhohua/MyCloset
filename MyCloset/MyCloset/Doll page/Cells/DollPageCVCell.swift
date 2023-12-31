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

    func configure(with outfit: DollCloth, yPos: CGFloat) {
        outfitImageView.image = createCenterCroppedImage(named: "\(outfit.outer)", yPos: yPos)
    }
    
    func configureAcc(with outfit: DollCloth) {
        outfitImageView.image = UIImage(named: "\(outfit.outer)")
    }
    
    func createCenterCroppedImage(named imageName: String, yPos: CGFloat) -> UIImage? {
        guard let originalImage = UIImage(named: imageName) else {
            return nil
        }

        let width = originalImage.size.width / 2
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: width))
        let xPosition = -(originalImage.size.width - width) / 2
        let yPosition = -(originalImage.size.height - width) / yPos

        let image = renderer.image { _ in
            originalImage.draw(at: CGPoint(x: xPosition, y: yPosition))
        }

        return image
    }
}

protocol ColorPickerViewDelegate: AnyObject {
    func didSelectColor(_ color: UIColor)
}

protocol PencilPickerViewDelegate: AnyObject {
    func pencilSelectColor(_ color: UIColor)
    func undoAction()
    func redoAction()
    func thicknessChanged(thickness: CGFloat)
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

class PencilPickerView: UIView, UIColorPickerViewControllerDelegate {
    weak var delegate: PencilPickerViewDelegate?

    private lazy var colorPickerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Pick Color", for: .normal)
        button.setTitleColor(.brown, for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(showColorPicker), for: .touchUpInside)
        return button
    }()

    private lazy var undoButton: UIButton = {
        let button = UIButton()
        button.setTitle("Undo", for: .normal)
        button.setTitleColor(.lightBrown(), for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(undoAction), for: .touchUpInside)
        return button
    }()

    private lazy var redoButton: UIButton = {
        let button = UIButton()
        button.setTitle("Redo", for: .normal)
        button.setTitleColor(.lightBrown(), for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(redoAction), for: .touchUpInside)
        return button
    }()

    private lazy var thicknessSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 1.0
        slider.maximumValue = 10.0
        slider.value = 5.0 // Default thickness
        slider.addTarget(self, action: #selector(thicknessChanged), for: .valueChanged)
        return slider
    }()

    private lazy var colorIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()

    @objc private func showColorPicker() {
        let colorPicker = UIColorPickerViewController()
        colorPicker.delegate = self
        colorPicker.modalPresentationStyle = .popover
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            rootViewController.present(colorPicker, animated: true, completion: nil)
        }
    }

    @objc private func undoAction() {
        delegate?.undoAction()
    }

    @objc private func redoAction() {
        delegate?.redoAction()
    }

    @objc private func thicknessChanged() {
        let thickness = thicknessSlider.value
        delegate?.thicknessChanged(thickness: CGFloat(thickness))
    }

    // MARK: - UIColorPickerViewControllerDelegate

    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        delegate?.pencilSelectColor(viewController.selectedColor)
        colorIndicatorView.backgroundColor = viewController.selectedColor
        viewController.dismiss(animated: true, completion: nil)
    }

    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        delegate?.pencilSelectColor(viewController.selectedColor)
        colorIndicatorView.backgroundColor = viewController.selectedColor
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
        addSubview(undoButton)
        addSubview(redoButton)
        addSubview(thicknessSlider)
        addSubview(colorIndicatorView)

        colorPickerButton.translatesAutoresizingMaskIntoConstraints = false
        undoButton.translatesAutoresizingMaskIntoConstraints = false
        redoButton.translatesAutoresizingMaskIntoConstraints = false
        thicknessSlider.translatesAutoresizingMaskIntoConstraints = false
        colorIndicatorView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            colorPickerButton.topAnchor.constraint(equalTo: topAnchor),
            colorPickerButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            colorPickerButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            colorPickerButton.heightAnchor.constraint(equalToConstant: 44),

            undoButton.topAnchor.constraint(equalTo: colorPickerButton.bottomAnchor, constant: 8),
            undoButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            undoButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            undoButton.heightAnchor.constraint(equalToConstant: 44),

            redoButton.topAnchor.constraint(equalTo: undoButton.bottomAnchor, constant: 8),
            redoButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            redoButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            redoButton.heightAnchor.constraint(equalToConstant: 44),

            thicknessSlider.topAnchor.constraint(equalTo: redoButton.bottomAnchor, constant: 8),
            thicknessSlider.leadingAnchor.constraint(equalTo: leadingAnchor),
            thicknessSlider.trailingAnchor.constraint(equalTo: trailingAnchor),
            thicknessSlider.heightAnchor.constraint(equalToConstant: 44),

            colorIndicatorView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            colorIndicatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            colorIndicatorView.bottomAnchor.constraint(equalTo: colorPickerButton.bottomAnchor, constant: -8),
            colorIndicatorView.widthAnchor.constraint(equalToConstant: 30)
        ])
    }
}
