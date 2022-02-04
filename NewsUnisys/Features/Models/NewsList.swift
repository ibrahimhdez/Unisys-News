//
//  NewsList.swift
//  NewsUnisys
//
//  Created by Ibrahim Hernández Jorge on 2/2/22.
//

import Foundation

struct NewsList: Codable {
    let status: String?
    let articles: [News]?
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case articles = "articles"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        status = try values.decodeIfPresent(String.self, forKey: .status)
        articles = try values.decodeIfPresent([News].self, forKey: .articles)
    }
}
