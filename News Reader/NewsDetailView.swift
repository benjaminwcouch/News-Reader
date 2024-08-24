//
//  NewsDetailView.swift
//  News Reader
//
//  Created by Benjamin Couch on 24/8/2024.
//

import SwiftUI

struct NewsDetailView: View {
    var article: Article

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let imageUrl = article.image_url, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: 200)
                                                    .clipped()
                    } placeholder: {
                    
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: 200)
                    }
                }

                Text(article.title)
                    .font(.largeTitle)
                    .bold()
                    .frame(maxWidth: .infinity, maxHeight: 200)

                if let description = article.description {
                    Text(description)
                        .font(.body)
                        .frame(maxWidth: .infinity, maxHeight: 200)
                }

                if let content = article.content {
                    Text(content)
                        .font(.body)
                        .frame(maxWidth: .infinity, maxHeight: 200)
                }

                Text("Published on \(article.pubDate)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: 200)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Article Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
