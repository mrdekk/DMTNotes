//
//  Note.swift
//  NotesV1
//
//  Created by Dmitry Galimzyanov on 11.11.16.
//  Copyright © 2016 Dmitry Galimzyanov. All rights reserved.
//

import Foundation

class Note: NSObject {
    var order: Int = 0
    var title: String?
    var desc: String?
    var color: String?
    var colorId: Int = 0
}
