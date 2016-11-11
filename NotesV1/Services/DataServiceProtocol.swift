//
//  DataServiceProtocol.swift
//  NotesV1
//
//  Created by Dmitry Galimzyanov on 11.11.16.
//  Copyright © 2016 Dmitry Galimzyanov. All rights reserved.
//

import Foundation

protocol DataServiceProtocol : class, NSObjectProtocol {
    func getNotes() -> [Note]
    func getNotesCount() -> Int
    func getNote(noteId: Int) -> Note?
    func addNote(note: Note) -> Int
    func removeNote(noteId: Int)
    func updateNote(noteId: Int, note: Note)
}
