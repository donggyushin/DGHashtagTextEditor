//
//  DGHashtagTextEditorPreviewTest.swift
//  DGHashtagTextEditor
//
//  Created by 신동규 on 11/15/24.
//

import SwiftUI

struct DGHashtagTextEditorPreviewTest: View {
    
    @State var text: String = "Placeholder Text"
    
    var body: some View {
        DGHashtagTextEditor(text: $text, placeholder: "Placeholder Text")
            .frame(height: 21)
            .padding()
    }
}

#Preview {
    DGHashtagTextEditorPreviewTest()
        .preferredColorScheme(.dark)
}
