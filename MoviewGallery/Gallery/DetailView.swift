//
//  DetailView.swift
//  MoviewGallery
//
//  Created by Milan Djordjevic on 13/03/2024.
//

import SwiftUI

struct DetailView: View {
    @Binding var isDetailShown: Bool
    @Binding var image: Image
    @State var selectedItem: ImageModel
    var animation: Namespace.ID
    
    @State private var zoomScale: CGFloat = 1
    @State private var previousZoomScale: CGFloat = 1
    private let minZoomScale: CGFloat = 0.23
    private let maxZoomScale: CGFloat = 5
    @State private var fadeClose: CGFloat = 0.9
    
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged(onZoomGestureStarted)
            .onEnded(onZoomGestureEnded)
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.opacity(fadeClose).ignoresSafeArea()
                //.matchedGeometryEffect(id: selectedItem.id, in: animation)
            
            PhotoView()
            
            Button {
//                withAnimation {
//                    fadeClose = 0.1
//                } completion: {
                    withAnimation {
                        isDetailShown = false
                    }
//                }
            } label: {
                Image(systemName: "xmark")
                    .font(.body.bold())
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white)
                    .frame(width: 16, height: 16)
                    .padding(12)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .padding(.trailing)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .matchedGeometryEffect(id: selectedItem.id, in: animation)
    }
    
    @ViewBuilder
    private func PhotoView() -> some View {
        GeometryReader { proxy in
            ScrollView([.vertical, .horizontal], showsIndicators: false) {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: proxy.size.width * max(minZoomScale, zoomScale))
                    .frame(maxHeight: .infinity)
                    .onTapGesture(count: 2, perform: onDoubleTap)
                    .gesture(zoomGesture)
            }
        }
    }
    
    // MARK: - Helpers
    private func onDoubleTap() {
        if zoomScale == 1 {
            withAnimation(.spring()) {
                zoomScale = 5
            }
        } else {
            resetImageState()
        }
    }
    
    private func resetImageState() {
        withAnimation(.interactiveSpring()) {
            zoomScale = 1
        }
    }
    
    private func onZoomGestureStarted(value: MagnificationGesture.Value) {
        withAnimation(.easeIn(duration: 0.1)) {
            let delta = value / previousZoomScale
            previousZoomScale = value
            let zoomDelta = zoomScale * delta
            var minMaxScale = max(minZoomScale, zoomDelta)
            minMaxScale = min(maxZoomScale, minMaxScale)
            zoomScale = minMaxScale
//            if zoomScale < 0.25 {
//                isDetailShown = false
//            }
        }
    }
    
    private func onZoomGestureEnded(value: MagnificationGesture.Value) {
        previousZoomScale = 1
        if zoomScale <= 1 {
            resetImageState()
        } else if zoomScale > 5 {
            zoomScale = 5
        }
    }
}

#Preview {
    HomeView()
}
