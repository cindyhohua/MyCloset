//
//  NewPostViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/16.
//

import UIKit
import SnapKit

class NewPostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var postion: [CGPoint] = []
    var tableView: UITableView!
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
    
    func pickPhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                imageView.image = pickedImage
                // 在这里可以启用按钮等来标记照片
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
                imageView.addGestureRecognizer(tapGestureRecognizer)
                imageView.isUserInteractionEnabled = true
            }

            dismiss(animated: true, completion: nil)
        }
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: imageView)
        postion.append(location)
        print("qq",location)
        createButton(at: location)
    }
    
    func createButton(at position: CGPoint) {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: position.x - 15, y: position.y - 15, width: 30, height: 30)
        button.backgroundColor = .white
        button.layer.cornerRadius = 15
        button.setTitle("\(self.postion.count)", for: .normal)
        button.titleLabel?.textColor = .brown
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        imageView.addSubview(button)
    }

    // 处理按钮点击事件
    @objc func buttonTapped(_ sender: UIButton) {
//        sender.removeFromSuperview()
    }

    func setup() {
        view.backgroundColor = .white
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
            imageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.4)
        ])
    }
}

extension NewPostViewController: UITableViewDelegate, UITableViewDataSource{
    func setupTableView() {
            tableView = UITableView()
            tableView.delegate = self
            tableView.dataSource = self
            tableView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tableView)

            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }

    // UITableViewDataSource 方法
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // 这里表示只有一个可输入的单元格
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InputCell", for: indexPath) as! HomePageTableCell
        // 在这里配置输入单元格的内容和样式
        return cell
    }
}
