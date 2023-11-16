//
//  NewPostViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/16.
//

import UIKit
import SnapKit

class NewPostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var position: [CGPoint] = []
    let chooseImageButton = UIButton()
    let indicateLabel = UILabel()
//    let deleteButton = UIButton()
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
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = pickedImage
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
            imageView.addGestureRecognizer(tapGestureRecognizer)
            imageView.isUserInteractionEnabled = true
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: imageView)
        position.append(location)
        print("qq",position)
        createButton(at: location)
    }
    
    func createButton(at position: CGPoint) {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: position.x - 10, y: position.y - 10, width: 20, height: 20)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.setTitle("\(self.position.count)", for: .normal)
//        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        imageView.addSubview(button)
    }

//    @objc func buttonTapped(_ sender: UIButton) {
//        sender.removeFromSuperview()
//    }
    
    func setup() {
        view.backgroundColor = .white
        let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextButtonTapped))
        nextButton.tintColor = UIColor.lightBrown()
        navigationItem.rightBarButtonItem = nextButton
        navigationItem.rightBarButtonItem?.isEnabled = false
        let leftButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward.circle"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = leftButton
        leftButton.tintColor = UIColor.lightBrown()
        navigationItem.title = "Create new post"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightBrown(), NSAttributedString.Key.font: UIFont.roundedFont(ofSize: 20)]
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
            make.top.equalTo(imageView.snp.bottom).offset(8)
        }
        chooseImageButton.addTarget(self, action: #selector(pickPhoto), for: .touchUpInside)
        
        view.addSubview(indicateLabel)
        indicateLabel.text = "點擊照片中服飾以增加註解，選擇完畢後點選下一步"
        indicateLabel.textColor = .gray
        indicateLabel.numberOfLines = 0
        indicateLabel.font = UIFont.roundedFont(ofSize: 14)
        indicateLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(chooseImageButton.snp.bottom).offset(4)
            make.leading.equalTo(view).offset(16)
            make.trailing.equalTo(view).offset(-16)
        }
    }
    
    @objc func nextButtonTapped() {
        let nextViewController = NewPostSecondStepViewController()
        nextViewController.position = position
        nextViewController.selectedImage = imageView.image
        navigationController?.pushViewController(nextViewController, animated: true)
    }
    
}
