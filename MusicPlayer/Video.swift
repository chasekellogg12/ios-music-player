//
//  Video.swift
//  MusicPlayer
//
//  Created by Chase Kellogg on 4/3/24.
//

import Foundation

struct Video : Decodable {
    var videoId = ""
    var title = ""
    var thumbnail = ""
    var published = Date()
    var uploader = ""
    
    enum CodingKeys: String, CodingKey {
        
        case snippet
        case thumbnails
        case high
        case id
        
        case published = "publishedAt"
        case thumbnail = "url"
        case videoId
        case uploader = "channelTitle"
        case title
    }
    
    init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let snippetContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .snippet)
        
        self.title = try snippetContainer.decode(String.self, forKey: .title)
        
        self.published = try snippetContainer.decode(Date.self, forKey: .published)
        
        self.uploader = try snippetContainer.decode(String.self, forKey: .uploader)
        
        let thumbnailContainer = try snippetContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .thumbnails)
        
        let highContainer = try thumbnailContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .high)
        
        self.thumbnail = try highContainer.decode(String.self, forKey: .thumbnail)
        
        let idContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .id)
        
        self.videoId = try idContainer.decode(String.self, forKey: .videoId)
    }
}
