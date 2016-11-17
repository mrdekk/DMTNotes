//
//  DataServiceProtocol.swift
//  NotesV1
//
//  Created by Dmitry Galimzyanov on 11.11.16.
//  Copyright © 2016 Dmitry Galimzyanov. All rights reserved.
//

import Foundation

protocol DataServiceProtocol : class, NSObjectProtocol {
    func getNotes(_ completion: (([Note]?) -> ())?)
    func getNotesCount(_ completion: ((Int?) -> ())?)
    func getNote(noteId: String, _ completion: ((Note?) -> ())?)
    func addNote(note: Note, _ completion: ((Bool) -> (Swift.Void))?)
    func updateNote(noteId: String, note: Note, _ completion: ((Bool) -> (Swift.Void))?)
    func removeNote(noteId: String, _ completion: ((Bool) -> (Swift.Void))?)
}
