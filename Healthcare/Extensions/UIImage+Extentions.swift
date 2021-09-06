//
//  UIImage+Extentions.swift
//  Healthcare
//
//  Created by T T on 2021/06/13.
//

import UIKit

extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }

    func resized(toWidth width: CGFloat) -> UIImage? {
           let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
           return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image {
               _ in draw(in: CGRect(origin: .zero, size: canvas))
           }
       }
    
    func resized(size: CGSize) -> UIImage {
        // リサイズ後のサイズを指定して`UIGraphicsImageRenderer`を作成する
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { (context) in
            // 描画を行う
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
