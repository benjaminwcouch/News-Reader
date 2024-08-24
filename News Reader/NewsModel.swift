//
//  NewsModel.swift
//  News Reader
//
//  Created by Benjamin Couch on 24/8/2024.
//
import Foundation

struct NewsResponse: Codable {
    let status: String
    let totalResults: Int?
    let results: [Article] // results is directly an array of Article
}

struct Article: Identifiable, Codable {
    let id = UUID() // To uniquely identify each article in the UI
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
