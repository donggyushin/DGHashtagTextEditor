// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit
import SwiftUI

public struct DGHashtagTextView: UIViewRepresentable {
    
    var textChangeAction: ((String) -> Void)?
    var text: String?
    
    public func makeUIView(context: Context) -> HashtagTextView {
        let view = HashtagTextView()
        view.delegate = context.coordinator
        return view
    }
    
    public func updateUIView(_ uiView: HashtagTextView, context: Context) {
        uiView.text = text
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
    
    func setText(text: String) -> Self {
        var copy = self
        copy.text = text
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
                hashtagTextView.resolveHashTags()
            }
        }
    }
}


// 한글, 영문, 숫자만 가능
public class HashtagTextView: UITextView {
    var hashtagArr: [String]?
    
    func resolveHashTags() {
//        self.isEditable = false
        self.isSelectable = true
        
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
                                                                
                    attrString.addAttribute(NSAttributedString.Key.link, value: "\(i)", range: matchRange)
                    i += 1
                }
            }
        }

        self.attributedText = attrString
    }
}
