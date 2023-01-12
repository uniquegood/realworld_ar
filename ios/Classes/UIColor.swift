//
//  UIColor.swift
//  Real World
//
//  Created by BumMo Koo on 2018. 5. 16..
//  Copyright © 2018년 Unique Good Company. All rights reserved.
//

import UIKit

extension UIColor {
    static let appTint: UIColor = #colorLiteral(red: 0.6235294118, green: 0.5019607843, blue: 0.7803921569, alpha: 1)
    static let appBackgroundMain: UIColor = #colorLiteral(red: 0.1294117647, green: 0.08235294118, blue: 0.1725490196, alpha: 1)
    static let appBarTint: UIColor = .appTint
    static let appNavigationBar: UIColor = #colorLiteral(red: 0.1176470588, green: 0.07058823529, blue: 0.1725490196, alpha: 1)
    static let appTabBar: UIColor = #colorLiteral(red: 0.07058823529, green: 0.03921568627, blue: 0.1411764706, alpha: 1)
    static let appTabTintHighlighted: UIColor = #colorLiteral(red: 0.9764705882, green: 0.8549019608, blue: 0.3725490196, alpha: 1)
    static let appPlaceholder: UIColor = .appTabBar
    static let appText: UIColor = .appTabBar
    static let appButton: UIColor = .appTabBar
    static let appLoading: UIColor = .appBackgroundMain
    static let androidAppColor: UIColor = .hexStringToColor("482871")
    static let communityCell: UIColor = .hexStringToColor("543673")
    static let communityTableView: UIColor = .hexStringToColor("E0E0E0")
    static let communitySeparateLine: UIColor = .hexStringToColor("D5D5D5")
    static let communityLikeIt: UIColor = .hexStringToColor("B58BE0")
    
    static let questCompleted: UIColor = #colorLiteral(red: 0.7843137255, green: 0.2156862745, blue: 0.2549019608, alpha: 1)
    static let questInProgress: UIColor = .appTabBar
    
    static let whiteThree: UIColor = UIColor(white: 219.0 / 255.0, alpha: 1.0)
    static let whiteFour: UIColor = UIColor(white: 234.0 / 255.0, alpha: 1.0)
    
    static let veryLightPink: UIColor = UIColor(white: 213.0 / 255.0, alpha: 1.0)
    static let veryLightPink2: UIColor = UIColor(white: 237.0 / 255.0, alpha: 1.0)
    
    static let deepLavender: UIColor = UIColor(red: 132.0 / 255.0, green: 98.0 / 255.0, blue: 180.0 / 255.0, alpha: 1.0)
    static let deepLavenderTwo: UIColor = UIColor(red: 122.0 / 255.0, green: 88.0 / 255.0, blue: 168.0 / 255.0, alpha: 1.0)
    
    static let greyish: UIColor = UIColor(white: 168.0 / 255.0, alpha: 1.0)
    static let greyishTwo: UIColor = UIColor(white: 185.0 / 255.0, alpha: 1.0)
    
    static let palePurple: UIColor = UIColor(red: 197.0 / 255.0, green: 176.0 / 255.0, blue: 226.0 / 255.0, alpha: 1.0)
    static let palePurpleTwo: UIColor = UIColor(red: 183.0 / 255.0, green: 157.0 / 255.0, blue: 211.0 / 255.0, alpha: 1.0)
    
    static let warmGrey: UIColor = UIColor(white: 144.0 / 255.0, alpha: 1.0)
    static let brownGrey: UIColor = UIColor(white: 136.0 / 255.0, alpha: 1.0)
    static let warmGreyThree: UIColor = UIColor(white: 139.0 / 255.0, alpha: 1.0)
    static let warmGreyFour: UIColor = UIColor(white: 134.0 / 255.0, alpha: 1.0)
    
    static let lightEggplant: UIColor = UIColor(red: 112.0 / 255.0, green: 75.0 / 255.0, blue: 155.0 / 255.0, alpha: 1.0)
    static let lightMustard: UIColor = UIColor(red: 247.0 / 255.0, green: 220.0 / 255.0, blue: 95.0 / 255.0, alpha: 1.0)
    
    static let straw: UIColor = UIColor(red: 250.0 / 255.0, green: 236.0 / 255.0, blue: 128.0 / 255.0, alpha: 1.0)
    static let lavender: UIColor = UIColor(red: 212.0 / 255.0, green: 187.0 / 255.0, blue: 239.0 / 255.0, alpha: 1.0)
    static let black16: UIColor = UIColor(white: 0.0, alpha: 0.16)
    static let twilight: UIColor = UIColor(red: 112.0 / 255.0, green: 78.0 / 255.0, blue: 155.0 / 255.0, alpha: 1.0)
    static let blueberry: UIColor = UIColor(red: 102.0 / 255.0, green: 69.0 / 255.0, blue: 142.0 / 255.0, alpha: 1.0)
    
