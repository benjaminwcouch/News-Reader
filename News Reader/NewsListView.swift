import Foundation
import SwiftUI

struct NewsListView: View {
    @StateObject private var viewModel = NewsViewModel()

    var body: some View {
        List {
            ForEach(viewModel.articles) { article in
                NewsRowView(article: article)
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.gray)
                    .onAppear {
                        viewModel.loadMoreArticlesIfNeeded(currentArticle: article)
                    }
            }
            if viewModel.isLoading {
                ProgressView()
                    .padding()
            }
        }
      //  .background(Color.blue)
        .onAppear {
            if viewModel.articles.isEmpty {
                viewModel.loadArticles()
            }
        }
    }
}

