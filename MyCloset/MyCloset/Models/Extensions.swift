//
//  Extensions.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/15.
//

import UIKit

extension UIFont {
    class func roundedFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(
            descriptor: UIFontDescriptor.preferredFontDescriptor(
                withTextStyle: .largeTitle).withDesign(.rounded)!, size: size)
        }
}

extension UIColor {
    class func lightBrown() -> UIColor {
        return UIColor(red: 1.96/2.55, green: 1.73/2.55, blue: 1.53/2.55, alpha: 1)
        }
    class func lightLightBrown() -> UIColor {
        return UIColor(red: 2.24/2.55, green: 2.16/2.55, blue: 2.07/2.55, alpha: 1)
        }
}

extension UIView {
    func asImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        return renderer.image { context in
            layer.render(in: context.cgContext)
        }
    }
}

extension UIButton {
    func addBadge(number: Int) {
        let badgeLabel = UILabel()
        badgeLabel.text = "\(number)"
        badgeLabel.textColor = .white
        badgeLabel.font = UIFont.systemFont(ofSize: 12)
        badgeLabel.textAlignment = .center
        badgeLabel.sizeToFit()
        
        let badgeSize = CGSize(width: badgeLabel.frame.width + 12, height: badgeLabel.frame.height + 4)
        
        let badgeView = UIView()
        badgeView.tag = 999
        badgeView.frame = CGRect(x: self.frame.width - 6, y: -4, width: badgeSize.width, height: badgeSize.height)
        badgeView.backgroundColor = .red
        badgeView.layer.cornerRadius = badgeSize.height / 2
        
        badgeLabel.center = CGPoint(x: badgeSize.width / 2, y: badgeSize.height / 2)
        badgeView.addSubview(badgeLabel)
        
        self.addSubview(badgeView)
    }
    
    func removeBadge() {
        for subview in self.subviews {
            if subview.tag == 999 {
                subview.removeFromSuperview()
            }
        }
    }
}
