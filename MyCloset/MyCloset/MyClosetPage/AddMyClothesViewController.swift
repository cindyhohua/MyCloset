//
//  AddMyClothesViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/17.
//
import UIKit
import SnapKit
import TOCropViewController

class AddMyClosetViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var clothes: ClothesStruct?
    var categoryPicker = UIPickerView()
    var subcategoryPicker = UIPickerView()
    var imageView = UIImageView()
    var nameTextField = UITextField()
    var storeTextField = UITextField()
    var priceTextField = UITextField()
    var contentTextField = UITextField()
    var uploadImageButton = UIButton()
    var chooseCategoryLabel = UILabel()
    var chooseSubcategoryLabel = UILabel()

    var categories = ["Tops", "Bottoms", "Accessories"]
    var subcategories = [
        ["Short Sleeve", "Long Sleeve", "Sweater", "Jacket"],
        ["Pants", "Shorts", "Skirt"],
        ["Headwear", "Face Mask", "Jewelry", "Socks", "Shoes"]
    ]

    var selectedCategory = 0
    var selectedSubcategory = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
//        self.navigationController?.navigationBar.backgroundColor = .white
        let leftButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward.circle"),
            style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = leftButton
        leftButton.tintColor = UIColor.brown
        let rightButton = UIBarButtonItem(
            image: UIImage(systemName: "checkmark.circle"), style: .plain,
            target: self, action: #selector(addButtonTapped(_:)))
        navigationItem.rightBarButtonItem = rightButton
        rightButton.tintColor = UIColor.brown
        navigationItem.title = "Add new item"
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.brown,
            NSAttributedString.Key.font: UIFont.roundedFont(ofSize: 20)]
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        subcategoryPicker.dataSource = self
        subcategoryPicker.delegate = self
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageView.layer.cornerRadius = imageView.bounds.height/2
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func setupUI() {
        // Add subviews
        view.addSubview(categoryPicker)
        view.addSubview(subcategoryPicker)
        view.addSubview(imageView)
        view.addSubview(nameTextField)
        view.addSubview(storeTextField)
        view.addSubview(priceTextField)
        view.addSubview(contentTextField)
        view.addSubview(uploadImageButton)
        view.addSubview(chooseCategoryLabel)
        view.addSubview(chooseSubcategoryLabel)
        
        // Category Picker Constraints
        categoryPicker.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.trailing.equalToSuperview().inset(20)
            make.leading.equalToSuperview().inset(100)
            make.height.equalTo(100)
        }
        
        chooseCategoryLabel.text = "Category"
        chooseCategoryLabel.textColor = .brown
        chooseCategoryLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalTo(categoryPicker)
        }
        
        // Subcategory Picker Constraints
        subcategoryPicker.snp.makeConstraints { make in
            make.top.equalTo(categoryPicker.snp.bottom)
            make.trailing.equalToSuperview().inset(20)
            make.leading.equalToSuperview().inset(100)
            make.height.equalTo(100)
        }
        chooseSubcategoryLabel.text = "Subategory"
        chooseSubcategoryLabel.textColor = .brown
        chooseSubcategoryLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalTo(subcategoryPicker)
        }
        
        // Image View Constraints
        imageView.snp.makeConstraints { make in
            make.top.equalTo(subcategoryPicker.snp.bottom)
            make.bottom.equalTo(nameTextField.snp.top).offset(-10)
            make.centerX.equalToSuperview()
            make.width.equalTo(imageView.snp.height)
        }
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        if clothes == nil {
            imageView.image = UIImage(named: "placeHolder")
        }
        
        // Name Text Field Constraints
        nameTextField.snp.makeConstraints { make in
            make.bottom.equalTo(storeTextField.snp.top).offset(-10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        nameTextField.placeholder = "輸入品名（必填）"
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.borderColor = UIColor.lightLightBrown().cgColor
        nameTextField.layer.cornerRadius = 10
        nameTextField.layer.sublayerTransform = CATransform3DMakeTranslation(20, 0, 0)
        
        // Store Text Field Constraints
        storeTextField.snp.makeConstraints { make in
            make.bottom.equalTo(priceTextField.snp.top).offset(-10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        storeTextField.placeholder = "輸入店家"
        storeTextField.layer.borderWidth = 1
        storeTextField.layer.borderColor = UIColor.lightLightBrown().cgColor
        storeTextField.layer.cornerRadius = 10
        storeTextField.layer.sublayerTransform = CATransform3DMakeTranslation(20, 0, 0)
        
        // Price Text Field Constraints
        priceTextField.snp.makeConstraints { make in
            make.bottom.equalTo(contentTextField.snp.top).offset(-10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        priceTextField.placeholder = "輸入價錢"
        priceTextField.layer.borderWidth = 1
        priceTextField.layer.borderColor = UIColor.lightLightBrown().cgColor
        priceTextField.layer.cornerRadius = 10
        priceTextField.layer.sublayerTransform = CATransform3DMakeTranslation(20, 0, 0)
        priceTextField.keyboardType = .numberPad
        
        // Content Text Field Constraints
        contentTextField.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        contentTextField.placeholder = "輸入其他註解"
        contentTextField.layer.borderWidth = 1
        contentTextField.layer.borderColor = UIColor.lightLightBrown().cgColor
        contentTextField.layer.cornerRadius = 10
        contentTextField.layer.sublayerTransform = CATransform3DMakeTranslation(20, 0, 0)
        
        // Upload image button
        uploadImageButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(imageView).offset(15)
        }
        
        uploadImageButton.setTitle("  新增服飾照  ", for: .normal)
        uploadImageButton.layer.cornerRadius = 10
        uploadImageButton.backgroundColor = .white.withAlphaComponent(0.5)
        uploadImageButton.setTitleColor(.brown, for: .normal)
        uploadImageButton.addTarget(self, action: #selector(uploadImageButtonTapped), for: .touchUpInside)
        
    }
    
    @objc func uploadImageButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self

        let alertController = UIAlertController(title: "選擇照片來源", message: nil, preferredStyle: .actionSheet)

        let photoLibraryAction = UIAlertAction(title: "從相簿選擇", style: .default) { _ in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }

        let cameraAction = UIAlertAction(title: "拍攝照片", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                self.showAlert(message: "你的設備沒有相機功能。")
            }
        }

        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        alertController.addAction(photoLibraryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    func showAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - UIPickerViewDataSource and UIPickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == categoryPicker {
            return categories.count
        } else {
            return subcategories[selectedCategory].count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == categoryPicker {
            return categories[row]
        } else {
            return subcategories[selectedCategory][row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == categoryPicker {
            selectedCategory = row
            subcategoryPicker.reloadAllComponents()
        } else {
            selectedSubcategory = row
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            picker.dismiss(animated: true)
            let cropViewController = TOCropViewController(image: pickedImage)
            cropViewController.delegate = self
            cropViewController.aspectRatioPreset = .presetSquare
            present(cropViewController, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func addButtonTapped(_ sender: UIButton) {
        let categoryName = categories[selectedCategory]
        let subcategoryName = subcategories[selectedCategory][selectedSubcategory]
        let itemName = nameTextField.text ?? ""
        let storeName = storeTextField.text ?? ""
        let price = priceTextField.text ?? ""
        let content = contentTextField.text ?? ""
        let image = imageView.image?.jpegData(compressionQuality: 0.3)
        
        if itemName != "" {
            CoreDataManager.shared.addClothes(
                category: categoryName, subcategory: subcategoryName,
                item: itemName, price: price, store: storeName,
                content: content, image: image)
            guard let viewControllers = self.navigationController?.viewControllers else { return }
            for controller in viewControllers {
                if controller is MyClosetPageViewController {
                    self.navigationController?.popToViewController(controller, animated: true)
                }
            }
        } else {
            showAlert(message: "Item name is required")
        }
    }
    
    func clothesEdit() {
        if let clothe = clothes {
            imageView.image = UIImage(data: clothe.image!)
            categoryPicker.isHidden = true
            subcategoryPicker.isHidden = true
            nameTextField.text = clothe.item
            nameTextField.isEnabled = false
            nameTextField.textColor = .gray
            storeTextField.text = clothe.store
            priceTextField.text = clothe.price
            contentTextField.text = clothe.content
            chooseCategoryLabel.isHidden = true
            chooseSubcategoryLabel.isHidden = true
            imageView.snp.makeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(100)
                make.bottom.equalTo(nameTextField.snp.top).offset(-10)
                make.centerX.equalToSuperview()
                make.width.equalTo(imageView.snp.height)
            }
            contentTextField.snp.makeConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-100)
                make.leading.trailing.equalToSuperview().inset(20)
                make.height.equalTo(40)
            }
        }
    }
}

extension AddMyClosetViewController: TOCropViewControllerDelegate {
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        imageView.image = image
        uploadImageButton.setTitle("  重新選擇照片  ", for: .normal)
        uploadImageButton.backgroundColor = .white.withAlphaComponent(0.5)
        uploadImageButton.layer.cornerRadius = 10
        dismiss(animated: true, completion: nil)
    }
}
