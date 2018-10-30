//
//  LineView.swift
//  FaceSwaping
//
//  Created by Diego Alejandro Villa Cardenas on 10/30/18.
//  Copyright © 2018 Diego Alejandro Villa Cardenas. All rights reserved.
//

import Foundation
import UIKit

class LineView : UIView {
    var points: [CGPoint] = [CGPoint(x: 0, y: 0)]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
    }
    
    init(frame: CGRect, points: [CGPoint]) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
        self.points = points
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
                if let context = UIGraphicsGetCurrentContext() {
                    context.setStrokeColor(UIColor.red.cgColor)
                    context.setLineWidth(1)
                    context.beginPath()
                    context.addLines(between: self.points)
                    context.closePath()
                    context.strokePath()
                }
    }
}
