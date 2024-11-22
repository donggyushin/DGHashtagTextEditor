// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit
import SwiftUI

public struct DGHashtagTextEditor: UIViewRepresentable {
    @Binding var text: String
    
    let textColor: UIColor
    let lineHeight: CGFloat?
    let mentionColor: UIColor?
    let hashtagColor: UIColor?
    let font: UIFont
    let isSelectable: Bool
    let isEditable: Bool
    let tintColor: UIColor?
    let onlyForMention: String?
    
    var tapHashtagAction: ((String) -> Void)?
    var tapMentionAction: ((String) -> Void)?
    var contentSizeAction: ((CGSize) -> Void)?
    
    public init(
        text: Binding<String>,
        font: UIFont = .preferredFont(forTextStyle: .body),
        textColor: UIColor = .label,
        lineHeight: CGFloat? = nil,
        mentionColor: UIColor? = nil,
        hashtagColor: UIColor? = nil,
        isSelectable: Bool = true,
        isEditable: Bool = true,
        tintColor: UIColor? = nil,
        onlyForMention: String? = nil
    ) {
        _text = text
        self.textColor = textColor
        self.lineHeight = lineHeight
        self.mentionColor = mentionColor
        self.hashtagColor = hashtagColor
        self.font = font
        self.isSelectable = isSelectable
        self.isEditable = isEditable
        self.tintColor = tintColor
        self.onlyForMention = onlyForMention
    }
    
    public func makeUIView(context: Context) -> DGHashtagTextView {
        let view = DGHashtagTextView()
        view.hashtagTextViewDelegate = context.coordinator
        view.delegate = context.coordinator
        view.backgroundColor = .clear
        DispatchQueue.main.async {
            contentSizeAction?(view.contentsSize())
        }
        return view
    }
    
    public func updateUIView(_ uiView: DGHashtagTextView, context: Context) {
        uiView.text = text
        uiView.font = font
        uiView.isSelectable = isSelectable
        uiView.isEditable = isEditable
        uiView.tintColor = tintColor
        
        uiView.lineHeight = lineHeight
        uiView.mentionColor = mentionColor
        uiView.hashtagColor = hashtagColor
        uiView.foregroundColor = textColor
        uiView.adjustAttributes()
        uiView.onlyForMention = onlyForMention
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    public class Coordinator: NSObject, DGHashtagTextViewDelegate, UITextViewDelegate {
        let parent: DGHashtagTextEditor
        
        init(parent: DGHashtagTextEditor) {
            self.parent = parent
        }
        
        public func tapHashtag(_ hashtagTextView: DGHashtagTextView, didSelect hashtag: String) {
            parent.tapHashtagAction?(hashtag)
        }
        
        public func tapMention(_ mentionTextView: DGHashtagTextView, didSelect mention: String) {
            parent.tapMentionAction?(mention)
        }
        
        public func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            if let dghashtagTextView = textView as? DGHashtagTextView {
                parent.contentSizeAction?(dghashtagTextView.contentsSize())
            }
        }
    }
}

public extension DGHashtagTextEditor {
    func onTapHashtag(perform action: @escaping (String) -> Void) -> Self {
        var copy = self
        copy.tapHashtagAction = action
        return copy
    }
    
    func onTapMention(perform action: @escaping (String) -> Void) -> Self {
        var copy = self
        copy.tapMentionAction = action
        return copy
    }
    
    func onContentSizeChanged(perform action: @escaping (CGSize) -> Void) -> Self {
        var copy = self
        copy.contentSizeAction = action
        return copy
    }
}

public protocol DGHashtagTextViewDelegate: AnyObject {
    func tapHashtag(_ hashtagTextView: DGHashtagTextView, didSelect hashtag: String) async
    func tapMention(_ mentionTextView: DGHashtagTextView, didSelect mention: String) async
}

public class DGHashtagTextView: UITextView {
    public weak var hashtagTextViewDelegate: DGHashtagTextViewDelegate?
    public var hashtagArr: [String]?
    public var mentionArr: [String]?
    public var lineHeight: CGFloat?
    public var mentionColor: UIColor?
    public var hashtagColor: UIColor?
    public var foregroundColor: UIColor?
    public var onlyForMention: String?
    
    let customHashtagAttribute = NSAttributedString.Key("CustomHashtagAttribute")
    let customMentionAttribute = NSAttributedString.Key("CustomMentionAttribute")
    
