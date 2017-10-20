//
//  Palette.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 10/13/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit

struct Palette {
    // MARK: Default Values
    
    fileprivate struct Constants {
        struct Luma {
            struct Dark {
                static let target: CGFloat = 0.26
                static let max: CGFloat = 0.45
            }
            
            struct Normal {
                static let min: CGFloat = 0.3
                static let target: CGFloat = 0.5
                static let max: CGFloat = 0.7
            }
            
            struct Light {
                static let min: CGFloat = 0.55
                static let target: CGFloat = 0.74
                
            }
        }
        
        struct Saturation {
            struct Muted {
                static let target: CGFloat = 0.3
                static let max: CGFloat = 0.4
            }
            
            struct Vibrant {
                static let target: CGFloat = 1.0
                static let min: CGFloat = 0.35
            }
        }
        
        struct Weight {
            static let saturation: CGFloat = 3.0
            static let luma: CGFloat = 6.0
            static let population: CGFloat = 5.0
        }
    }
    
    private let countedColors: CountedSet<UIColor>
    
    init(image: UIImage) {
        self.countedColors = image.dominantColorsForSize()
    }
    
    // MARK: Palette Colors
    
    var vibrant: UIColor? {
        return colorMatchFor(targetLuma: Constants.Luma.Normal.target, minLuma: Constants.Luma.Normal.min, maxLuma: Constants.Luma.Normal.max, targetSaturation: Constants.Saturation.Vibrant.target, minSaturation: Constants.Saturation.Vibrant.min, maxSaturation: 1)
    }
    
    var lightVibrant: UIColor? {
        return colorMatchFor(targetLuma: Constants.Luma.Light.target, minLuma: Constants.Luma.Light.min, maxLuma: 1.0, targetSaturation: Constants.Saturation.Vibrant.target, minSaturation: Constants.Saturation.Vibrant.min, maxSaturation: 1)
    }
    
    var darkVibrant: UIColor? {
        return colorMatchFor(targetLuma: Constants.Luma.Dark.target, minLuma: 0, maxLuma: Constants.Luma.Dark.max, targetSaturation: Constants.Saturation.Vibrant.target, minSaturation: Constants.Saturation.Vibrant.min, maxSaturation: 1)
    }
    
    var muted: UIColor? {
        return colorMatchFor(targetLuma: Constants.Luma.Normal.target, minLuma: Constants.Luma.Normal.min, maxLuma: Constants.Luma.Normal.max, targetSaturation: Constants.Saturation.Muted.target, minSaturation: 0, maxSaturation: Constants.Saturation.Muted.max)
    }
    
    var lightMuted: UIColor? {
        return colorMatchFor(targetLuma: Constants.Luma.Light.target, minLuma: Constants.Luma.Light.min, maxLuma: 1, targetSaturation: Constants.Saturation.Muted.target, minSaturation: 0, maxSaturation: Constants.Saturation.Muted.max)
    }
    
    var darkMuted: UIColor? {
        return colorMatchFor(targetLuma: Constants.Luma.Dark.target, minLuma: 0, maxLuma: Constants.Luma.Dark.max, targetSaturation: Constants.Saturation.Muted.target, minSaturation: 0, maxSaturation: Constants.Saturation.Muted.max)
    }
    
    // MARK: Private
    
    private func colorMatchFor(targetLuma: CGFloat, minLuma: CGFloat, maxLuma: CGFloat, targetSaturation: CGFloat, minSaturation: CGFloat, maxSaturation: CGFloat) -> UIColor? {
        var bestMatch: UIColor? = nil
        var maxComparisonValue: CGFloat = 0
        
        for color in countedColors.elements {
            let saturationIsInBetweenThresholds = color.saturation >= minSaturation && color.saturation <= maxSaturation
            let lumaIsInBetweenThresholds = color.luma >= minLuma && color.luma <= maxLuma
            
            if saturationIsInBetweenThresholds && lumaIsInBetweenThresholds {
                let currentColorCount = CGFloat(countedColors.count(for: color))
                let highestColorCount = CGFloat(countedColors.count(for: countedColors.first!))
                
                let weightedComparisonValue = weightedComparison(saturation: color.saturation, targetSaturation: targetSaturation, luma: color.luma, targetLuma: targetLuma, population: currentColorCount, maxPopulation: highestColorCount)
                
                if bestMatch == nil || weightedComparisonValue > maxComparisonValue {
                    bestMatch = color
                    maxComparisonValue = weightedComparisonValue
                }
            }
        }
        
        return bestMatch
    }
    
    private func weightedComparison(saturation: CGFloat, targetSaturation: CGFloat, luma: CGFloat, targetLuma: CGFloat, population: CGFloat, maxPopulation: CGFloat) -> CGFloat {
        let saturationInvertedDiff = invertedDifference(saturation, targetSaturation)
        let lumaInvertedDiff = invertedDifference(luma, targetLuma)
        let populationRatio = population/maxPopulation
        
        let saturationValueWeight = (saturationInvertedDiff, Constants.Weight.saturation)
        let lumaValueWeight = (lumaInvertedDiff, Constants.Weight.luma)
        let populationValueWeight = (populationRatio, Constants.Weight.population)
        
        return weightedMean(saturationValueWeight, lumaValueWeight, populationValueWeight)
    }
    
    /// Returns the weighted mean of a series of value and weight pairs
    ///
    /// - Parameter values: A tuple of a value and its corresponding weight
    /// - Returns: Sum of the weighted values divided by sum of weights
    private func weightedMean(_ values: (value: CGFloat, weight: CGFloat)...) -> CGFloat {
        let sumWeightedValues = values.reduce(0) { sum, input in return sum + (input.value * input.weight )}
        let sumWeights = values.reduce(0) { sum, input in return sum + input.weight }
        
        return sumWeightedValues/sumWeights
    }
    
    /// Returns 1 minus the absolute difference between two numbers
    private func invertedDifference(_ x: CGFloat, _ y: CGFloat) -> CGFloat {
        return 1 - abs((x - y))
    }
}

