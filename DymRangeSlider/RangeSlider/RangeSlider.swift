//
//  RangeSlider.swift
//  FSInvestor
//
//  Created by Yiming Dong on 29/11/18.
//  Copyright © 2018 Funding Societies. All rights reserved.
//

import UIKit

public class RangeSlider: UIControl {
    
    enum SliderType {
        case fullRange
        case singleMax
        case singleMin
    }
    var type: SliderType = .fullRange {
        didSet {
            initializeLayers()
        }
    }
    
    fileprivate var previouslocation = CGPoint()
    
    let trackLayer = SliderTrackLayer()
    let lowerThumbLayer = SliderThumbLayer()
    let upperThumbLayer = SliderThumbLayer()
    
    private func printValues(_ functionName: StaticString = #function) {
        print("\(functionName)>>> minimumValue:\(minimumValue), maximumValue:\(maximumValue), lowerValue:\(lowerValue), upperValue:\(upperValue)")
    }
    
    public var minimumValue: CGFloat = 0.0 {
        didSet {
            printValues()
            updateLayerFrames()
        }
    }
    
    public var maximumValue: CGFloat = 1.0 {
        didSet {
            printValues()
            updateLayerFrames()
        }
    }
    
    public var lowerValue: CGFloat = 0.2 {
        didSet {
            printValues()
            updateLayerFrames()
        }
    }
    
    public var upperValue: CGFloat = 0.8 {
        didSet {
            printValues()
            updateLayerFrames()
        }
    }
    
    fileprivate var thumbWidth: CGFloat {
        return CGFloat(bounds.height)
    }
    
    fileprivate var thumbWidthHalf: CGFloat {
        return CGFloat(bounds.height) * 0.5
    }
    
    override public var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initializeLayers()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeLayers()
    }
    
    override public func layoutSublayers(of: CALayer) {
        super.layoutSublayers(of: layer)
        updateLayerFrames()
    }
    
    fileprivate func initializeLayers() {
        
        trackLayer.removeFromSuperlayer()
        lowerThumbLayer.removeFromSuperlayer()
        upperThumbLayer.removeFromSuperlayer()
        
        layer.backgroundColor = UIColor.clear.cgColor
        
        trackLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(trackLayer)
        
        if type != .singleMax {
            lowerThumbLayer.contentsScale = UIScreen.main.scale
            layer.addSublayer(lowerThumbLayer)
        }
        
        if type != .singleMin {
            upperThumbLayer.contentsScale = UIScreen.main.scale
            layer.addSublayer(upperThumbLayer)
        }
    }
}

extension RangeSlider {
    
    var fullRange: CGFloat {
        return maximumValue - minimumValue
    }
    
    func relative(value: CGFloat) -> CGFloat {
        return value - minimumValue
    }
    
    func relativeRatio(value: CGFloat) -> CGFloat {
        guard fullRange > 0 else {return 0}
        return relative(value: value) / fullRange
    }
    
    var disabledRange: CGFloat {
        guard bounds.width > 0 else {return 0}
        return type == .fullRange ? (thumbWidthHalf * fullRange / bounds.width) : 0
    }
    
    func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        // height of track is 1/3 of that of the slider
        trackLayer.frame = bounds.insetBy(dx: 0.0, dy: bounds.height * 0.333)
        trackLayer.layerModel.lower = relativeRatio(value: lowerValue)
        trackLayer.layerModel.upper = relativeRatio(value: upperValue)
        
        
        let lowerThumbCenter = positionForValue(lowerValue)
        lowerThumbLayer.frame = CGRect(x: lowerThumbCenter - thumbWidthHalf, y: 0.0, width: thumbWidth, height: thumbWidth)
        
        
        let upperThumbCenter = positionForValue(upperValue)
        upperThumbLayer.frame = CGRect(x: upperThumbCenter - thumbWidthHalf, y: 0.0, width: thumbWidth, height: thumbWidth)
        
        setNeedsDisplay()
        
        print("--------------")
        print("maxValue: \(maximumValue)")
        print("minValue: \(minimumValue)")
        print("lowerValue: \(lowerValue)")
        print("upperValue: \(upperValue)")
        print("trackLayer: \(trackLayer.frame)")
        print("lowerThumbLayer: \(lowerThumbLayer.frame)")
        print("upperThumbLayer: \(upperThumbLayer.frame)")
        
        CATransaction.commit()
    }
    
    public override func setNeedsDisplay() {
        super.setNeedsDisplay()
        
        trackLayer.setNeedsDisplay()
        lowerThumbLayer.setNeedsDisplay()
        upperThumbLayer.setNeedsDisplay()
    }
    
    func positionForValue(_ value: CGFloat, isThumb: Bool = false) -> CGFloat {
        guard fullRange > 0 else {return 0}
        
        var position = bounds.width * relativeRatio(value: value)
        if isThumb {
            position -= thumbWidthHalf
        }
        
        return position
    }
    
    private func boundValue(_ value: CGFloat, toLowerValue lowerValue: CGFloat, upperValue: CGFloat) -> CGFloat {
        return min(max(value, lowerValue), upperValue)
    }
    
    func boundValuesInRange() {
        
        lowerValue = boundValue(lowerValue, toLowerValue: minimumValue, upperValue: maximumValue - disabledRange)
        upperValue = boundValue(upperValue, toLowerValue: minimumValue + disabledRange, upperValue: maximumValue)
        
        if type == .singleMin {
            upperValue = maximumValue
        } else if type == .singleMax {
            lowerValue = minimumValue
        }
    }
}

// MARK: Tracking
extension RangeSlider {
    override public func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        // Determine value change, by how much the user has dragged
        let movement = (location.x - previouslocation.x)
        let deltaValue = fullRange * movement / (bounds.width - thumbWidth)
        
        previouslocation = location
        
        // Hit test the thumb layers
        if type != .singleMax && lowerThumbLayer.frame.contains(location) {
            lowerThumbLayer.layerModel.highlighted = true
        } else if type != .singleMin && upperThumbLayer.frame.contains(location) {
            upperThumbLayer.layerModel.highlighted = true
        } else if type == .singleMax {
            upperValue = boundValue(upperValue + deltaValue, toLowerValue: lowerValue + disabledRange, upperValue: maximumValue)
        } else if type == .singleMin {
            lowerValue = boundValue(lowerValue + deltaValue, toLowerValue: minimumValue, upperValue: upperValue - disabledRange)
        }
        
        return lowerThumbLayer.layerModel.highlighted || upperThumbLayer.layerModel.highlighted
    }
    
    override public func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        // Determine value change, by how much the user has dragged
        let movement = (location.x - previouslocation.x)
        let deltaValue = fullRange * movement / (bounds.width - thumbWidth)
        
        previouslocation = location

        // Update the values
        if lowerThumbLayer.layerModel.highlighted {
            lowerValue = boundValue(lowerValue + deltaValue, toLowerValue: minimumValue, upperValue: upperValue - disabledRange)
        } else if upperThumbLayer.layerModel.highlighted {
            upperValue = boundValue(upperValue + deltaValue, toLowerValue: lowerValue + disabledRange, upperValue: maximumValue)
        }
        
        setNeedsDisplay()
        
        sendActions(for: .valueChanged)
        
        return true
    }
    
    override public func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        lowerThumbLayer.layerModel.highlighted = false
        upperThumbLayer.layerModel.highlighted = false
    }
}
