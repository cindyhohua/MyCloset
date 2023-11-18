//
//  Extensions.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/15.
//

import UIKit

extension UIFont {
    class func roundedFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle).withDesign(.rounded)!, size: size)
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
