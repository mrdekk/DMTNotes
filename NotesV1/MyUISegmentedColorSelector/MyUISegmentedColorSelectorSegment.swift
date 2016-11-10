//
//  MyUISegmentedColorSelectorSegment.swift
//  NotesV1
//
//  Created by Dmitry Galimzyanov on 08.11.16.
//  Copyright © 2016 Dmitry Galimzyanov. All rights reserved.
//

import UIKit

@IBDesignable
class MyUISegmentedColorSelectorSegment: MyUIHorizontalTableCell {

    @IBOutlet weak var root: UIView!
    @IBOutlet weak var colorView: UIView!

    @IBInspectable
    var color: UIColor? {
        get {
            return colorView.backgroundColor
        }
        set {
            colorView.backgroundColor = newValue
        }
    }

    //@IBInspectable
    //var isOutlined : Bool {
    //    get {
    //        return root.backgroundColor == UIColor.black
    //    }
    //    set {
    //        if newValue {
    //            root.backgroundColor = UIColor.black
    //        } else {
    //            root.backgroundColor = nil
    //        }
    //    }
    //}

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    private func commonInit() {
        loadSubviewFromXib()
        root.widthAnchor.constraint(equalTo: root.heightAnchor, multiplier: 1).isActive = true
        //isOutlined = false
    }

}