    public init() {
        super.init(frame: .zero, textContainer: nil)
        textContainerInset = .zero
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func contentsSize() -> CGSize {
        let fixedWidth = frame.size.width
        return sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
    }
    
    public func adjustAttributes() {
        let nsText: NSString = self.text as NSString
        let attrString = NSMutableAttributedString(string: nsText as String)
        
        // 폰트, 텍스트 색상, 줄 간격이 존재하면 설정
        if let font = font {
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
        
        let hashtagDetector = try? NSRegularExpression(pattern: "#(\\w+)", options: NSRegularExpression.Options.caseInsensitive)
        let results = hashtagDetector?.matches(in: self.text,
                                               options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds,
                                               range: NSMakeRange(0, self.text.utf16.count))
        
        if let onlyForMention, let mentionColor {
            
            if self.text.hasPrefix(onlyForMention) {
                let range = NSMakeRange(0, onlyForMention.count)
                attrString.addAttribute(.foregroundColor, value: mentionColor, range: range)
                attrString.addAttribute(customMentionAttribute, value: onlyForMention, range: range)
            }
          
            self.attributedText = attrString
            return
        }

        hashtagArr = results?.compactMap{ [weak self] in (self?.text as? NSString)?.substring(with: $0.range(at: 1)) }
        
        if let hashtagColor {
            if let hashtagArr {
                // NSRegularExpression을 사용하여 모든 해시태그의 위치를 찾음
                let regex = try? NSRegularExpression(pattern: "#(\\w+)", options: [])
                
                let matches = regex?.matches(in: self.text, options: [], range: NSRange(location: 0, length: nsText.length))
                
                // 모든 해시태그 위치에 대해 속성을 추가
                matches?.forEach { match in
                    let wordRange = match.range(at: 0)
                    let word = nsText.substring(with: wordRange)
                    
                    // 해시태그 배열의 index에 맞는 색상 적용
                    if let index = hashtagArr.firstIndex(of: word.replacingOccurrences(of: "#", with: "")) {
                        attrString.addAttribute(customHashtagAttribute, value: index, range: wordRange)
                        attrString.addAttribute(.foregroundColor, value: hashtagColor, range: wordRange)
                    }
                }
            }
        }
        
        let mentionDetector = try? NSRegularExpression(pattern: "@(\\w+)", options: NSRegularExpression.Options.caseInsensitive)
        let mentionResults = mentionDetector?.matches(in: self.text,
                                                      options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds,
                                                      range: NSMakeRange(0, self.text.utf16.count))
        
        mentionArr = mentionResults?.compactMap { [weak self] in (self?.text as? NSString)?.substring(with: $0.range(at: 1)) }
        
        if let mentionColor {
            if let mentionArr {
                // NSRegularExpression을 사용하여 모든 멘션의 위치를 찾음
                let regex = try? NSRegularExpression(pattern: "@(\\w+)", options: [])
                
                let matches = regex?.matches(in: self.text, options: [], range: NSRange(location: 0, length: nsText.length))
                
                // 모든 멘션 위치에 대해 속성을 추가
                matches?.forEach { match in
                    let wordRange = match.range(at: 0)
                    let word = nsText.substring(with: wordRange)
                    
                    // mentionArr 배열의 index에 맞는 색상 적용
                    if let index = mentionArr.firstIndex(of: word.replacingOccurrences(of: "@", with: "")) {
                        attrString.addAttribute(customMentionAttribute, value: index, range: wordRange)
                        attrString.addAttribute(.foregroundColor, value: mentionColor, range: wordRange)
                    }
                }
            }
        }
        
        self.attributedText = attrString
    }
    
    private var touchesEndedTask: Task<Void, Never>?
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touchesEndedTask == nil else { return }
        touchesEndedTask = Task {
            guard let touch = touches.first else { return }
            let location = touch.location(in: self)
            
            // 터치된 위치의 텍스트 인덱스를 얻음
            if let textPosition = closestPosition(to: location),
               let range = tokenizer.rangeEnclosingPosition(textPosition, with: .word, inDirection: UITextDirection.storage(.forward)) {
                let startIndex = offset(from: beginningOfDocument, to: range.start)
                let nsRange = NSRange(location: startIndex, length: offset(from: range.start, to: range.end))
                
                if let index = attributedText.attribute(customHashtagAttribute, at: nsRange.location, effectiveRange: nil) as? Int {
                    if let hashtagArr {
                        await hashtagTextViewDelegate?.tapHashtag(self, didSelect: hashtagArr[index])
                    }
                } else if let index = attributedText.attribute(customMentionAttribute, at: nsRange.location, effectiveRange: nil) as? Int {
                    if let mentionArr {
                        await hashtagTextViewDelegate?.tapMention(self, didSelect: mentionArr[index])
                    }
                }
            }
            super.touchesEnded(touches, with: event)
            touchesEndedTask = nil
        }
    }
}
