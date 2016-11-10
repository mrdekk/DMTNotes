//
//  DataService.swift
//  NotesV1
//
//  Created by Dmitry Galimzyanov on 09.11.16.
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

protocol IDataService : class, NSObjectProtocol {
    func getNotesGeneration() -> Int
    func getNotes() -> [Note]
    func getNote(noteId: Int) -> Note?
    func addNote(note: Note)
    func removeNote(noteId: Int)
    func updateNote(noteId: Int, note: Note)
}

class DumbDataService: NSObject, IDataService {
    private var backingStorage: [Note] = []

    override init() {
        super.init()
        createTestNotes()
    }

    private var notesListGen: Int = 0

    func getNotesGeneration() -> Int {
        return notesListGen
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
        notesListGen += 1
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

    func addNote(note: Note) {
        backingStorage += [note]
        notesListGen += 1
    }

    func updateNote(noteId: Int, note: Note) {
        if noteId >= 0 && noteId < backingStorage.count {
            backingStorage[noteId] = note
            notesListGen += 1
        }
    }

    func removeNote(noteId: Int) {
        if noteId >= 0 && noteId < backingStorage.count {
            backingStorage.remove(at: noteId)
            notesListGen += 1
        }
    }
}
