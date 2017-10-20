//
//  ExpandableLabel.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 9/20/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation
import UIKit

final class ExpandableLabel: UILabel {
    
    typealias LineIndexTuple = (line: CTLine, index: Int)
    
    enum TextReplacement {
        case character
        case word
    }
    
    // MARK: Configurable
    
    var isCollapsed: Bool = true {
        didSet {
            // Set attributed text
            // Set number of lines
        }
    }
    
    /// Set `true` if the label can be expanded from collapsed state.
    /// Default is `true`
    var isExpandable: Bool = true
    
    /// Set `true` is the label can be collapsed from expanded state.
    /// Default is `false`
    var isCollapsible: Bool = false
    
    /// The attributed truncation token to be used at the end of the collapsed label.
    /// The default value is "More". Ellipses are prepended to all truncation tokens by
    /// default.
    var attributedTruncationToken: NSAttributedString! {
        didSet {
            self.attributedTruncationToken = attributedTruncationToken.copyWithAddedFontAttribute(font)
        }
    }
    
    var textReplacement: TextReplacement = .word
    
    override var text: String? {
        set(text) {
            if let text = text {
                self.attributedText = NSAttributedString(string: text)
            } else {
                self.attributedText = nil
            }
        }
        
        get {
            return self.attributedText?.string
        }
    }
    
    override var attributedText: NSAttributedString? {
        set(attributedText) {
            if let attributedText = attributedText?.copyWithAddedFontAttribute(font), attributedText.length > 0 {
                // Calculate number of lines
                self.collapsedText = collapsedText(with: attributedText, withTruncationToken: attributedTruncationToken)
                // Assign expandedText
                super.attributedText = collapsedText
            }
        }
        
        get {
            return super.attributedText
        }
    }
    
    override var numberOfLines: Int {
        didSet {
            numberOfCollapsedLines = numberOfLines
        }
    }
    
    private var customFont: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    
    override var font: UIFont! {
        didSet {
            customFont = font
            attributedTruncationToken = NSAttributedString(string: "More", attributes: [.font: UIFont.boldSystemFont(ofSize: customFont.pointSize)])
        }
    }
    
    // MARK: Private
    
    private var expandedText: NSAttributedString?
    private var collapsedText: NSAttributedString?
    private var linkRect: CGRect = .zero
    private var numberOfCollapsedLines = 0
    private var collapsedLinkTextRange: NSRange?
    private var expandedLinkTextRange: NSRange?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDefaults()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    private func setupDefaults() {
        isUserInteractionEnabled = true
        lineBreakMode = .byClipping
        numberOfLines = 5
        attributedTruncationToken = NSAttributedString(string: "More", attributes: [.font: UIFont.boldSystemFont(ofSize: customFont.pointSize)])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func sizeToFit() {
        super.sizeToFit()
    }
    
    private func collapsedText(with text: NSAttributedString?, withTruncationToken token: NSAttributedString) -> NSAttributedString? {
        guard let text = text else { return nil }
        let lines = text.lines(for: frame.size.width)
        
        if numberOfCollapsedLines > 0 && numberOfCollapsedLines < lines.count {
            let lastLineRef = lines[numberOfCollapsedLines-1]
            let lineIndex: LineIndexTuple = (lastLineRef, numberOfCollapsedLines-1)
            let modifiedLastLine = replacedWordInText(text, atLineIndex: lineIndex, withTruncationToken: token)
            
            let collapsedLines = NSMutableAttributedString()
            for index in 0..<lineIndex.index {
                collapsedLines.append(text.text(for: lines[index]))
            }
            collapsedLines.append(modifiedLastLine)
            
            return collapsedLines
        }
        
        return text
    }
    
    private func textFitsWidth(_ text: NSAttributedString) -> Bool {
        return (text.boundingRect(for: frame.size.width).size.height <= font.lineHeight) as Bool
    }
    
    private func replacedWordInText(_ text: NSAttributedString, atLineIndex lineIndex: LineIndexTuple, withTruncationToken token: NSAttributedString) -> NSAttributedString {
        let lineText = text.text(for: lineIndex.line)
        var lineTextWithTruncationToken = lineText
        
        (lineText.string as NSString).enumerateSubstrings(in: NSRange(location: 0, length: lineText.length), options: [.byWords, .reverse]) { (word, substringRange, enclosingRange, stop) -> Void in
            let lineTextWithLastWordRemoved = lineText.attributedSubstring(from: NSRange(location: 0, length: substringRange.location))
            let lineTextWithAddedTruncationToken = NSMutableAttributedString(attributedString: lineTextWithLastWordRemoved)
            lineTextWithAddedTruncationToken.append(NSAttributedString(string: "...", attributes: [.font: self.customFont]))
                lineTextWithAddedTruncationToken.append(token)
            
            let fits = self.textFitsWidth(lineTextWithAddedTruncationToken)
            
            if fits {
                lineTextWithTruncationToken = lineTextWithAddedTruncationToken
                stop.pointee = true
            }
        }
        return lineTextWithTruncationToken
        
    }
}
