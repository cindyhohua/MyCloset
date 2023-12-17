//
//  NewPostViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/16.
//

import UIKit
import SnapKit
import TOCropViewController

class NewPostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var position: [CGPoint] = [] {
        didSet {
            if position.count > 0 {
                deleteButton.isHidden = false
            } else {
                deleteButton.isHidden = true
            }
        }
    }
    let chooseImageButton = UIButton()
    let indicateLabel = UILabel()
    let deleteButton = UIButton()
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 5
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        pickPhoto()
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc func pickPhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self

        let alertController = UIAlertController(title: "選擇照片來源", message: nil, preferredStyle: .actionSheet)

        let cameraAction = UIAlertAction(title: "相機", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                print("相機不可用")
            }
        }

        let libraryAction = UIAlertAction(title: "相簿", style: .default) { _ in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }

        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        alertController.addAction(cameraAction)
        alertController.addAction(libraryAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    func showAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            self.dismiss(animated: true)
            let cropViewController = TOCropViewController(image: pickedImage)
            cropViewController.delegate = self
            let customAspectRatio = CGSize(width: 1, height: 1.4)
            cropViewController.customAspectRatio = customAspectRatio
            present(cropViewController, animated: true, completion: nil)
        }
    }
    
    func convertToRelativePosition(_ point: CGPoint) -> CGPoint {
        let relativeX = point.x / imageView.bounds.width
        let relativeY = point.y / imageView.bounds.height
        return CGPoint(x: relativeX, y: relativeY)
    }
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: imageView)
        let relativePosition = convertToRelativePosition(location)
        position.append(relativePosition)
        createButton(at: location)
    }
    
    func createButton(at position: CGPoint) {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: position.x - 10, y: position.y - 10, width: 20, height: 20)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.tag = self.position.count
        button.setTitle("\(self.position.count)", for: .normal)
        imageView.addSubview(button)
    }
    
    @objc func deleteButtonTapped() {
        if !position.isEmpty {
            if let button = imageView.viewWithTag(position.count) as? UIButton {
                button.removeFromSuperview()
            }
            position.removeLast()
        }
    }

//    @objc func buttonTapped(_ sender: UIButton) {
//        sender.removeFromSuperview()
//    }
    
    func setup() {
        view.backgroundColor = .white
        let nextButton = UIBarButtonItem(
            title: "Next", style: .plain, target: self,
            action: #selector(nextButtonTapped))
        nextButton.tintColor = UIColor.lightBrown()
        navigationItem.rightBarButtonItem = nextButton
        navigationItem.rightBarButtonItem?.isEnabled = false
        let leftButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward.circle"),
            style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = leftButton
        leftButton.tintColor = UIColor.lightBrown()
        navigationItem.title = "Create new post"
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.lightBrown(),
            NSAttributedString.Key.font: UIFont.roundedFont(ofSize: 20)]
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 18),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.4)
        ])
 
        view.addSubview(chooseImageButton)
        chooseImageButton.setTitle("選擇其他張照片", for: .normal)
        chooseImageButton.setTitleColor(UIColor.lightBrown(), for: .normal)
        chooseImageButton.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(imageView.snp.bottom).offset(3)
        }
        chooseImageButton.addTarget(self, action: #selector(pickPhoto), for: .touchUpInside)
        
        view.addSubview(indicateLabel)
        indicateLabel.text = "點擊照片中服飾以增加註解，選擇完畢後點選下一步"
        indicateLabel.textColor = .gray
        indicateLabel.numberOfLines = 0
        indicateLabel.font = UIFont.roundedFont(ofSize: 14)
        indicateLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(chooseImageButton.snp.bottom).offset(1)
            make.leading.equalTo(view).offset(16)
            make.trailing.equalTo(view).offset(-16)
        }
        
        view.addSubview(deleteButton)
        deleteButton.setImage(UIImage(systemName: "arrowshape.turn.up.left.fill"), for: .normal)
        deleteButton.backgroundColor = .white
        deleteButton.tintColor = .brown
        deleteButton.snp.makeConstraints { make in
            make.leading.equalTo(imageView).offset(16)
            make.top.equalTo(imageView).offset(16)
            make.width.height.equalTo(50)
        }
        deleteButton.layer.cornerRadius = 25
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        deleteButton.isHidden = true
    }
    
    @objc func nextButtonTapped() {
        let nextViewController = NewPostSecondStepViewController()
        nextViewController.position = position
        nextViewController.selectedImage = imageView.image
        navigationController?.pushViewController(nextViewController, animated: true)
    }
    
}

extension NewPostViewController: TOCropViewControllerDelegate {
    func cropViewController(
        _ cropViewController: TOCropViewController,
        didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        // 在這裡處理裁切後的照片，例如顯示在 UIImageView 中
        imageView.image = image
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        imageView.addGestureRecognizer(tapGestureRecognizer)
        imageView.isUserInteractionEnabled = true
        navigationItem.rightBarButtonItem?.isEnabled = true
        dismiss(animated: true, completion: nil)
    }
}
