//
//  File.swift
//  
//
//  Created by JWI on 26/11/2025.
//

import Foundation
@_exported import IBPCollectionViewCompositionalLayout

public typealias NSCollectionLayoutAnchor = IBPNSCollectionLayoutAnchor
public typealias NSCollectionLayoutBoundarySupplementaryItem = IBPNSCollectionLayoutBoundarySupplementaryItem
public typealias NSCollectionLayoutDecorationItem = IBPNSCollectionLayoutDecorationItem
public typealias NSCollectionLayoutDimension = IBPNSCollectionLayoutDimension
public typealias NSCollectionLayoutEdgeSpacing = IBPNSCollectionLayoutEdgeSpacing
public typealias NSCollectionLayoutEnvironment = IBPNSCollectionLayoutEnvironment
public typealias NSCollectionLayoutGroup = IBPNSCollectionLayoutGroup
public typealias NSCollectionLayoutGroupCustomItem = IBPNSCollectionLayoutGroupCustomItem
public typealias NSCollectionLayoutItem = IBPNSCollectionLayoutItem
public typealias NSCollectionLayoutSection = IBPNSCollectionLayoutSection
public typealias NSCollectionLayoutSize = IBPNSCollectionLayoutSize
public typealias NSCollectionLayoutSpacing = IBPNSCollectionLayoutSpacing
public typealias NSCollectionLayoutSupplementaryItem = IBPNSCollectionLayoutSupplementaryItem
public typealias NSCollectionLayoutVisibleItem = IBPNSCollectionLayoutVisibleItem
public typealias NSDirectionalEdgeInsets = IBPNSDirectionalEdgeInsets
public typealias UICollectionLayoutSectionOrthogonalScrollingBehavior = IBPUICollectionLayoutSectionOrthogonalScrollingBehavior
public typealias UICollectionViewCompositionalLayout = IBPUICollectionViewCompositionalLayout
public typealias UICollectionViewCompositionalLayoutConfiguration = IBPUICollectionViewCompositionalLayoutConfiguration

extension IBPNSDirectionalEdgeInsets {
    public static var zero: IBPNSDirectionalEdgeInsets {
        return IBPNSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    }
}
