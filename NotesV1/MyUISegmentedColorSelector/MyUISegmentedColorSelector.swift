//
//  MyUISegmentedColorSelector.swift
//  NotesV1
//
//  Created by Dmitry Galimzyanov on 02.11.16.
//  Copyright © 2016 Dmitry Galimzyanov. All rights reserved.
//

import UIKit

@objc
protocol MyUISegmentedColorSelectorDelegate : class, NSObjectProtocol {
    @objc optional func colorSelectorDidSelect(_ colorSelector: MyUISegmentedColorSelector,
                                               colorAt index: Int)
}

@IBDesignable
class MyUISegmentedColorSelector: UIControl, MyUIHorizontalTableDelegate {

    @IBOutlet weak var root: MyUIHorizontalTable!

    var colors: [UIColor] = [] {
        didSet {
            root.dataSource = ColorsListDataSource(colors:colors)
        }
    }

    var selectedIndex: Int {
        get {
            return root.selectedIndex
        }
        set {
            root.selectedIndex = newValue
        }
    }

    var delegate: MyUISegmentedColorSelectorDelegate?

    required override init(frame: CGRect) {
        super.init(frame: frame)
        loadSubviewFromXib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadSubviewFromXib()
    }

    internal func tableDidSelect(_ table: MyUIHorizontalTable, itemAt index: Int) {
        delegate?.colorSelectorDidSelect?(self, colorAt: index)
    }
}
