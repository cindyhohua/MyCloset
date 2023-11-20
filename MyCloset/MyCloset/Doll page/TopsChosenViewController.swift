//
//  TopsChosenViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/20.
//

import UIKit
import SnapKit

class TopsChosenViewController: UIViewController {
    var cloth: ClothesStruct?
    private var button1 = UIButton()
    private var button2 = UIButton()
    private var button3 = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let leftButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward.circle"), style: .plain, target: self, action: #selector(backButtonTapped))
            navigationItem.leftBarButtonItem = leftButton
            leftButton.tintColor = UIColor.brown
        navigationItem.title = "Choose type"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.brown, NSAttributedString.Key.font: UIFont.roundedFont(ofSize: 20)]
        setup()
    }
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    func setup() {
        view.addSubview(button1)
        view.addSubview(button2)
        view.addSubview(button3)
        button2.snp.makeConstraints { make in
            make.center.equalTo(view)
            make.height.equalTo(50)
            make.width.equalTo(120)
        }
        button2.setTitle("罩衫", for: .normal)
        button2.backgroundColor = .brown
        button2.setTitleColor(.white, for: .normal)
        button2.layer.cornerRadius = 8
        button2.addTarget(self, action: #selector(go2), for: .touchUpInside)
        
        button1.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.bottom.equalTo(button2.snp.top).offset(-100)
            make.height.equalTo(50)
            make.width.equalTo(120)
        }
        button1.setTitle("上衣", for: .normal)
        button1.backgroundColor = .brown
        button1.setTitleColor(.white, for: .normal)
        button1.layer.cornerRadius = 8
        button1.addTarget(self, action: #selector(go1), for: .touchUpInside)
        
        button3.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(button2.snp.bottom).offset(100)
            make.height.equalTo(50)
            make.width.equalTo(120)
        }
        button3.setTitle("外套", for: .normal)
        button3.backgroundColor = .brown
        button3.setTitleColor(.white, for: .normal)
        button3.layer.cornerRadius = 8
        button3.addTarget(self, action: #selector(go3), for: .touchUpInside)
    }
    @objc func go1() {
        let secondViewController = PaperDollTopsViewController()
        secondViewController.cloth = cloth
        navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    @objc func go2() {
        let secondViewController = PaperDollTopsViewController()
        secondViewController.cloth = cloth
        secondViewController.neckline = neckline2
        secondViewController.hem = hem2
        secondViewController.sleeve = sleeve2
        secondViewController.pattern = pattern2
        navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    @objc func go3() {
        let secondViewController = PaperDollTopsViewController()
        secondViewController.cloth = cloth
        secondViewController.neckline = neckline3
        secondViewController.hem = hem3
        secondViewController.sleeve = sleeve3
        secondViewController.pattern = pattern3
        navigationController?.pushViewController(secondViewController, animated: true)
    }
}
