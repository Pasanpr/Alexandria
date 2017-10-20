//
//  Set+Extensions.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 10/13/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit

extension CountedSet where Element == UIColor {
    /// Returns a color that is extremely similar to the color compared if the
    /// counted set contains one. This is done by measuring the CIEDE2000 color distance
    /// between the color for a certain threshold
    ///
    /// - Parameter comparisonColor: The color to compare against all colors in the set
    /// - Returns: An optional UIColor instance
    public func colorExtremelySimilar(to comparisonColor: UIColor) -> UIColor? {
        return first(where: { $0.isExtremelySimilar(to: comparisonColor) })
        
    }
}

