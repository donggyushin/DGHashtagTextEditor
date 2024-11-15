//
//  DGHashtagTextEditorPreviewTest.swift
//  DGHashtagTextEditor
//
//  Created by 신동규 on 11/15/24.
//

import SwiftUI

struct DGHashtagTextEditorPreviewTest: View {
    
    @State var text: String = ""
    
    var body: some View {
        DGHashtagTextEditor(text: $text, placeholder: "PlaceHolder")
            .frame(height: 21)
            .padding()
    }
}

#Preview {
    DGHashtagTextEditorPreviewTest()
        .preferredColorScheme(.dark)
}
