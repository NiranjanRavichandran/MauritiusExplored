//
//  TextField.swift
//  MauritiusExplored
//
//  Created by Niranjan Ravichandran on 21/05/15.
//  Copyright (c) 2015 Adavers. All rights reserved.
//

import UIKit

class TextField: UITextField {
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        
        super.textRectForBounds(bounds)

        var newBounds: CGRect = bounds
        newBounds.origin.x += 60
        
        return newBounds
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        
        super.editingRectForBounds(bounds)
        var newBounds: CGRect = bounds
        newBounds.origin.x += 60
        
        return newBounds
    }

    override func placeholderRectForBounds(bounds: CGRect) -> CGRect{
        
        super.placeholderRectForBounds(bounds)
        var newBounds: CGRect = bounds
        newBounds.origin.x += 110
        
        return newBounds
    }
}
