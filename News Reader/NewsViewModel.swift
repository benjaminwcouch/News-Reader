//
//  NewsViewModel.swift
//  News Reader
//
//  Created by Benjamin Couch on 24/8/2024.
//
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
    @Published var hasMore: Bool = true
    @Published var selectedSource: NewsSource = .newsData
    
    private var currentPage: Int = 1
    private var nextPageToken: String? = nil
    private var cancellable: AnyCancellable?
    private let cacheFileName = "cachedArticles.json"
    private let cacheDirectory: URL

    // API Keys
    private let newsDataKey = "pub_516104555e74d07f24177b3c846577826c459"
    private let newsAPIKey = "ec82aa7cfcf44cfd8004409baaa6ac4f"
    private let guardianKey = "eaf2758d-b4bc-4502-904d-28ca7135c288"

    enum NewsSource: String, CaseIterable, Identifiable {
        case newsData = "NewsData.io"
        case newsAPI = "NewsAPI"
        case guardian = "The Guardian"
        
        var id: String { self.rawValue }
    }
    
    init() {
        cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        loadCachedArticles()
        loadArticles()
    }

    func loadArticles() {
        guard !isLoading && hasMore else { return }
        isLoading = true
        
        let urlString = buildURLString()
        guard let url = URL(string: urlString) else { return }
        
        switch selectedSource {
        case .newsData:
            fetchNewsDataArticles(from: url)
        case .newsAPI:
            fetchNewsAPIArticles(from: url)
        case .guardian:
            fetchGuardianArticles(from: url)
        }
    }
    
    private func fetchNewsDataArticles(from url: URL) {
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { data, _ -> Data in
                // Print raw JSON for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON response: \(jsonString)")
                }
                return data
            }
            .decode(type: NewsResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.handleError(error)
                }
            }, receiveValue: { [weak self] response in
                self?.handleNewsDataResponse(response)
            })
    }
    
    private func fetchNewsAPIArticles(from url: URL) {
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: NewsAPIResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.handleError(error)
                }
            }, receiveValue: { [weak self] response in
                self?.handleNewsAPIResponse(response)
            })
    }
    
    private func fetchGuardianArticles(from url: URL) {
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: GuardianResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.handleError(error)
                }
            }, receiveValue: { [weak self] response in
                self?.handleGuardianResponse(response)
            })
    }
    
    private func handleNewsDataResponse(_ response: NewsResponse) {
        switch response.results {
        case .success(let newsDataArticles):
            if newsDataArticles.isEmpty {
                hasMore = false
            } else {
                let convertedArticles = newsDataArticles.map { Article.from(newsDataArticle: $0) }
                articles.append(contentsOf: convertedArticles)
                nextPageToken = response.nextPage
                hasMore = response.nextPage != nil
                saveArticlesToCache()
            }
        case .error(let error):
            print("NewsData.io API Error: \(error.message)")
            hasMore = false
        }
        isLoading = false
    }
    
    private func handleNewsAPIResponse(_ response: NewsAPIResponse) {
        if response.articles.isEmpty {
            hasMore = false
        } else {
            let convertedArticles = response.articles.map { Article.from(newsAPIArticle: $0) }
            articles.append(contentsOf: convertedArticles)
            currentPage += 1
            saveArticlesToCache()
        }
        isLoading = false
    }
    
    private func handleGuardianResponse(_ response: GuardianResponse) {
        if response.response.results.isEmpty {
            hasMore = false
        } else {
            let convertedArticles = response.response.results.map { Article.from(guardianArticle: $0) }
            articles.append(contentsOf: convertedArticles)
            currentPage += 1
            saveArticlesToCache()
        }
        isLoading = false
    }
    
    private func buildURLString() -> String {
        switch selectedSource {
        case .newsData:
            if let nextPage = nextPageToken {
                return "https://newsdata.io/api/1/news?apikey=\(newsDataKey)&language=en&page=\(nextPage)"
            } else {
                return "https://newsdata.io/api/1/news?apikey=\(newsDataKey)&language=en"
            }
        case .newsAPI:
            return "https://newsapi.org/v2/top-headlines?country=us&apiKey=\(newsAPIKey)&page=\(currentPage)"
        case .guardian:
            return "https://content.guardianapis.com/search?api-key=\(guardianKey)&page=\(currentPage)&show-fields=thumbnail,bodyText"
        }
    }
    
    func changeSource(_ source: NewsSource) {
        selectedSource = source
        articles = []
        currentPage = 1
        nextPageToken = nil
        hasMore = true
        loadArticles()
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

    @MainActor
    func refreshArticles() async {
        articles = []
        currentPage = 1
        nextPageToken = nil
        hasMore = true
        loadArticles()
    }

    private func handleError(_ error: Error) {
        print("Error loading articles: \(error)")
    }
}
