//
//  DataServiceProtocol.swift
//  NotesV1
//
//  Created by Dmitry Galimzyanov on 11.11.16.
//  Copyright © 2016 Dmitry Galimzyanov. All rights reserved.
//

import Foundation


protocol DataServiceProtocol : class, NSObjectProtocol {
    func getNotesGeneration() -> Int
    func getNotes() -> [Note]
    func getNote(noteId: Int) -> Note?
    func addNote(note: Note)
    func removeNote(noteId: Int)
    func updateNote(noteId: Int, note: Note)
}
