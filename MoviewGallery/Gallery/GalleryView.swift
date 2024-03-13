//
//  GalleryView.swift
//  MoviewGallery
//
//  Created by Milan Djordjevic on 13/03/2024.
//

import SwiftUI

/// We have only two for now ;)
enum LayoutType {
    case oneBigFourSmall
    case fourSmallOneBig
}

struct GalleryView<Content, Item, ID>: View where Content: View, ID: Hashable, Item: RandomAccessCollection, Item.Element: Hashable {
    var content: (Item.Element) -> Content
    var items: Item
    var id: KeyPath<Item.Element, ID>
    var spacing: CGFloat
    
    init(items: Item,
         id: KeyPath<Item.Element, ID>,
         spacing: CGFloat = 5,
         @ViewBuilder content: @escaping (Item.Element) -> Content) {
        self.content = content
        self.id = id
        self.items = items
        self.spacing = spacing
    }
    
    var body: some View {
        LazyVStack(spacing: spacing) {
            ForEach(generateColumns(), id: \.self) { row in
                RowView(row: row)
            }
        }
    }
    
    // MARK: - Views
    @ViewBuilder
    private func RowView(row: [Item.Element]) -> some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = (proxy.size.height - spacing) / 2
            let type = layoutType(row: row)
            let columnWidth = (width > 0 ? ((width - (spacing * 3)) / 4) : 0)
            
            HStack(spacing: spacing) {
                if type == .oneBigFourSmall {
                    WrapView(row: row, index: 0)
                    
                    VStack(spacing: spacing) {
                        WrapView(row: row, index: 1)
                            .frame(height: height)
                        
                        WrapView(row: row, index: 2)
                            .frame(height: height)
                    }
                    .frame(width: columnWidth)
                    
                    VStack(spacing: spacing) {
                        WrapView(row: row, index: 3)
                            .frame(height: height)
                        
                        WrapView(row: row, index: 4)
                            .frame(height: height)
                    }
                    .frame(width: columnWidth)
                }
                
                if type == .fourSmallOneBig {
                    VStack(spacing: spacing) {
                        WrapView(row: row, index: 0)
                            .frame(height: height)
                        
                        WrapView(row: row, index: 1)
                            .frame(height: height)
                    }
                    .frame(width: columnWidth)
                    
                    VStack(spacing: spacing) {
                        WrapView(row: row, index: 2)
                            .frame(height: height)
                        
                        WrapView(row: row, index: 3)
                            .frame(height: height)
                    }
                    .frame(width: columnWidth)
                    
                    WrapView(row: row, index: 4)
                }
            }
        }
        .frame(height: layoutType(row: row) == .oneBigFourSmall || layoutType(row: row) == .fourSmallOneBig ? 260 : 120)
    }
    
    /// Safe unwrap view
    @ViewBuilder
    func WrapView(row: [Item.Element], index: Int) -> some View {
        if (row.count - 1) >= index {
            content(row[index])
        }
    }
    
    // MARK: - Helpers
    private func layoutType(row: [Item.Element]) -> LayoutType {
        let index = generateColumns().firstIndex { item in return item == row } ?? 0
        
        /// This could be better...
        /// but works for now
        var types: [LayoutType] = []
        generateColumns().forEach { _ in
            if types.isEmpty {
                types.append(.oneBigFourSmall)
            } else if types.last == .oneBigFourSmall {
                types.append(.fourSmallOneBig)
            } else if types.last == .fourSmallOneBig {
                types.append(.oneBigFourSmall)
            }
        }
        
        return types[index]
    }
    
    private func generateColumns() -> [[Item.Element]] {
        var columns: [[Item.Element]] = []
        var row: [Item.Element] = []
        
        for item in items {
            /// five images per row...
            if row.count == 5 {
                columns.append(row)
                row.removeAll()
                row.append(item)
            } else {
                row.append(item)
            }
        }
        
        columns.append(row)
        row.removeAll()
        return columns
    }
}

#Preview {
    HomeView()
}
