//
//  GalleryViewModel.swift
//  MoviewGallery
//
//  Created by Milan Djordjevic on 13/03/2024.
//

import Foundation

@MainActor
final class GalleryViewModel: ObservableObject {
    @Published var images: [ImageModel]?
    @Published var page = 0
    @Published var startFetch = false
    @Published var endFetch = false
    
    func update() {
        page += 1
        Task {
            do {
                try await fetch()
            } catch {
                #if DEBUG
                print(error.localizedDescription)
                #endif
            }
        }
    }
    
    /// Fetch from Picsum
    /// 
    func fetch() async throws {
        guard let url = URL(string: "https://picsum.photos/v2/list?page=\(page)&limit=30") else { return }
        let response = try await URLSession.shared.data(from: url)
        
        let images = try JSONDecoder().decode([ImageModel].self, from: response.0).compactMap({ item -> ImageModel? in
            return .init(id: item.id, downloadURL: "https://picsum.photos/id/\(item.id)/500/500")
        })
        
        await MainActor.run(body: {
            if self.images == nil { self.images = [] }
            self.images?.append(contentsOf: images)
            
            /// limit to 1000 images
            endFetch = (self.images?.count ?? 0) > 1001
            startFetch = false
        })
    }
}
