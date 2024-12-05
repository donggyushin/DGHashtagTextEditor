// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit
import SwiftUI

public struct DGHashtagTextView: UIViewRepresentable {
    
    var textChangeAction: ((String) -> Void)?
    var text: String?
    var font: UIFont?
    var foregroundColor: UIColor?
    var lineHeight: CGFloat?
    
    var tagColor: UIColor?
    var mentionColor: UIColor?
    
    public func makeUIView(context: Context) -> HashtagTextView {
        let view = HashtagTextView()
        view.delegate = context.coordinator
        return view
    }
    
    public func updateUIView(_ uiView: HashtagTextView, context: Context) {
        if let text {
            uiView.text = text
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

public extension DGHashtagTextView {
    func onTextChange(_ action: @escaping (String) -> Void) -> Self {
        var copy = self
        copy.textChangeAction = action
        return copy
    }
    
    func setText(_ text: String?) -> Self {
        var copy = self
        copy.text = text
        return copy
    }
    
    func setFont(_ font: UIFont) -> Self {
        var copy = self
        copy.font = font
        return copy
    }
    
    func setForegroundColor(_ foregroundColor: UIColor) -> Self {
        var copy = self
        copy.foregroundColor = foregroundColor
        return copy
    }
    
    func setLineHeight(_ lineHeight: CGFloat) -> Self {
        var copy = self
        copy.lineHeight = lineHeight
        return copy
    }
    
    func setMentionColor(_ color: UIColor?) -> Self {
        var copy = self
        copy.mentionColor = color
        return copy
    }
    
    func setTagColor(_ color: UIColor?) -> Self {
        var copy = self
        copy.tagColor = color
        return copy
    }
}

extension DGHashtagTextView {
    public class Coordinator: NSObject, UITextViewDelegate {
        let parent: DGHashtagTextView
        
        init(parent: DGHashtagTextView) {
            self.parent = parent
        }
        
        public func textViewDidChange(_ textView: UITextView) {
            parent.textChangeAction?(textView.text)
            
            if let hashtagTextView = textView as? HashtagTextView {
                hashtagTextView.resolveBasicStyle(font: parent.font, foregroundColor: parent.foregroundColor, lineHeight: parent.lineHeight)
                hashtagTextView.resolveHashTags(color: parent.tagColor)
                hashtagTextView.resolveMentions(color: parent.mentionColor)
            }
        }
    }
}


// 한글, 영문, 숫자만 가능
public class HashtagTextView: UITextView {
    var hashtagArr: [String]?
    var mentionArr: [String]?
    
    func resolveBasicStyle(font: UIFont?, foregroundColor: UIColor?, lineHeight: CGFloat?) {
        let nsText: NSString = self.text as NSString
        let attrString = NSMutableAttributedString(string: nsText as String)
        
        if let font {
            attrString.addAttribute(.font, value: font, range: NSMakeRange(0, nsText.length))
        }
        
        if let foregroundColor {
            attrString.addAttribute(.foregroundColor, value: foregroundColor, range: NSMakeRange(0, nsText.length))
        }
        
        if let lineHeight = lineHeight {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = lineHeight
            paragraphStyle.maximumLineHeight = lineHeight
            attrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, nsText.length))
        }
        
        self.attributedText = attrString
    }
    
    // https://withthemilkyway.tistory.com/34
    func resolveHashTags(color: UIColor?) {
        let nsText: NSString = self.text as NSString
        let attrString = NSMutableAttributedString(string: nsText as String)
        let hashtagDetector = try? NSRegularExpression(pattern: "#(\\w+)", options: NSRegularExpression.Options.caseInsensitive)
        let results = hashtagDetector?.matches(in: self.text,
                                               options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds,
                                               range: NSMakeRange(0, self.text.utf16.count))

        hashtagArr = results?.map{ (self.text as NSString).substring(with: $0.range(at: 1)) }
                                
        if hashtagArr?.count != 0 {
            var i = 0
            for var word in hashtagArr! {
                word = "#" + word
                if word.hasPrefix("#") {
                    let matchRange:NSRange = nsText.range(of: word as String, options: .caseInsensitive)
                    
                    if let color {
                        attrString.addAttribute(.foregroundColor, value: color, range: matchRange)
                    }
                    i += 1
                }
            }
        }

        self.attributedText = attrString
    }
    
    func resolveMentions(color: UIColor?) {
        let nsText: NSString = self.text as NSString
        let attrString = NSMutableAttributedString(string: nsText as String)
        let hashtagDetector = try? NSRegularExpression(pattern: "@(\\w+)", options: NSRegularExpression.Options.caseInsensitive)
        let results = hashtagDetector?.matches(in: self.text,
                                               options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds,
                                               range: NSMakeRange(0, self.text.utf16.count))

        mentionArr = results?.map{ (self.text as NSString).substring(with: $0.range(at: 1)) }
                                
        if mentionArr?.count != 0 {
            var i = 0
            for var word in mentionArr! {
                word = "@" + word
                if word.hasPrefix("@") {
                    let matchRange:NSRange = nsText.range(of: word as String, options: .caseInsensitive)
                    
                    if let color {
                        attrString.addAttribute(.foregroundColor, value: color, range: matchRange)
                    }
                    i += 1
                }
            }
        }

        self.attributedText = attrString
    }
}
