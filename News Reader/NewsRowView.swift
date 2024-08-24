//
//  NewsRowView.swift
//  News Reader
//
//  Created by Benjamin Couch on 24/8/2024.
import SwiftUI

struct NewsRowView: View {
    let article: Article
    
    var body: some View {
      
        VStack(alignment: .leading)  {
            if let imageUrl = article.image_url, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: 300 , maxHeight: 200)
                        .clipped()
                } placeholder: {
                   
                    ProgressView()
                        .frame(maxWidth: 300 , maxHeight: 200)
                }
            }
            
            Text(article.title)
                .font(.headline)
                .frame(maxWidth: 300,  maxHeight: 300)
                .lineLimit(2)
                .padding(.top, 5)
            
            Text(article.description ?? "No description available")
                .font(.subheadline)
                .frame(maxWidth: 300, alignment: .leading)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack {
                Text(article.source_name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                Text(article.pubDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 5)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 3)
        .onTapGesture {
            if let link = article.link, let url = URL(string: link) {
                UIApplication.shared.open(url)
            }
        }
    }
}
