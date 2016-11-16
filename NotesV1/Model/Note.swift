//
//  Note.swift
//  NotesV1
//
//  Created by Dmitry Galimzyanov on 11.11.16.
//  Copyright © 2016 Dmitry Galimzyanov. All rights reserved.
//

import Foundation

class Note: NSObject {
    // swiftlint:disable variable_name
    var id: String
    // swiftlint:enable variable_name
    
    var order: Int = 0
    var title: String?
    var desc: String?
    var color: String?
    var colorId: Int = 0
    
    override init() {
        id = UUID.init().uuidString
        super.init()
    }
    
    init(from dbNote: DbNote) {
        id = dbNote.id! // data contract: id can't be nil
        color = dbNote.color
        colorId = Int(dbNote.colorId)
        desc = dbNote.desc
        order = Int(dbNote.order)
        title = dbNote.title
        super.init()
    }
}

extension Note {
    func copyToDbNote(dbNote: DbNote) {
        dbNote.id = self.id
        dbNote.color = self.color
        dbNote.colorId = Int32(self.colorId)
        dbNote.desc = self.desc
        dbNote.order = Int32(self.order)
        dbNote.title = self.title
    }
}
