# DGHashtagTextEditor
DGHashtagTextEditor is a highly customizable SwiftUI component designed for handling rich text with hashtags and mentions, making it perfect for social media apps and other interactive text-based interfaces. This editor provides a flexible API to create interactive text with seamless hashtag and mention detection, custom font and line-height options, and dynamic size management.


<img src="https://github.com/user-attachments/assets/2b15c584-9b4a-43ca-bb11-f393ee3e67bd" width=300 />


## Key Features
- Custom Font Support: Use any font you want to customize the look and feel of your text editor.
- Adjustable Line Height: Set line height to control the vertical spacing of your text.
- Dynamic Content Size Subscription: Easily subscribe to content size changes, enabling dynamic text editor sizing for responsive layouts.
- Hashtag and Mention Detection: Automatically detects hashtags and mentions within the text, simplifying interactive text handling.
- Tap Actions for Hashtags and Mentions: Subscribe to tap events on hashtags and mentions, allowing for interactive and actionable text elements.


DGHashtagTextEditor provides a seamless way to add rich, customizable text editing capabilities to your SwiftUI projects, with a focus on social interactions and responsiveness.


## Installation

### Swift Package Manager

The [Swift Package Manager](https://www.swift.org/documentation/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding `DGHashtagTextEditor` as a dependency is as easy as adding it to the dependencies value of your Package.swift or the Package list in Xcode.

```
dependencies: [
   .package(url: "https://github.com/donggyushin/DGHashtagTextEditor.git", .upToNextMajor(from: "1.0.2"))
]
```

Normally you'll want to depend on the DGLineHeight target:

```
.product(name: "DGHashtagTextEditor", package: "DGHashtagTextEditor")
```

```swift
    var body: some View {
        DGHashtagTextEditor(
            text: $text,
            font: .pretendard(.regular, size: 16),
            lineHeight: 23,
            mentionColor: .gray,
            hashtagColor: .systemBlue,
            isEditable: true // <-- set false when you want to receive on tap action
        )
        .onTapHashtag { hashtag in
            print("user tapped hashtag")
        }
        .onTapMention { mention in
            print("user tapped mention")
        }
        .onContentSizeChanged { size in
            var height = max(size.height, minHeight)
            height = min(size.height, maxHeight)
            self.height = height
        }
        .frame(height: height)
    }
```
