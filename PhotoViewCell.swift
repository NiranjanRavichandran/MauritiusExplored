//
//  PhotoViewCell.swift
//  MauritiusExplored
//
//  Created by Niranjan Ravichandran on 03/05/15.
//  Copyright (c) 2015 Adavers. All rights reserved.
//

import UIKit

class PhotoViewCell: UICollectionViewCell {
    
 var cellImageView: UIImageView!
 var cellLable: UILabel!
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        cellImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        cellImageView.contentMode = UIViewContentMode.ScaleToFill
        contentView.addSubview(cellImageView)
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
