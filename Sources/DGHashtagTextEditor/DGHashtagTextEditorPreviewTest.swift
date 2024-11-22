//
//  DGHashtagTextEditorPreviewTest.swift
//  DGHashtagTextEditor
//
//  Created by 신동규 on 11/15/24.
//

import SwiftUI

struct DGHashtagTextEditorPreviewTest: View {
    
    @State var text: String = "@Mention"
    
    var body: some View {
        DGHashtagTextEditor(
            text: $text,
            font: .systemFont(ofSize: 20),
            lineHeight: 30,
            mentionColor: .gray,
            hashtagColor: .blue
        )
            .padding()
    }
}

#Preview {
    DGHashtagTextEditorPreviewTest()
        .preferredColorScheme(.dark)
}
