//
//  File.swift
//  DGHashtagTextEditor
//
//  Created by 신동규 on 12/5/24.
//

import SwiftUI

struct DGHashtagTextViewPreview: View {
    
    @State private var changeText: String?
    
    var body: some View {
        DGHashtagTextView()
            .setTagColor(.green)
            .setMentionColor(.green)
            .setForegroundColor(.white)
            .onTextChange { print($0) }
            .setLineHeight(20)
            .setText(changeText)
    }
}

#Preview {
    DGHashtagTextViewPreview()
        .preferredColorScheme(.dark)
}
