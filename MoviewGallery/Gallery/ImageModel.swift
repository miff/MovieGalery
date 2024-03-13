//
//  ImageModel.swift
//  MoviewGallery
//
//  Created by Milan Djordjevic on 13/03/2024.
//

import Foundation

struct ImageModel: Identifiable, Codable, Hashable {
    var id: String
    var downloadURL: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case downloadURL = "download_url"
    }
}
