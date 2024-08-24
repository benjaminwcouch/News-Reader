//
//  NewsDetailView.swift
//  News Reader
//
//  Created by Benjamin Couch on 24/8/2024.
//

//
//  NewsDetailView.swift
//  News Reader
//
//  Created by Benjamin Couch on 24/8/2024.
//
import SwiftUI

struct NewsDetailView: View {
    let article: Article
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let imageUrl = article.image_url, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .clipped()
                    } placeholder: {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(article.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(article.source_name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(article.pubDate)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let description = article.description {
                        Text(description)
                            .font(.body)
                            .padding(.top)
                    }
                    
                    if let content = article.content {
                        Text(content)
                            .font(.body)
                            .padding(.top)
                    }
                    
                    if let link = article.link, let url = URL(string: link) {
                        Link("Read full article", destination: url)
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding(.top)
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
