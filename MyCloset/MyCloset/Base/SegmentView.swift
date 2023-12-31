//
//  SegmentView.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/17.
//

import UIKit

protocol SegmentControlDelegate: AnyObject {
    func changeToIndex(_ manager: SegmentView, index: Int)
}
class SegmentView: UIView {
    private var buttonTitles: [String]!
    var buttons: [UIButton]!
    private var allView: UIView!
    private var selectorView: UIView!
    var delegate: SegmentControlDelegate?
    private func configStackView() {
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        stack.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        stack.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    }
    
    private func configSelectorView() {
        allView = UIView(frame: CGRect(x: 0, y: self.frame.height, width: frame.width, height: 1.5))
        allView.backgroundColor = UIColor.lightBrown()
        let selectorWidth = frame.width / CGFloat(self.buttonTitles.count)
        selectorView = UIView(frame: CGRect(x: 0, y: self.frame.height, width: selectorWidth, height: 1.5))
        selectorView.backgroundColor = UIColor.brown
        addSubview(allView)
        addSubview(selectorView)
    }
    
    private func createButton() {
        buttons = [UIButton]()
        buttons.removeAll()
        subviews.forEach({$0.removeFromSuperview()})
        for buttonTitle in buttonTitles {
            let button = UIButton(type: .system)
            button.setTitle(buttonTitle, for: .normal)
            button.addTarget(self, action: #selector(SegmentView.buttonAction(sender:)), for: .touchUpInside)
            button.setTitleColor(UIColor.lightBrown(), for: .normal)
            buttons.append(button)
        }
        buttons[0].setTitleColor(UIColor.brown, for: .normal)
    }
    
    @objc func buttonAction(sender: UIButton) {
        for (buttonIndex, btn) in buttons.enumerated() {
            btn.setTitleColor(UIColor.lightBrown(), for: .normal)
            if btn == sender {
                let selectorPosition = frame.width/CGFloat(buttonTitles.count) * CGFloat(buttonIndex)
                self.delegate?.changeToIndex(self, index: buttonIndex)
                UIView.animate(withDuration: 0.3) {
                    self.selectorView.frame.origin.x = selectorPosition
                }
                btn.setTitleColor(UIColor.brown, for: .normal)
            }
        }
    }
    
    private func updateView() {
        createButton()
        configStackView()
        configSelectorView()
    }
    
    convenience init(frame: CGRect, buttonTitle: [String]) {
        self.init(frame: frame)
        self.buttonTitles = buttonTitle
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        updateView()
    }
    
    func setButtonTitles(buttonTitles: [String]) {
        self.buttonTitles = buttonTitles
        updateView()
    }
}
