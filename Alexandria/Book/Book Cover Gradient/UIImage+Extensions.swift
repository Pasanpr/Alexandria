//
//  UIImage+Extensions.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 10/13/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit

extension UIImage {
    fileprivate struct ImagePixels {
        let width: Int
        let height: Int
        let rawData: UnsafeMutableRawPointer
        
        let bytesPerPixel = 4
        var byteIndex = 0
        
        let redOffset = 0
        let greenOffset = 1
        let blueOffset = 2
        let alphaOffset = 3
        
        init(width: Int, height: Int, rawData: UnsafeMutableRawPointer) {
            self.width = width
            self.height = height
            self.rawData = rawData
        }
        
        var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
            let alpha = CGFloat(rawData.load(fromByteOffset: byteIndex + alphaOffset, as: UInt8.self))
            let red = CGFloat(rawData.load(fromByteOffset: byteIndex + redOffset, as: UInt8.self))/255.0
            let green = CGFloat(rawData.load(fromByteOffset: byteIndex + greenOffset, as: UInt8.self))/255.0
            let blue = CGFloat(rawData.load(fromByteOffset: byteIndex + blueOffset, as: UInt8.self))/255.0
            
            return (red, green, blue, alpha)
        }
        
        var red: CGFloat {
            return rgba.red
        }
        
        var green: CGFloat {
            return rgba.green
        }
        
        var blue: CGFloat {
            return rgba.blue
        }
        
        var alpha: CGFloat {
            return rgba.alpha
        }
        
        mutating func moveTo(x: Int, y: Int) {
            let bytesPerRow = bytesPerPixel * width
            byteIndex = bytesPerRow * y + bytesPerPixel * x
        }
    }
    
    func dominantColorsForSize(_ size: CGSize = .zero) -> CountedSet<UIColor> {
        var scaleDownSize = size
        
        if scaleDownSize == CGSize.zero {
            let ratio = self.size.width/self.size.height
            let modifiedWidth: CGFloat = 150
            scaleDownSize = CGSize(width: modifiedWidth, height: modifiedWidth/ratio)
        }
        
        let width = Int(scaleDownSize.width)
        let height = Int(scaleDownSize.height)
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let rawData = calloc(height * width * bytesPerPixel, MemoryLayout<CUnsignedChar>.size)
        
        defer {
            free(rawData)
        }
        
        let bitsPerComponent = 8
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        
        guard let context = CGContext(data: rawData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            fatalError("CGContextCretion failed")
        }
        
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        context.draw(self.cgImage!, in: rect)
        
        
        var imagePixels = ImagePixels(width: width, height: height, rawData: rawData!)
        var countedSet = CountedSet<UIColor>()
        
        for x in 0..<width {
            for y in 0..<height {
                imagePixels.moveTo(x: x, y: y)
                
                let newColor = UIColor(red: imagePixels.red, green: imagePixels.green, blue: imagePixels.blue, alpha: imagePixels.alpha)
                
                // Check the colors set to see if it contains a color extremely
                // similar to the current color. If it does, we'll then increase
                // the count on it by adding it to the counted set.
                // If there are no colors in color
                if let existingColor = countedSet.colorExtremelySimilar(to: newColor) {
                    countedSet.add(existingColor)
                } else {
                    countedSet.add(newColor)
                }
            }
        }
        
        return countedSet
    }
}

