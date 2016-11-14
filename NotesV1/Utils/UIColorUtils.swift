//
//  UIColorUtils.swift
//  NotesV1
//
//  Created by Dmitry Galimzyanov on 10.11.16.
//  Copyright © 2016 Dmitry Galimzyanov. All rights reserved.
//

import Foundation
import UIKit

class UIColorUtils {
    static func hexStringToUIColor (_ hex: String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if (cString.characters.count) != 6 {
            return UIColor.gray
        }

        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    static func uiColorToHexString (color: UIColor) -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        color.getRed(&r, green: &g, blue: &b, alpha: &a)

        let rI = UInt8(Double(r) * 255.0)
        let gI = UInt8(Double(g) * 255.0)
        let bI = UInt8(Double(b) * 255.0)
        //let aI = UInt8(Double(a) * 255.0)

        return String(format: "#%02X%02X%02X", rI, gI, bI)
    }
}

extension UIColor {
    convenience init(hexRgbString: String) {
        let cString: String = hexRgbString.trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
        let scanner = Scanner(string: cString)

        if cString.hasPrefix("#") {
            scanner.scanLocation = 1
        }

        var rgbValue: UInt32 = 0
        scanner.scanHexInt32(&rgbValue)

        let mask = 0xFF
        let r = Int(rgbValue >> 16) & mask
        let g = Int(rgbValue >> 8) & mask
        let b = Int(rgbValue) & mask

        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0

        self.init(red:red, green:green, blue:blue, alpha:1)
    }

    func toHexRgbString() -> String {
        return UIColorUtils.uiColorToHexString(color: self)
    }
}
