//
//  ColorsListDataSource.swift
//  NotesV1
//
//  Created by Dmitry Galimzyanov on 11.11.16.
//  Copyright © 2016 Dmitry Galimzyanov. All rights reserved.
//

import UIKit

@objc
class ColorsListDataSource: NSObject, MyUIHorizontalTableDataSource {
    
    let colors: [UIColor]
    
    init(colors: [UIColor]) {
        self.colors = colors
    }
    
    func numberOfRows(_ table: MyUIHorizontalTable) -> Int {
        return colors.count
    }
    
    func cell(_ table: MyUIHorizontalTable, forRowAt index: Int) -> MyUIHorizontalTableCell {
        if let cell = table.cell(for: index) as? MyUISegmentedColorSelectorSegment {
            cell.color = colors[index]
            return cell
        }
        return MyUIHorizontalTableCell()
    }
}

@objc
class RandomColorsListDataSource: NSObject, MyUIHorizontalTableDataSource {
    
    func numberOfRows(_ table: MyUIHorizontalTable) -> Int {
        return 30
    }
    func cell(_ table: MyUIHorizontalTable, forRowAt index: Int) -> MyUIHorizontalTableCell {
        if let cell = table.cell(for: index) as? MyUISegmentedColorSelectorSegment {
            cell.color = UIColor(hue: CGFloat(drand48()), saturation: 0.6, brightness: 1, alpha: 1)
            return cell
        }
        return MyUIHorizontalTableCell()
    }
}
