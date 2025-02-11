//
//  CustomSearchBar.swift
//  TLDR
//
//  Created by Suraj Pathak on 11/2/2025.
//  Copyright © 2025 Suraj Pathak. All rights reserved.
//

import SwiftUI

struct CustomSearchBar: View {
    @Binding var searchText: String
    var placeholder: String = "Search command..."
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "greaterthanorequalto")
                .foregroundColor(.white)
                .padding(.leading)
            
            TextField(placeholder, text: $searchText)
                .focused($isFocused)
                .foregroundStyle(.placeholder, .white)
                .foregroundColor(.white)
                .padding(.vertical)
                .autocorrectionDisabled()
                .onAppear {
                    isFocused = true
                }
        }
        .background(.clear)
    }
}
