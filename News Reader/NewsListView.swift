//
//  NewsListView.swift
//  News Reader
//
//  Created by Benjamin Couch on 24/8/2024.
//
import SwiftUI

struct NewsListView: View {
    @StateObject private var viewModel = NewsViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                // Source Picker
                Picker("News Source", selection: $viewModel.selectedSource) {
                    ForEach(NewsViewModel.NewsSource.allCases) { source in
                        Text(source.rawValue).tag(source)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)  // Only pad the sides
                .padding(.vertical, 8) // Add some vertical padding
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 0.9, green: 0.95, blue: 1.0))
                        .padding(.horizontal)  // Match the picker's padding
                )
                .onChange(of: viewModel.selectedSource) { _ in
                    viewModel.changeSource(viewModel.selectedSource)
                }
                
                List {
                    ForEach(viewModel.articles) { article in
                        NavigationLink {
                            NewsDetailView(article: article)
                        } label: {
                            NewsRowView(article: article)
                                .frame(maxWidth: .infinity)
                                .listRowInsets(EdgeInsets())
                                .onAppear {
                                    viewModel.loadMoreArticlesIfNeeded(currentArticle: article)
                                }
                        }
                    }
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
                .listStyle(PlainListStyle())
                .refreshable {
                    await viewModel.refreshArticles()
                }
            }
            .navigationTitle("News")
        }
        .onAppear {
            if viewModel.articles.isEmpty {
                viewModel.loadArticles()
            }
        }
    }
}

struct NewsListView_Previews: PreviewProvider {
    static var previews: some View {
        NewsListView()
    }
}
