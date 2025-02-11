//
//  MarkdownView.swift
//  TLDR
//
//  Created by Suraj Pathak on 11/2/2025.
//  Copyright © 2025 Suraj Pathak. All rights reserved.
//

import SwiftUI

struct MarkdownView: View {
    @Binding var markdownContent: NSMutableAttributedString

    var body: some View {
        ScrollView {
            ScrollViewReader { proxy in
                Text(AttributedString(markdownContent))
                .padding()
                .textSelection(.enabled)
                .foregroundColor(.white)
                .environment(\.openURL, OpenURLAction { url in
                    return .systemAction
                })
                    .onAppear {
                        withAnimation {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                    .onChange(of: markdownContent) {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                Color.clear
                    .frame(height: 1)
                    .id("bottom")
            }
        }
    }
}

