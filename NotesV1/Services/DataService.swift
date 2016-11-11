//
//  DataService.swift
//  NotesV1
//
//  Created by Dmitry Galimzyanov on 09.11.16.
//  Copyright © 2016 Dmitry Galimzyanov. All rights reserved.
//

import Foundation

class DumbDataService: NSObject, DataServiceProtocol {
    private var backingStorage: [Note] = []

    override init() {
        super.init()
        createTestNotes()
    }

    private func createTestNotes() {
        let count = 15
        for i in 0..<count {
            let note = Note()
            note.order = i
            note.title = "Note \(i)"
            note.desc = "This is a note. Id = \(i)"
            note.colorId = i % 13

            backingStorage.append(note)
        }
    }
    
    func getNotesCount() -> Int {
        return backingStorage.count
    }

    func getNotes() -> [Note] {
        return backingStorage
    }

    func getNote(noteId: Int) -> Note? {
        if noteId >= 0 && noteId < backingStorage.count {
            return backingStorage[noteId]
        }
        return nil
    }

    func addNote(note: Note) -> Int {
        let id = backingStorage.count
        backingStorage += [note]
        return id
    }

    func updateNote(noteId: Int, note: Note) {
        if noteId >= 0 && noteId < backingStorage.count {
            backingStorage[noteId] = note
        }
    }

    func removeNote(noteId: Int) {
        if noteId >= 0 && noteId < backingStorage.count {
            backingStorage.remove(at: noteId)
        }
    }
}
