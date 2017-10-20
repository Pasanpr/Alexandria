//
//  LumaGradientView.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 10/13/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit

public final class LumaGradientView: UIView {
    private let palette: Palette
    private let blurEffectStyle: UIBlurEffectStyle
    
    // MARK: Pivot Circles
    public var pivotPoints: Int = 3
    
    public lazy var pivotCircleDiameter: CGFloat = {
        let maxWidth = self.frame.width
        return maxWidth/4
    }()
    
    init(image: UIImage, blurEffectStyle: UIBlurEffectStyle) {
        self.palette = Palette(image: image)
        self.blurEffectStyle = blurEffectStyle
        super.init(frame: .zero)
    }
    
    private lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: self.blurEffectStyle)
        return UIVisualEffectView(effect: blurEffect)
    }()
    
    private var bestMatch: (startColor: UIColor, stopColor: UIColor) {
        if let darkVibrant = palette.darkVibrant, let lightVibrant = palette.lightVibrant {
            return (darkVibrant, lightVibrant)
        } else if let lightVibrant = palette.lightVibrant, let darkMuted = palette.darkMuted {
            return (lightVibrant, darkMuted)
        } else if let darkVibrant = palette.darkVibrant, let lightMuted = palette.lightMuted {
            return (darkVibrant, lightMuted)
        } else if let darkMuted = palette.darkMuted, let lightMuted = palette.lightMuted {
            return (darkMuted, lightMuted)
        } else {
            return (palette.vibrant!, palette.muted!)
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    public override func draw(_ rect: CGRect) {
        guard let currentContext = UIGraphicsGetCurrentContext() else { return }
        
        let colors = [bestMatch.startColor.cgColor, bestMatch.stopColor.cgColor] as CFArray
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0.0, 1.0]) else { return }
        
        let start = CGPoint(x: 0, y: 0)
        let end = CGPoint(x: bounds.width, y: bounds.height)
        
        currentContext.drawLinearGradient(gradient, start: start, end: end, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        
        var existingCircles = [CGRect]()
        
        for _ in 0..<pivotPoints {
            let point = randomPoint(in: rect, existingPivotCircles: existingCircles)
            let pivotCircle = addPivotCircle(at: point)
            existingCircles.append(pivotCircle)
        }
    }
    
    // MARK: Private
    
    private func randomPoint(in rect: CGRect, existingPivotCircles: [CGRect]) -> CGPoint {
        func generateRandomX(for rect: CGRect) -> CGFloat {
            var x = CGFloat(arc4random_uniform(UInt32(rect.width))) + rect.origin.x
            
            if x + pivotCircleDiameter > rect.maxX {
                x = x - pivotCircleDiameter
            }
            
            return x
        }
        
        func generateRandomY(for rect: CGRect) -> CGFloat {
            var y = CGFloat(arc4random_uniform(UInt32(rect.height))) + rect.origin.y
            
            if y + pivotCircleDiameter > rect.maxY {
                y = y - pivotCircleDiameter
            }
            
            return y
        }
        
        func randomCircle(in rect: CGRect) -> CGRect {
            let randomX = generateRandomX(for: rect)
            let randomY = generateRandomY(for: rect)
            
            return CGRect(x: randomX, y: randomY, width: pivotCircleDiameter, height: pivotCircleDiameter)
        }
        
        func circle(_ circle: CGRect, intersectsWith rects: [CGRect]) -> Bool {
            for rect in rects {
                if circle.intersects(rect) {
                    return true
                }
            }
            
            return false
        }
        
        var hypotheticalRect = randomCircle(in: rect)
        
        while circle(hypotheticalRect, intersectsWith: existingPivotCircles) {
            hypotheticalRect = randomCircle(in: rect)
        }
        
        return CGPoint(x: hypotheticalRect.origin.x, y: hypotheticalRect.origin.y)
    }
    
    private func addPivotCircle(at point: CGPoint) -> CGRect {
        let rect = CGRect(origin: point, size: CGSize(width: pivotCircleDiameter, height: pivotCircleDiameter))
        let ovalPath = UIBezierPath(ovalIn: rect)
        let fillColor = interpolatedColor(at: point)
        fillColor.setFill()
        ovalPath.fill()
        
        return rect
    }
    
    
    private func gradientPercentageGivenPoint(_ point: CGPoint) -> CGFloat {
        // http://www.teacherschoice.com.au/Maths_Library/Trigonometry/triangle_given_3_points.htm
        func distanceBetween(_ start: CGPoint, _ stop: CGPoint) -> CGFloat {
            let xDistance = stop.x - start.x
            let yDistance = stop.y - start.y
            
            let xSquared = xDistance * xDistance
            let ySquared = yDistance * yDistance
            
            return CGFloat(sqrt((xSquared + ySquared)))
        }
        
        func largestAngle(originEndDistance oe: CGFloat, originPointDistance op: CGFloat, pointEndDistance pe: CGFloat) -> CGFloat {
            let opSq = op * op
            let oeSq = oe * oe
            let peSq = pe * pe
            
            let cosP = (opSq + peSq - oeSq)/(2 * op * pe)
            return acos(cosP) * 180/CGFloat.pi
        }
        
        func angleAtOrigin(originEndDistance oe: CGFloat, pointEndDistance pe: CGFloat, angleAtPoint p: CGFloat) -> CGFloat {
            let angleP = p * .pi/180
            let sinP = sin(angleP)
            let sinO = (sinP * pe)/oe
            return asin(sinO) * 180/CGFloat.pi
        }
        
        func lengthOnDiagonal(angleAtOrigin o: CGFloat, hypotenuse h: CGFloat) -> CGFloat {
            let angleO = o * .pi/180
            return cos(angleO) * h
        }
        
        let origin = frame.origin
        let end = CGPoint(x: frame.width, y: frame.height)
        
        let originEndDistance = distanceBetween(origin, end)
        let originPointDistance = distanceBetween(origin, point)
        let pointEndDistance = distanceBetween(point, end)
        
        // Angle P is the angle formed by the point to origin on one side and
        // end on the other
        let angleP = largestAngle(originEndDistance: originEndDistance, originPointDistance: originPointDistance, pointEndDistance: pointEndDistance)
        
        // Angle O is the angle formed at origin to the point on one side and
        // end on the other
        let angleO = angleAtOrigin(originEndDistance: originEndDistance, pointEndDistance: pointEndDistance, angleAtPoint: angleP)
        
        let intermediatePointLength = lengthOnDiagonal(angleAtOrigin: angleO, hypotenuse: originPointDistance)
        
        return intermediatePointLength/originEndDistance
    }
    
    private func interpolatedColor(at point: CGPoint) -> UIColor {
        // https://stackoverflow.com/a/22649247
        let percent = gradientPercentageGivenPoint(point)
        
        let startColor = bestMatch.startColor
        let stopColor = bestMatch.stopColor
        
        let redResult = startColor.rgba.red + (percent * (stopColor.rgba.red - startColor.rgba.red))
        let greenResult = startColor.rgba.green + (percent * (stopColor.rgba.green - startColor.rgba.green))
        let blueResult = startColor.rgba.blue + (percent * (stopColor.rgba.blue - startColor.rgba.blue))
        
        return UIColor(red: redResult, green: greenResult, blue: blueResult, alpha: 1.0)
    }
    
    private func color(at point: CGPoint, startColor: UIColor, stopColor: UIColor) -> UIColor {
        return .black
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurView)
        
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}

