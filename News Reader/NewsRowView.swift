//
//  NewsRowView.swift
//  News Reader
//
//  Created by Benjamin Couch on 24/8/2024.
//

import SwiftUI

struct NewsRowView: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading) {
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
            
            VStack(alignment: .leading, spacing: 8) {
                Text(article.title)
                    .font(.headline)
                    .lineLimit(2)
                
                if let description = article.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                
                HStack {
                    Text(article.source_name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(article.pubDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 3)
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
}
