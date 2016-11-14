//
//  MyUIHorizontalTableCell.swift
//  NotesV1
//
//  Created by Dmitry Galimzyanov on 09.11.16.
//  Copyright © 2016 Dmitry Galimzyanov. All rights reserved.
//

import UIKit

@objc
protocol MyUIHorizontalTableCellDelegate {
    @objc optional func didTap(_ cell: MyUIHorizontalTableCell)
}

@IBDesignable
class MyUIHorizontalTableCell: UIView, UIGestureRecognizerDelegate {
    private var defaultColor: UIColor?
    private var tapRecognizer: UITapGestureRecognizer!

    // get or set selected state
    @IBInspectable
    var isSelected: Bool {
        didSet {
            if isSelected {
                self.backgroundColor = self.tintColor
            } else {
                self.backgroundColor = self.defaultColor
            }
        }
    }

    var index: Int = 0

    var delegate: MyUIHorizontalTableCellDelegate?

    required init?(coder aDecoder: NSCoder) {
        isSelected = false
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect) {
        isSelected = false
        super.init(frame: frame)
        commonInit()
    }

    private func commonInit() {
        defaultColor = self.backgroundColor

        tapRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(tapRecognizerAction))
        tapRecognizer.delegate = self
        self.addGestureRecognizer(tapRecognizer)
    }

    @objc
    private func tapRecognizerAction() {
        if let delegate = delegate {
            delegate.didTap?(self)
        }
    }
}
