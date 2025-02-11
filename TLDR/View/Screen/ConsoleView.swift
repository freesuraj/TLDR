//
//  ConsoleView.swift
//  TLDR
//
//  Created by Suraj Pathak on 11/2/2025.
//  Copyright © 2025 Suraj Pathak. All rights reserved.
//

import SwiftUI

struct ConsoleView: View {
    
    @State private var searchText = ""
    @State private var viewModel = ConsoleViewModel()
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading) {
            infoButton
            MarkdownView(markdownContent: $viewModel.text)
            suggestions
            searchBar
        }
        .task {
            NetworkManager.checkAutoUpdate(printVerbose: false)
            Verbose.out(Constant.startUpInstruction)
        }
        .padding(.horizontal)
        .background(Color.appBackgroundColor)
    }
    
    private var infoButton: some View {
        Button {
            Verbose.out(Constant.aboutUsMarkdown)
        } label: {
            HStack {
                Spacer()
                Image(systemName: "info.circle")
                    .foregroundStyle(.white)
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            CustomSearchBar(searchText: $searchText)
            Spacer()
            clearButton
        }
    }
    
    private var clearButton: some View {
        Button {
            viewModel.clearConsole()
        } label: {
            Image(systemName: "trash.fill")
                .foregroundStyle(.white)
        }
    }
    
    @ViewBuilder
    private var suggestions: some View {
        if !searchText.isEmpty {
            ForEach(searchResults, id: \.id) { command in
                Button {
                    searchText = ""
                    Verbose.out(command.rawOutput)
                } label: {
                    HStack(spacing: 2) {
                        Text("\(command.name)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.callout)
                            .foregroundStyle(Color.white)
                        Spacer()
                        Text("\(command.type)")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .font(.callout)
                            .foregroundStyle(Color.gray)
                    }
                    .padding(4)
                }
            }
        }
    }
    
    private var searchResults: [any Command] {
        StoreManager.getMatchingCommands(searchText)
    }
}
