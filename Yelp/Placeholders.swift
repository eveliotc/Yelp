//
//  Placeholders.swift
//  Flicks
//
//  Created by Evelio Tarazona on 10/23/16.
//  Copyright © 2016 Evelio Tarazona. All rights reserved.
//

import Foundation
import UIKit

public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

public struct Placeholders {

    public static var image: UIImage {
        get {
            return UIImage(color: Colors.placeholder)!
        }
    }
}
