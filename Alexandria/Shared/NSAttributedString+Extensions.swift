//
//  NSAttributedString+Extensions.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 9/20/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation
import UIKit

extension NSAttributedString {
    /// Returns an NSRange value for the entire attributed string
    var stringRange: NSRange {
        return NSMakeRange(0, length)
    }
    
    /// Returns true if the attributed string contains a font attribute
    var hasFontAttribute: Bool {
        guard !self.string.isEmpty else { return false }
        guard let _ = self.attribute(.font, at: 0, effectiveRange: nil) as? UIFont else { return false }
        return true
    }
    
    /// Returns a copy of the attributed string with the font attribute added.
    /// If the attributed string already contains a font attribute, self is returned
    /// as a copy.
    func copyWithAddedFontAttribute(_ font: UIFont) -> NSAttributedString {
        if !hasFontAttribute {
            let copy = NSMutableAttributedString(attributedString: self)
            copy.addAttribute(.font, value: font, range: self.stringRange)
            return copy
        }
        
        return self.copy() as! NSAttributedString
    }
    
    /// Returns text at a given line
    ///
    /// - Parameter lineRef: The line from which to obtain the string range.
    /// - Returns: An attributed string slice obtained from the original string using the range obtained.
    func text(for lineRef: CTLine) -> NSAttributedString {
        let lineRangeRef = CTLineGetStringRange(lineRef)
        let range = NSMakeRange(lineRangeRef.location, lineRangeRef.length)
        return self.attributedSubstring(from: range)
    }
    
    /// Returns an array of lines that make up a frame defined by the width provided
    ///
    /// - Parameter width: The width that defines a frame to obtain the line array from
    /// - Returns: This function returns an array of CTLine objects that are obtained by rendering the attributed string in a frame defined by the width provided.
    func lines(for width: CGFloat) -> [CTLine] {
        let rect = CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude)
        let bezierPath = UIBezierPath(rect: rect)
        let frameSetterRef = CTFramesetterCreateWithAttributedString(self)
        let frameRef = CTFramesetterCreateFrame(frameSetterRef, CFRange(location: 0, length: 0), bezierPath.cgPath, nil)
        
        let lines = CTFrameGetLines(frameRef) as! [CTLine]
        return lines
    }
    
    func boundingRect(for width: CGFloat) -> CGRect {
        return self.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude),
                                 options: .usesLineFragmentOrigin, context: nil)
    }
}
