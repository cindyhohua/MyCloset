//
//  AddMyClothesViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/17.
//
import UIKit
import SnapKit


class AddMyClosetViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var categoryPicker = UIPickerView()
    var subcategoryPicker = UIPickerView()
    var imageView = UIImageView()
    var nameTextField = UITextField()
    var storeTextField = UITextField()
    var priceTextField = UITextField()
    var contentTextField = UITextField()
    var uploadImageButton = UIButton()

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
        let leftButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward.circle"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = leftButton
        leftButton.tintColor = UIColor.brown
        let rightButton = UIBarButtonItem(image: UIImage(systemName: "checkmark.circle"), style: .plain, target: self, action: #selector(addButtonTapped(_:)))
        navigationItem.rightBarButtonItem = rightButton
        rightButton.tintColor = UIColor.brown
        navigationItem.title = "Add new item"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.brown, NSAttributedString.Key.font: UIFont.roundedFont(ofSize: 20)]
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
        
        // Category Picker Constraints
        categoryPicker.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(100)
        }
        
        // Subcategory Picker Constraints
        subcategoryPicker.snp.makeConstraints { make in
            make.top.equalTo(categoryPicker.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(100)
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
        imageView.image = UIImage(named: "download20231105155350")?.withTintColor(UIColor.lightLightBrown())
        
        // Name Text Field Constraints
        nameTextField.snp.makeConstraints { make in
            make.bottom.equalTo(storeTextField.snp.top).offset(-10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        nameTextField.placeholder = "    輸入品名（必填）"
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.borderColor = UIColor.lightLightBrown().cgColor
        nameTextField.layer.cornerRadius = 10
        
        // Store Text Field Constraints
        storeTextField.snp.makeConstraints { make in
            make.bottom.equalTo(priceTextField.snp.top).offset(-10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        storeTextField.placeholder = "     輸入店家"
        storeTextField.layer.borderWidth = 1
        storeTextField.layer.borderColor = UIColor.lightLightBrown().cgColor
        storeTextField.layer.cornerRadius = 10
        
        
        // Price Text Field Constraints
        priceTextField.snp.makeConstraints { make in
            make.bottom.equalTo(contentTextField.snp.top).offset(-10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        priceTextField.placeholder = "    輸入價錢"
        priceTextField.layer.borderWidth = 1
        priceTextField.layer.borderColor = UIColor.lightLightBrown().cgColor
        priceTextField.layer.cornerRadius = 10
        
        // Content Text Field Constraints
        contentTextField.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        contentTextField.placeholder = "    輸入其他註解"
        contentTextField.layer.borderWidth = 1
        contentTextField.layer.borderColor = UIColor.lightLightBrown().cgColor
        contentTextField.layer.cornerRadius = 10
        
        // Upload image button
        uploadImageButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(imageView)
        }
        
        uploadImageButton.setTitle("新增服飾照", for: .normal)
        uploadImageButton.setTitleColor(.white, for: .normal)
        uploadImageButton.addTarget(self, action: #selector(uploadImageButtonTapped), for: .touchUpInside)
        
    }
    
    @objc func uploadImageButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
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
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            uploadImageButton.setTitle("重新選擇照片", for: .normal)
        }
        picker.dismiss(animated: true, completion: nil)
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
        let image = imageView.image?.jpegData(compressionQuality: 0.5)
        
        CoreDataManager.shared.addClothes(category: categoryName, subcategory: subcategoryName, item: itemName, price: price, store: storeName, content: content, image: image)

        
        navigationController?.popViewController(animated: true)
    }
}