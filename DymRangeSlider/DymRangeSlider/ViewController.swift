//
//  ViewController.swift
//  DymRangeSlider
//
//  Created by Yiming Dong on 29/11/18.
//  Copyright © 2018 Yiming Dong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        
        let slider = RangeSlider(frame: CGRect(x: 50, y: 90, width: 200, height: 20))
        slider.type = .singleMin
        slider.minimumValue = 10
        slider.maximumValue = 100
        slider.boundValuesInRange()
    
        view.addSubview(slider)
    }

}

