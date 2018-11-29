//
//  SliderThumbLayer.swift
//  FSInvestor
//
//  Created by Yiming Dong on 29/11/18.
//  Copyright © 2018 Funding Societies. All rights reserved.
//

import UIKit

class SliderThumbLayerModel {
    var highlighted: Bool = false
    var fillColor: UIColor = UIColor.white
    var strokeColor: UIColor = UIColor.gray
    var lineWidth: CGFloat = 0.5
}

class SliderThumbLayer: CALayer {
    
    var layerModel: SliderThumbLayerModel = SliderThumbLayerModel() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(in ctx: CGContext) {
        
        let thumbFrame = bounds.insetBy(dx: 2.0, dy: 2.0)
        let cornerRadius = thumbFrame.height * 0.5
        let thumbPath = UIBezierPath(roundedRect: thumbFrame, cornerRadius: cornerRadius)
        
        // Fill
        ctx.setFillColor(layerModel.fillColor.cgColor)
        ctx.addPath(thumbPath.cgPath)
        ctx.fillPath()
        
        // Outline
        ctx.setStrokeColor(layerModel.strokeColor.cgColor)
        ctx.setLineWidth(layerModel.lineWidth)
        ctx.addPath(thumbPath.cgPath)
        ctx.strokePath()
        
        // highlight mask
        if layerModel.highlighted {
            ctx.setFillColor(UIColor(white: 0.0, alpha: 0.1).cgColor)
            ctx.addPath(thumbPath.cgPath)
            ctx.fillPath()
        }
    }
}
