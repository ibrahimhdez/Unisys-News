//
//  News.swift
//  NewsUnisys
//
//  Created by Ibrahim Hernández Jorge on 2/2/22.
//

import Foundation

struct News: Codable {
    let title: String?
    let description: String?
    let urlToImage: String?
    let publishedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case description = "description"
        case urlToImage = "urlToImage"
        case publishedAt = "publishedAt"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        title = try values.decodeIfPresent(String.self, forKey: .title)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        urlToImage = try values.decodeIfPresent(String.self, forKey: .urlToImage)
        publishedAt = try values.decodeIfPresent(String.self, forKey: .publishedAt)
    }
}
