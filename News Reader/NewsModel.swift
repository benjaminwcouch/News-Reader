//
//  NewsModel.swift
//  News Reader
//
//  Created by Benjamin Couch on 24/8/2024.
//
// Add these to NewsModel.swift


import Foundation

// Base Article Model
struct Article: Identifiable, Codable {
    let id = UUID()
    let article_id: String
    let title: String
    let link: String?
    let keywords: [String]?
    let creator: [String]?
    let video_url: String?
    let description: String?
    let content: String?
    let pubDate: String
    let image_url: String?
    let source_id: String
    let source_name: String
    let source_url: String
    let source_icon: String?
    let language: String
    let country: [String]
    let category: [String]
    
    enum CodingKeys: String, CodingKey {
        case article_id
        case title
        case link
        case keywords
        case creator
        case video_url
        case description
        case content
        case pubDate
        case image_url
        case source_id
        case source_name
        case source_url
        case source_icon
        case language
        case country
        case category
    }
}

// NewsAPI Response Models
struct NewsAPIResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [NewsAPIArticle]
}

struct NewsAPIArticle: Codable {
    let source: NewsAPISource
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
}

struct NewsAPISource: Codable {
    let id: String?
    let name: String
}

// Guardian Response Models
struct GuardianResponse: Codable {
    let response: GuardianResponseContent
}

struct GuardianResponseContent: Codable {
    let status: String
    let total: Int
    let results: [GuardianArticle]
}

struct GuardianArticle: Codable {
    let id: String
    let type: String
    let sectionId: String
    let sectionName: String
    let webPublicationDate: String
    let webTitle: String
    let webUrl: String
    let fields: GuardianFields?
}

struct GuardianFields: Codable {
    let thumbnail: String?
    let bodyText: String?
}

// NewsData.io Response Models
struct NewsResponse: Codable {
    let status: String
    let totalResults: Int?
    let nextPage: String?
    let results: ResponseResults
}

enum ResponseResults: Codable {
    case success([NewsDataArticle])
    case error(ErrorResponse)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let articles = try? container.decode([NewsDataArticle].self) {
            self = .success(articles)
        } else if let error = try? container.decode(ErrorResponse.self) {
            self = .error(error)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unable to decode results")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .success(let articles):
            try container.encode(articles)
        case .error(let error):
            try container.encode(error)
        }
    }
}

struct NewsDataArticle: Codable {
    let title: String
    let link: String?
    let keywords: [String]?
    let creator: [String]?
    let video_url: String?
    let description: String?
    let content: String?
    let pubDate: String
    let image_url: String?
    let source_id: String
    let source_name: String?
    let country: [String]
    let category: [String]
    let language: String
}

struct ErrorResponse: Codable {
    let message: String
    let code: String
}

// Article Conversion Extensions
extension Article {
    static func from(newsDataArticle: NewsDataArticle) -> Article {
        return Article(
            article_id: UUID().uuidString,
            title: newsDataArticle.title,
            link: newsDataArticle.link,
            keywords: newsDataArticle.keywords,
            creator: newsDataArticle.creator,
            video_url: newsDataArticle.video_url,
            description: newsDataArticle.description,
            content: newsDataArticle.content,
            pubDate: newsDataArticle.pubDate,
            image_url: newsDataArticle.image_url,
            source_id: newsDataArticle.source_id,
            source_name: newsDataArticle.source_name ?? "",
            source_url: "",
            source_icon: nil,
            language: newsDataArticle.language,
            country: newsDataArticle.country,
            category: newsDataArticle.category
        )
    }
    
    static func from(newsAPIArticle: NewsAPIArticle) -> Article {
        return Article(
            article_id: UUID().uuidString,
            title: newsAPIArticle.title,
            link: newsAPIArticle.url,
            keywords: nil,
            creator: nil,
            video_url: nil,
            description: newsAPIArticle.description,
            content: nil,
            pubDate: newsAPIArticle.publishedAt,
            image_url: newsAPIArticle.urlToImage,
            source_id: newsAPIArticle.source.id ?? "",
            source_name: newsAPIArticle.source.name,
            source_url: "",
            source_icon: nil,
            language: "en",
            country: ["US"],
            category: []
        )
    }
    
    static func from(guardianArticle: GuardianArticle) -> Article {
        return Article(
            article_id: guardianArticle.id,
            title: guardianArticle.webTitle,
            link: guardianArticle.webUrl,
            keywords: nil,
            creator: nil,
            video_url: nil,
            description: guardianArticle.fields?.bodyText,
            content: nil,
            pubDate: guardianArticle.webPublicationDate,
            image_url: guardianArticle.fields?.thumbnail,
            source_id: guardianArticle.sectionId,
            source_name: "The Guardian",
            source_url: "https://www.theguardian.com",
            source_icon: nil,
            language: "en",
            country: ["UK"],
            category: [guardianArticle.sectionName]
        )
    }
}
