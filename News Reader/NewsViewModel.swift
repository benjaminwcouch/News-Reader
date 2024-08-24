//
//  NewsViewModel.swift
//  News Reader
//
//  Created by Benjamin Couch on 24/8/2024.
//
import SwiftUI
import Combine

class NewsViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var isLoading: Bool = false
    @Published var hasMore: Bool = true // Track if more articles are available

    private var currentPage: Int = 1
    private var cancellable: AnyCancellable?

    private let apiKey = "pub_516104555e74d07f24177b3c846577826c459"
    private let cacheFileName = "cachedArticles.json"
    private let cacheDirectory: URL

    init() {
        // Set cache directory
        cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        // Load cached articles if available
        loadCachedArticles()
        // Load new articles
        loadArticles()
    }

    func loadArticles() {
        guard !isLoading && hasMore else { return }
        isLoading = true

        let urlString = "https://newsdata.io/api/1/latest?apikey=\(apiKey)&language=en"
        
        cancellable = URLSession.shared.dataTaskPublisher(for: URL(string: urlString)!)
            .map { $0.data }
            .decode(type: NewsResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                switch completion {
                case .failure(let error):
                    print("Error loading articles: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { response in
                if response.results.isEmpty {
                    self.hasMore = false
                } else {
                    self.articles.append(contentsOf: response.results)
                    self.currentPage += 1
                    self.saveArticlesToCache()
                }
            })
    }

    func loadMoreArticlesIfNeeded(currentArticle article: Article?) {
        guard let article = article else {
            loadArticles()
            return
        }
        
        let thresholdIndex = articles.index(articles.endIndex, offsetBy: -5)
        if articles.firstIndex(where: { $0.id == article.id }) == thresholdIndex {
            loadArticles()
        }
    }

    private func loadCachedArticles() {
        let fileURL = cacheDirectory.appendingPathComponent(cacheFileName)
        guard let data = try? Data(contentsOf: fileURL) else { return }

        let decoder = JSONDecoder()
        if let cachedArticles = try? decoder.decode([Article].self, from: data) {
            self.articles = cachedArticles
        }
    }

    private func saveArticlesToCache() {
        let fileURL = cacheDirectory.appendingPathComponent(cacheFileName)
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(articles) {
            try? data.write(to: fileURL)
        }
    }
}
