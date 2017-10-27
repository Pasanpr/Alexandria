//
//  UIColor+Extensions.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 10/13/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit

extension UIColor {
    enum UIColorInputError : Error {
        case missingHashMarkAsPrefix,
        unableToScanHexValue,
        mismatchedHexStringLength,
        unableToOutputHexStringForWideDisplayColor
    }
    
    /**
     The shorthand three-digit hexadecimal representation of color.
     #RGB defines to the color #RRGGBB.
     
     - parameter hex3: Three-digit hexadecimal value.
     - parameter alpha: 0.0 - 1.0. The default is 1.0.
     */
    public convenience init(hex3: UInt16, alpha: CGFloat = 1) {
        let divisor = CGFloat(15)
        let red     = CGFloat((hex3 & 0xF00) >> 8) / divisor
        let green   = CGFloat((hex3 & 0x0F0) >> 4) / divisor
        let blue    = CGFloat( hex3 & 0x00F      ) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /**
     The shorthand four-digit hexadecimal representation of color with alpha.
     #RGBA defines to the color #RRGGBBAA.
     
     - parameter hex4: Four-digit hexadecimal value.
     */
    public convenience init(hex4: UInt16) {
        let divisor = CGFloat(15)
        let red     = CGFloat((hex4 & 0xF000) >> 12) / divisor
        let green   = CGFloat((hex4 & 0x0F00) >>  8) / divisor
        let blue    = CGFloat((hex4 & 0x00F0) >>  4) / divisor
        let alpha   = CGFloat( hex4 & 0x000F       ) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /**
     The six-digit hexadecimal representation of color of the form #RRGGBB.
     
     - parameter hex6: Six-digit hexadecimal value.
     */
    public convenience init(hex6: UInt32, alpha: CGFloat = 1) {
        let divisor = CGFloat(255)
        let red     = CGFloat((hex6 & 0xFF0000) >> 16) / divisor
        let green   = CGFloat((hex6 & 0x00FF00) >>  8) / divisor
        let blue    = CGFloat( hex6 & 0x0000FF       ) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /**
     The six-digit hexadecimal representation of color with alpha of the form #RRGGBBAA.
     
     - parameter hex8: Eight-digit hexadecimal value.
     */
    public convenience init(hex8: UInt32) {
        let divisor = CGFloat(255)
        let red     = CGFloat((hex8 & 0xFF000000) >> 24) / divisor
        let green   = CGFloat((hex8 & 0x00FF0000) >> 16) / divisor
        let blue    = CGFloat((hex8 & 0x0000FF00) >>  8) / divisor
        let alpha   = CGFloat( hex8 & 0x000000FF       ) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /**
     The rgba string representation of color with alpha of the form #RRGGBBAA/#RRGGBB, throws error.
     
     - parameter rgba: String value.
     */
    public convenience init(rgba_throws rgba: String) throws {
        guard rgba.hasPrefix("#") else {
            throw UIColorInputError.missingHashMarkAsPrefix
        }
        
        let hexString: String = rgba.substring(from: rgba.characters.index(rgba.startIndex, offsetBy: 1))
        var hexValue:  UInt32 = 0
        
        guard Scanner(string: hexString).scanHexInt32(&hexValue) else {
            throw UIColorInputError.unableToScanHexValue
        }
        
        switch (hexString.characters.count) {
        case 3:
            self.init(hex3: UInt16(hexValue))
        case 4:
            self.init(hex4: UInt16(hexValue))
        case 6:
            self.init(hex6: hexValue)
        case 8:
            self.init(hex8: hexValue)
        default:
            throw UIColorInputError.mismatchedHexStringLength
        }
    }
    
    /**
     The rgba string representation of color with alpha of the form #RRGGBBAA/#RRGGBB, fails to default color.
     
     - parameter rgba: String value.
     */
    public convenience init(_ rgba: String, defaultColor: UIColor = UIColor.clear) {
        guard let color = try? UIColor(rgba_throws: rgba) else {
            self.init(cgColor: defaultColor.cgColor)
            return
        }
        self.init(cgColor: color.cgColor)
    }
    
    /**
     Hex string of a UIColor instance, throws error.
     
     - parameter includeAlpha: Whether the alpha should be included.
     */
    public func hexStringThrows(_ includeAlpha: Bool = true) throws -> String  {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        guard r >= 0 && r <= 1 && g >= 0 && g <= 1 && b >= 0 && b <= 1 else {
            throw UIColorInputError.unableToOutputHexStringForWideDisplayColor
        }
        
        if (includeAlpha) {
            return String(format: "#%02X%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255), Int(a * 255))
        } else {
            return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
        }
    }
    
    /**
     Hex string of a UIColor instance, fails to empty string.
     
     - parameter includeAlpha: Whether the alpha should be included.
     */
    public func hexString(_ includeAlpha: Bool = true) -> String  {
        guard let hexString = try? hexStringThrows(includeAlpha) else {
            return ""
        }
        return hexString
    }
    
    convenience init(hue: CGFloat, saturation: CGFloat, luminance: CGFloat, alpha: CGFloat) {
        // https://axonflux.com/handy-rgb-to-hsl-and-rgb-to-hsv-color-model-c
        func hue2rgb(p: CGFloat, q: CGFloat, t: CGFloat) -> CGFloat {
            if (t < 0) { return t + 1 }
            if (t > 1) { return t - 1 }
            if (t < 1/6) { return p + (q - p) * 6 * t }
            if (t < 1/2) { return q }
            if (t < 2/3) { return p + (q - p) * (2/3 - t) * 6 }
            return p
        }
        
        if saturation == 0 {
            self.init(red: luminance, green: luminance, blue: luminance, alpha: alpha)
        } else {
            let q = luminance < 0.5 ? luminance * (1 + saturation) : luminance + saturation - luminance * saturation
            let p = 2 * luminance - q
            let r = hue2rgb(p: p, q: q, t: hue + 1/3)
            let g = hue2rgb(p: p, q: q, t: hue)
            let b = hue2rgb(p: p, q: q, t: hue - 1/3)
            
            self.init(red: r, green: g, blue: b, alpha: alpha)
        }
    }
    
    /// Returns the red, green, blue and alpha values
    public var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r,g,b,a)
    }
    
    /// Returns hue, saturation and lightness values
    public var hsl: (hue: CGFloat, saturation: CGFloat, luminance: CGFloat) {
        let maximum = max(rgba.red, max(rgba.green, rgba.blue))
        let mininimum = min(rgba.red, min(rgba.green, rgba.blue))
        
        let delta = maximum - mininimum
        
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        let luminance: CGFloat = (maximum + mininimum) / 2
        
        if delta != 0 {
            if luminance < 0.5 {
                saturation = delta / (maximum + mininimum)
            }
            else {
                saturation = delta / (2 - maximum - mininimum)
            }
            
            if rgba.red == maximum {
                hue = (rgba.green - rgba.blue) / delta + (rgba.green < rgba.blue ? 6 : 0)
            }
            else if rgba.green == maximum {
                hue = (rgba.blue - rgba.red) / delta + 2
            }
            else if rgba.blue == maximum {
                hue = (rgba.red - rgba.green) / delta + 4
            }
        }
        
        hue /= 6
        
        return (hue, saturation, luminance)
    }
    
    /// Returns saturation value
    public var saturation: CGFloat {
        return hsl.saturation
    }
    
    /// Returns luma value
    public var luma: CGFloat {
        let lumaRed = 0.2126 * rgba.red
        let lumaGreen = 0.7152 * rgba.green
        let lumaBlue = 0.0722 * rgba.blue
        let luma = lumaRed + lumaGreen + lumaBlue
        
        return luma
    }
    
    /// Returns [CIE 1931 XYZ]((https://en.wikipedia.org/wiki/CIE_1931_color_space#Meaning_of_X.2C_Y_and_Z)) color space values
    public var xyz: (x: CGFloat, y: CGFloat, z: CGFloat) {
        
        func invertColorComponent(_ component: CGFloat) -> CGFloat {
            // http://www.color.org/srgb.pdf
            
            let threshold: CGFloat = 0.04045
            
            if component > threshold {
                let intermediate = (component + 0.055)/1.055
                return pow(intermediate, 2.4)
            } else {
                return component/12.92
            }
        }
        
        let red = invertColorComponent(rgba.red) * 100
        let green = invertColorComponent(rgba.green) * 100
        let blue = invertColorComponent(rgba.blue) * 100
        
        // See link for matrix multiplication
        // https://en.wikipedia.org/wiki/SRGB
        
        let x: CGFloat = (red * 0.4124) + (green * 0.3576) + (blue * 0.1805)
        let y: CGFloat = (red * 0.2126) + (green * 0.7152) + (blue * 0.0722)
        let z: CGFloat = (red * 0.0193) + (green * 0.1192) + (blue * 0.9505)
        
        return (x, y, z)
    }
    
    /// Returns the [CIE Lab](https://en.wikipedia.org/wiki/Lab_color_space) color space values
    ///
    /// l: lightness of the color as a value ranging between 0 and 100. 0 indicates black.
    ///
    /// a: the position of the color between green and red. Negative values indicate green while positive values indicate magenta
    ///
    /// b: the position of the color between blue and yellow. Negative values indicate blue and positive values indicate yellow
    public var lab: (l: CGFloat, a: CGFloat, b: CGFloat) {
        
        func xyzTransformation(x: CGFloat, y: CGFloat, z: CGFloat) -> (x: CGFloat, y: CGFloat, z: CGFloat) {
            func forwardTransformation(_ value: CGFloat) -> CGFloat {
                let threshold: CGFloat = 0.008856
                
                if value > threshold {
                    return pow(value, 1/3)
                } else {
                    return ((7.787 * value) + (16/116))
                }
            }
            
            let transformedX = forwardTransformation(x/95.047)
            let transformedY = forwardTransformation(y/100.0)
            let transformedZ = forwardTransformation(z/108.883)
            
            return (transformedX, transformedY, transformedZ)
        }
        
        let xyzTransformed = xyzTransformation(x: self.xyz.x, y: self.xyz.y, z: self.xyz.z)
        
        let l = (116 * xyzTransformed.y) - 16
        let a = 500 * (xyzTransformed.x - xyzTransformed.y)
        let b = 200 * (xyzTransformed.y - xyzTransformed.z)
        
        return (l, a, b)
    }
    
    
    /// Determine the distance between two colors based on the way humans perceive
    /// them using the Sharma 2004 alteration of the CIEDE2000 algorithm
    ///
    /// - Parameter color: A UIColor to compare
    /// - Returns: A CGFloat representing the [Delta E](https://en.wikipedia.org/wiki/Color_difference#CIELAB_Delta_E.2A) value
    public func distance(to color: UIColor) -> CGFloat {
        // Sharma 2004 alteration to CIEDE2000: http://www.ece.rochester.edu/~gsharma/ciede2000/ciede2000noteCRNA.pdf
        // https://github.com/jathu/sweetercolor/blob/master/Sweetercolor/Sweetercolor.swift#L378
        
        func rad2deg(r: CGFloat) -> CGFloat {
            return r * CGFloat(180/Double.pi)
        }
        
        func deg2rad(d: CGFloat) -> CGFloat {
            return d * CGFloat(Double.pi/180)
        }
        
        let k_l = CGFloat(1), k_c = CGFloat(1), k_h = CGFloat(1)
        
        let LAB1 = self.lab
        let L_1 = LAB1.l, a_1 = LAB1.a, b_1 = LAB1.b
        
        let LAB2 = color.lab
        let L_2 = LAB2.l, a_2 = LAB2.a, b_2 = LAB2.b
        
        let C_1ab = sqrt(pow(a_1, 2) + pow(b_1, 2))
        let C_2ab = sqrt(pow(a_2, 2) + pow(b_2, 2))
        let C_ab  = (C_1ab + C_2ab)/2
        
        let G = 0.5 * (1 - sqrt(pow(C_ab, 7)/(pow(C_ab, 7) + pow(25, 7))))
        let a_1_p = (1 + G) * a_1
        let a_2_p = (1 + G) * a_2
        
        let C_1_p = sqrt(pow(a_1_p, 2) + pow(b_1, 2))
        let C_2_p = sqrt(pow(a_2_p, 2) + pow(b_2, 2))
        
        // Read note 1 (page 23) for clarification on radians to hue degrees
        let h_1_p = (b_1 == 0 && a_1_p == 0) ? 0 : (atan2(b_1, a_1_p) + CGFloat(2 * Double.pi)) * CGFloat(180/Double.pi)
        let h_2_p = (b_2 == 0 && a_2_p == 0) ? 0 : (atan2(b_2, a_2_p) + CGFloat(2 * Double.pi)) * CGFloat(180/Double.pi)
        
        let deltaL_p = L_2 - L_1
        let deltaC_p = C_2_p - C_1_p
        
        var h_p: CGFloat = 0
        if (C_1_p * C_2_p) == 0 {
            h_p = 0
        } else if fabs(h_2_p - h_1_p) <= 180 {
            h_p = h_2_p - h_1_p
        } else if (h_2_p - h_1_p) > 180 {
            h_p = h_2_p - h_1_p - 360
        } else if (h_2_p - h_1_p) < -180 {
            h_p = h_2_p - h_1_p + 360
        }
        
        let deltaH_p = 2 * sqrt(C_1_p * C_2_p) * sin(deg2rad(d: h_p/2))
        
        let L_p = (L_1 + L_2)/2
        let C_p = (C_1_p + C_2_p)/2
        
        var h_p_bar: CGFloat = 0
        if (h_1_p * h_2_p) == 0 {
            h_p_bar = h_1_p + h_2_p
        } else if fabs(h_1_p - h_2_p) <= 180 {
            h_p_bar = (h_1_p + h_2_p)/2
        } else if fabs(h_1_p - h_2_p) > 180 && (h_1_p + h_2_p) < 360 {
            h_p_bar = (h_1_p + h_2_p + 360)/2
        } else if fabs(h_1_p - h_2_p) > 180 && (h_1_p + h_2_p) >= 360 {
            h_p_bar = (h_1_p + h_2_p - 360)/2
        }
        
        let T1 = cos(deg2rad(d: h_p_bar - 30))
        let T2 = cos(deg2rad(d: 2 * h_p_bar))
        let T3 = cos(deg2rad(d: (3 * h_p_bar) + 6))
        let T4 = cos(deg2rad(d: (4 * h_p_bar) - 63))
        let T = 1 - rad2deg(r: 0.17 * T1) + rad2deg(r: 0.24 * T2) - rad2deg(r: 0.32 * T3) + rad2deg(r: 0.20 * T4)
        
        let deltaTheta = 30 * exp(-pow((h_p_bar - 275)/25, 2))
        let R_c = 2 * sqrt(pow(C_p, 7)/(pow(C_p, 7) + pow(25, 7)))
        let S_l =  1 + ((0.015 * pow(L_p - 50, 2))/sqrt(20 + pow(L_p - 50, 2)))
        let S_c = 1 + (0.045 * C_p)
        let S_h = 1 + (0.015 * C_p * T)
        let R_t = -sin(deg2rad(d: 2 * deltaTheta)) * R_c
        
        // Calculate total
        
        let P1 = deltaL_p/(k_l * S_l)
        let P2 = deltaC_p/(k_c * S_c)
        let P3 = deltaH_p/(k_h * S_h)
        let deltaE = sqrt(pow(P1, 2) + pow(P2, 2) + pow(P3, 2) + (R_t * P2 * P3))
        
        return deltaE
    }
    
    /// Returns true if a color is extremely similar to the comparison color
    /// as determined by the CIE2000 delta E value
    ///
    /// - Parameter comparisonColor: Color to compare against
    /// - Returns: `true` if the detla E is less than 11, `false` otherwise
    public func isExtremelySimilar(to comparisonColor: UIColor) -> Bool {
        let imperceptibilityThreshold: CGFloat = 11.0
        return distance(to: comparisonColor) < imperceptibilityThreshold
    }
    
    public func lighten(by percentage: CGFloat) -> UIColor {
        return UIColor(hue: hsl.hue, saturation: hsl.saturation, luminance: hsl.luminance + percentage, alpha: rgba.alpha)
    }
    
    public func darken(by percentage: CGFloat) -> UIColor {
        return lighten(by: percentage * -1)
    }
}
