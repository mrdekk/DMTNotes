//
//  MyUIHorizontalTable.swift
//  NotesV1
//
//  Created by Dmitry Galimzyanov on 04.11.16.
//  Copyright © 2016 Dmitry Galimzyanov. All rights reserved.
//

import UIKit

@objc
protocol MyUIHorizontalTableDataSource : class, NSObjectProtocol {
    @objc func cell(_ table: MyUIHorizontalTable, forRowAt index: Int) -> MyUIHorizontalTableCell

    @objc func numberOfRows(_ table: MyUIHorizontalTable) -> Int
}

@objc
protocol MyUIHorizontalTableDelegate :class, NSObjectProtocol {
    @objc optional func tableDidSelect(_ table: MyUIHorizontalTable, itemAt index: Int)
}

enum MyUIHorizontalTableError: Error {
    case CellTypeError()
}

@IBDesignable
class MyUIHorizontalTable: UIView, MyUIHorizontalTableCellDelegate {
    @IBInspectable
    var cellType: String! {
        didSet {
            tryConfigureTable()
        }
    }

    @IBInspectable
    var spacing: CGFloat {
        get {
            return stack.spacing
        }
        set {
            stack.spacing = newValue
        }
    }

    @IBOutlet
    private weak var root: UIScrollView!

    @IBOutlet
    private weak var stack: UIStackView!

    /// Workaround for Xcode bug that prevents you from connecting the delegate in the storyboard.
    /// Remove this extra property once Xcode gets fixed.
    @IBOutlet
    weak var dataSource: AnyObject? {
        get {
            return dataSourceTyped
        }
        set {
            dataSourceTyped = newValue as? MyUIHorizontalTableDataSource
        }
    }

    weak var dataSourceTyped: MyUIHorizontalTableDataSource? {
        didSet {
            tryConfigureTable()
        }
    }

    /// Workaround for Xcode bug that prevents you from connecting the delegate in the storyboard.
    /// Remove this extra property once Xcode gets fixed.
    @IBOutlet
    weak var delegate: AnyObject? {
        get {
            return delegateTyped
        }
        set {
            delegateTyped = newValue as? MyUIHorizontalTableDelegate
        }
    }

    weak var delegateTyped: MyUIHorizontalTableDelegate? {
        didSet {
            tryConfigureTable()
        }
    }

    var cellClass: MyUIHorizontalTableCell.Type? = nil

    var cellViews: [MyUIHorizontalTableCell] = []

    var selectedIndex: Int {
        didSet {
            if oldValue != -1 {
                let cell = cellViews[oldValue]
                cell.isSelected = false
            }
            if selectedIndex != -1 {
                let cell = cellViews[selectedIndex]
                cell.isSelected = true
            }
            delegateTyped?.tableDidSelect?(self, itemAt: selectedIndex)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        selectedIndex = -1
        super.init(coder: aDecoder)
        //dataSource = aDecoder.decodeObject(forKey: "dataSource") as? MyUIHorizontalTableDataSource
        loadSubviewFromXib()
        root.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        root.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        root.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        root.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
    }

    override init(frame: CGRect) {
        selectedIndex = -1
        super.init(frame: frame)
        loadSubviewFromXib()
        //root.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        //root.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        //root.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        //root.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        root.setNeedsLayout()
    }

    func tryConfigureTable() {
        do {
            if cellType == nil ||
                dataSource == nil {
                return
            }
            try initCells()
            fillCells()
        } catch {
            // TODO
        }
    }

    func initCells() throws {
        if cellType == nil { throw NSError() }

        guard let declaredCellType =
            NSClassFromString(cellType) as? MyUIHorizontalTableCell.Type else {
            throw MyUIHorizontalTableError.CellTypeError()
        }

        self.cellClass = declaredCellType
    }

    func fillCells() {
        if dataSource != nil {
            //let section = 0 // TODO get support for multiple sections
            let rowsCount = dataSourceTyped!.numberOfRows(self)
            for r in 0..<rowsCount {
                let cell = createCell()
                if cell != nil {
                    cell?.index = r
                    cellViews.append(cell!)
                }
            }

            self.stack.subviews.forEach({ v in v.removeFromSuperview() })
            for r in 0..<rowsCount {
                let cell = dataSource?.cell(self, forRowAt: r)
                if cell != nil {
                    self.stack.addArrangedSubview(cell!)
                }
            }
        }
    }

    // cell factory
    func createCell() -> MyUIHorizontalTableCell? {
        if cellClass != nil {
            let cell = cellClass!.init()
            cell.delegate = self
            return cell
            //return cellClass!.init(frame: CGRect(x: 0, y: 0, width: 30, height: 30 ))
        }
        return nil
    }

    func getCellForIndex(index: Int) -> MyUIHorizontalTableCell? {
        if index >= 0 && index < cellViews.count {
            return cellViews[index]
        }
        // TODO is exception would be better here?
        return nil
    }

    func cellTapped(_ cell: MyUIHorizontalTableCell) {
        let index = cell.index
        self.selectedIndex = index
    }
}
