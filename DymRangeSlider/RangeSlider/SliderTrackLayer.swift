//
//  SliderTrackLayer.swift
//  FSInvestor
//
//  Created by Yiming Dong on 29/11/18.
//  Copyright © 2018 Funding Societies. All rights reserved.
//

import UIKit

class SliderTrackLayerModel {
    var curvaceousness: CGFloat = 1.0 {
        didSet {
            if curvaceousness < 0.0 {
                curvaceousness = 0.0
            }
            
            if curvaceousness > 1.0 {
                curvaceousness = 1.0
            }
        }
    }
    var trackTintColor: UIColor = UIColor(white: 1, alpha: 0.2)
    var trackHighlightTintColor: UIColor = UIColor.blue
    var lower: CGFloat = 0.2
    var upper: CGFloat = 1
}

class SliderTrackLayer: CALayer {
    
    var layerModel: SliderTrackLayerModel = SliderTrackLayerModel() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(in ctx: CGContext) {
        
        // Clip
        let cornerRadius = bounds.height * layerModel.curvaceousness * 0.5
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        
        // Fill the track
        ctx.setFillColor(layerModel.trackTintColor.cgColor)
        ctx.addPath(path.cgPath)
        ctx.fillPath()
        
        // Fill the highlighted range
        ctx.setFillColor(layerModel.trackHighlightTintColor.cgColor)
        let lowerValuePosition = bounds.width * layerModel.lower
        let upperValuePosition = bounds.width * layerModel.upper
        let rect = CGRect(x: lowerValuePosition, y: 0.0, width: upperValuePosition - lowerValuePosition, height: bounds.height)
        let pathInner = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        ctx.addPath(pathInner.cgPath)
        ctx.fillPath()
    }
}
