//
//  CachedAsyncImage.swift
//  MoviewGallery
//
//  Created by Milan Djordjevic on 13/03/2024.
//

import SwiftUI

struct CachedAsyncImage<Content>: View where Content: View {
    private let url: URL
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (AsyncImagePhase) -> Content
    
    init(url: URL,
         scale: CGFloat = 1,
         transaction: Transaction = Transaction(),
         @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
    }
    
    var body: some View {
        AsyncImage(url: url, scale: scale, transaction: transaction) { phase in
            cacheAndRender(phase: phase)
        }
    }
    
    /// https://developer.apple.com/videos/play/wwdc2021/10022/ Why we need Viewbuild :D
    @ViewBuilder
    func cacheAndRender(phase: AsyncImagePhase) -> some View {
        content(phase)
    }
}

#Preview {
    CachedAsyncImage(url: URL(string: "https://picsum.photos/id/42/500/500")!) { phase in
        switch phase {
        case .empty:
            ProgressView()
        case .success(let image):
            image
        case .failure(let error):
            Text("error: \(error.localizedDescription)")
        @unknown default:
            fatalError()
        }
    }
}

fileprivate class ImageCache {
    private let cache = URLCache.shared
    
    func getImage(url: URL) -> Image? {
        if let response = cache.cachedResponse(for: URLRequest(url: url)), let uiImage = UIImage(data: response.data) {
            return Image(uiImage: uiImage)
        }
        return nil
    }
}