    static let eggplant: UIColor = UIColor(red: 19.0 / 255.0, green: 7.0 / 255.0, blue: 39.0 / 255.0, alpha: 1.0)
    static let purple: UIColor = UIColor(red: 133.0 / 255.0, green: 41.0 / 255.0, blue: 185.0 / 255.0, alpha: 1.0)
    
    
    
    static let primaryPurple100: UIColor = UIColor(red: 200.0 / 255.0, green: 105.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    static let primaryPurpleTint01: UIColor = UIColor(red: 249.0 / 255.0, green: 240.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    static let primaryPurpleTint04: UIColor = UIColor(red: 225.0 / 255.0, green: 172.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    static let primaryPurpleDark: UIColor = UIColor(red: 137.0 / 255.0, green: 29.0 / 255.0, blue: 199.0 / 255.0, alpha: 1.0)
    static let primaryPurpleOpacity: UIColor = UIColor(red: 137.0 / 255.0, green: 29.0 / 255.0, blue: 199.0 / 255.0, alpha: 0.1)
    static let primaryPurpleShade01: UIColor = UIColor(red: 170.0 / 255.0, green: 89.0 / 255.0, blue: 217.0 / 255.0, alpha: 1.0)
    static let secindaryYellow: UIColor = UIColor(red: 255.0 / 255.0, green: 216.0 / 255.0, blue: 20.0 / 255.0, alpha: 1.0)
    static let secindaryBlueShade01: UIColor = UIColor(red: 107.0 / 255.0, green: 165.0 / 255.0, blue: 217.0 / 255.0, alpha: 1.0)
    
    
    static let warmGreyFive: UIColor = UIColor(white: 112.0 / 255.0, alpha: 1.0)
    static let grayTintz1: UIColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
    static let grayTint01: UIColor = UIColor(red: 237.0 / 255.0, green: 237.0 / 255.0, blue:  237.0 / 255.0, alpha: 1.0)
    static let grayTint03: UIColor = UIColor(red: 195.0 / 255.0, green: 195.0 / 255.0, blue:  195.0 / 255.0, alpha: 1.0)
    static let grayTint04: UIColor = UIColor(red: 169.0 / 255.0, green: 169.0 / 255.0, blue:  169.0 / 255.0, alpha: 1.0)
    static let gray100: UIColor = UIColor(red: 98.0 / 255.0, green: 98.0 / 255.0, blue:  98.0 / 255.0, alpha: 1.0)
    static let gray5: UIColor = UIColor(red: 46.0 / 255.0, green: 46.0 / 255.0, blue:  46.0 / 255.0, alpha: 1.0)
    static let grayTintz2: UIColor = UIColor(red: 244.0 / 255.0, green: 244.0 / 255.0, blue:  244.0 / 255.0, alpha: 1.0)
    static let secondaryDarkBlue100: UIColor = UIColor(red: 40.0 / 255.0, green: 47.0 / 255.0, blue:  137.0 / 255.0, alpha: 1.0)
    static let secondaryYellow: UIColor = UIColor(red: 255.0 / 255.0, green: 216.0 / 255.0, blue:  20.0 / 255.0, alpha: 1.0)
    static let statusRed: UIColor = UIColor(red: 211.0 / 255.0, green: 0, blue:  0, alpha: 1.0)
    static let grayShade01: UIColor = UIColor(red: 83.0 / 255.0, green: 83.0 / 255.0, blue:  83.0 / 255.0, alpha: 1.0)
    static let grayShade03: UIColor = UIColor(red: 54.0 / 255.0, green: 54.0 / 255.0, blue:  54.0 / 255.0, alpha: 1.0)
    static let grayShade04: UIColor = UIColor(red: 39.0 / 255.0, green: 39.0 / 255.0, blue:  39.0 / 255.0, alpha: 1.0)
    static let secondaryYelloTint05: UIColor = UIColor(red: 255.0 / 255.0, green: 228.0 / 255.0, blue:  90.0 / 255.0, alpha: 1.0)
    
    static let questLocked = UIColor.appTabBar.withAlphaComponent(0.25)
    
    static let defaultTableViewFooterColor = UIColor.init(displayP3Red: 0.298039, green: 0.337255, blue: 0.423529, alpha: 1.0)
    
    /// # 문자가 지워지고 대문자로 변경된 hex컬러 코드를 UIColor로 리턴해주는 클래스 메서드
    ///
    /// - Parameter hexStr: 넣어진 문자
    /// - Returns: 컬러 코드에 맞는 UIColor
    static func hexStringToColor(_ hexStr: String) -> UIColor {
        var rgbValue:UInt32 = 0
        Scanner(string: hexStr).scanHexInt32(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    static func hexStringToColor(_ hexStr: String, with alpha: CGFloat) -> UIColor {
        var rgbValue:UInt32 = 0
        Scanner(string: hexStr).scanHexInt32(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
