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
