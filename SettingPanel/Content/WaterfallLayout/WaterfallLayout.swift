//
//  WaterfallLayout.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-12-22.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class WaterfallLayout: NSCollectionViewLayout {
  weak var delegate: NSCollectionViewDelegateWaterfallLayout?
  
  private var contentHeight: CGFloat = 0
  private var columnWidth: CGFloat {
    guard let collectionView = collectionView else { return 0 }
    let numOfCols = delegate?.numberOfColumns(in: collectionView) ?? 1
    return collectionViewContentSize.width / CGFloat(numOfCols)
  }
  
  private var cache: [[NSCollectionViewLayoutAttributes]] = []
  
  override var collectionViewContentSize: NSSize {
    guard let collectionView = collectionView else { return .zero }
    if let connectedDelegate = delegate {
      let contentInsets = (0..<collectionView.numberOfSections).map {
        connectedDelegate.collectionView(collectionView, layout: self, insetForSectionAt: $0)
      }
      let minRight  = contentInsets.map { $0.right }.min()!
      let minLeft   = contentInsets.map { $0.left }.min()!
      let maxBottom = contentInsets.map { $0.bottom }.max()!
      return NSSize(width: collectionView.bounds.width - minRight - minLeft,
                    height: contentHeight + maxBottom)
    } else {
      return super.collectionViewContentSize
    }
  }
  
  override func prepare() {
    guard
      cache.isEmpty,
      let collectionView = collectionView
    else { return }
    
    let xOffsets = (0 ..< (delegate?.numberOfColumns(in: collectionView) ?? 0)).map {
      CGFloat($0) * columnWidth
    }
    var column = 0
    let TopInset = delegate?.collectionView(collectionView, layout: self, insetForSectionAt: 0) ?? NSEdgeInsetsZero
    let columnNum = delegate?.numberOfColumns(in: collectionView) ?? 1
    var yOffsets = [CGFloat](repeating: TopInset.top, count: columnNum)
    for section in 0 ..< collectionView.numberOfSections {
      let inset = delegate?.collectionView(collectionView, layout: self, insetForSectionAt: section) ?? NSEdgeInsetsZero
      var cacheAtSection: [NSCollectionViewLayoutAttributes] = []
      for item in 0 ..< collectionView.numberOfItems(inSection: section) {
        let indexPath = IndexPath(item: item, section: section)
        let attribute = NSCollectionViewLayoutAttributes(forItemWith: indexPath)
        
        let itemHeight = delegate?.collectionView(collectionView, layout: self, heightForItemAt: indexPath) ?? 0
        let spacing = delegate?.collectionView(collectionView, layout: self, minimumInteritemSpacingForSectionAt: section) ?? 0
        let height = itemHeight + spacing * 2
        let xPos = xOffsets[column] + spacing + inset.left / 2
        let frame = NSRect(x: xPos, y: yOffsets[column], width: columnWidth, height: height)
        let insetsFrame = frame.insetBy(dx: spacing, dy: spacing)
        
        attribute.frame = insetsFrame
        cacheAtSection.append(attribute)
        
        contentHeight = max(contentHeight, frame.maxY)
        yOffsets[column] += height
        
        column = yOffsets.enumerated().min { $0.element < $1.element }?.offset ?? 0
      }
      cache.append(cacheAtSection)
      guard let maxYOffSet = yOffsets.max() else { return }
      let minSectionSpacing = delegate?.collectionView(collectionView, layout: self, minimumLineSpacingForSectionAt: section) ?? 0
      yOffsets = [CGFloat](repeating: maxYOffSet + minSectionSpacing, count: yOffsets.count)
    }
  }
  
  override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
    let visibleAttributes = cache.map {
      $0.filter { attribute in attribute.frame.intersects(rect) }
    }.reduce([], +)
    return visibleAttributes
  }
  
  override func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
    return cache[indexPath.section][indexPath.item]
  }
}
