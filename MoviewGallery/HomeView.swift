//
//  HomeView.swift
//  MoviewGallery
//
//  Created by Milan Djordjevic on 13/03/2024.
//

import SwiftUI

struct HomeView: View {
    @StateObject var galleryViewModel = GalleryViewModel()
    
    var body: some View {
        Group {
            if let images = galleryViewModel.images {
                ScrollView(showsIndicators: false) {
                    Gallery(with: images)
                        .padding()
                        .padding(.bottom, 10)
                    
                    Status()
                }
            }
        }
        .onAppear {
            galleryViewModel.update()
        }
    }
    
    // MARK: - Views
    
    @ViewBuilder
    private func Gallery(with images: [ImageModel]) -> some View {
        GalleryView(items: images, id: \.id) { item in
            CachedAsyncImage(url: URL(string: item.downloadURL)!) { phase in
                if let image = phase.image {
                    GeometryReader { proxy in
                        let size = proxy.size
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .cornerRadius(6)
                            .onAppear {
                                if images.last?.id == item.id {
                                    galleryViewModel.startFetch = true
                                }
                            }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func Status() -> some View {
        if galleryViewModel.startFetch && !galleryViewModel.endFetch {
            VStack {
                Text("Page \(galleryViewModel.page) of 100")
                    .font(.caption)
                ProgressView()
            }
            .offset(y: -15)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    galleryViewModel.update()
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
