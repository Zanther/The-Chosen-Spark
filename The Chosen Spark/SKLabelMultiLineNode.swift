//
//  Untitled.swift
//  The Chosen Spark
//
//  Created by Steven Lattenhauer 2nd on 10/4/24.
//

import SpriteKit

class SKLabelMultiLineNode : SKLabelNode {
    
    public init(text: String,
                fontName: String,
                fontSize: CGFloat,
                hAlignment: SKLabelHorizontalAlignmentMode,
                vAlignment: SKLabelVerticalAlignmentMode,
                labelWidth: CGFloat,
                position: CGPoint,
                zPosition: CGFloat)  {
        super.init()
        
        self.text = text
        self.fontName = fontName
        self.fontSize = fontSize
        self.horizontalAlignmentMode = hAlignment
        self.verticalAlignmentMode = vAlignment
        self.preferredMaxLayoutWidth = labelWidth
        self.position = position
        self.zPosition = zPosition
        self.numberOfLines = 0
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
