//
//  BSUiStyle.swift
//  BluesnapSDK
//
//  Copyright © 2020 Bluesnap. All rights reserved.
//

import Foundation

public enum DefaultStyle {

    public static var userInterfaceStyle = UIColor.darkGray;
    
    public static var tint: UIColor = {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    /// Return the color for Dark Mode
                    return UIColor.label
                } else {
                    /// Return the color for Light Mode
                    return UIColor.black
                }
            }
        } else {
            
//            if userInterfaceStyle == .dark {
//                // User Interface is Dark
//            } else {
//                // User Interface is Light
//            }
//            
            /// Return a fallback color for iOS 12 and lower.
            return BSColors.defaultlabel
        }
    }()
    
    public enum BSColors {

        public static let defaultlabel: UIColor = {
            if #available(iOS 13.0, *) {
                return UIColor.label
            } else {
                return .black
            }
        }()
        
        public static let background: UIColor = {
            if #available(iOS 13.0, *) {
                return UIColor.systemBackground
            } else {
                return tint
            }
        }()
        
        
    }
    
    

}

public let BSDynamicStyle = DefaultStyle.self

