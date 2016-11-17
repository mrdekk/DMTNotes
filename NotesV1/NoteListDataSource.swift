//
//  NoteListDataSource.swift
//  NotesV1
//
//  Created by Dmitry Galimzyanov on 11.11.16.
//  Copyright © 2016 Dmitry Galimzyanov. All rights reserved.
//

import UIKit

class NoteListDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    private let serviceLocator = AppDelegate.shared.serviceLocator!
    private let dataService: DataServiceProtocol
    private var fetchedItems: [Note] = []
    private var indexPathsDictionary: [String: IndexPath] = [:]
    
    override init() {
        dataService = serviceLocator.dataService
        super.init()
    }
    
    private func getIndexPath(byNoteId: String) -> IndexPath? {
        return indexPathsDictionary[byNoteId]
    }
    
    func getNoteBy(indexPath: IndexPath) -> Note? {
        return fetchedItems[indexPath.row]
    }
    
    func addNote(note: Note, _ completion: ((IndexPath?) -> ())?) {
        dataService.addNote(note: note) {
            [weak self]
            isSuccess in
            guard isSuccess else {
                completion?(nil)
                return
            }
            
            guard let sself = self else {
                completion?(nil)
                return
            }
            
            // add to internal
            let index = sself.fetchedItems.count
            sself.fetchedItems.append(note)
            let indexPath = IndexPath(row: index, section: 0)
            sself.indexPathsDictionary[note.id] = indexPath
            
            completion?(indexPath)
        }
    }
    
    func updateNote(noteId: String, note: Note, _ completion: ((IndexPath?) -> ())?) {
        dataService.updateNote(noteId: noteId, note: note) {
            [weak self]
            isSuccess in
            guard isSuccess else {
                completion?(nil)
                return
            }
            
            guard let sself = self else {
                completion?(nil)
                return
            }
            
            guard let indexPath = sself.getIndexPath(byNoteId: noteId) else {
                completion?(nil)
                return
            }
            
            let index = indexPath.row
            sself.fetchedItems[index] = note
            
            completion?(indexPath)
        }
    }
    
    func removeNote(noteId: String, _ completion: ((IndexPath?) -> ())?) {
        dataService.removeNote(noteId: noteId) {
            [weak self]
            isSuccess in
            guard isSuccess else {
                completion?(nil)
                return
            }
            
            guard let sself = self else {
                completion?(nil)
                return
            }
            
            guard let indexPath = sself.getIndexPath(byNoteId: noteId) else {
                completion?(nil)
                return
            }
            
            let index = indexPath.row
            sself.fetchedItems.remove(at: index)
            sself.indexPathsDictionary.removeValue(forKey: noteId)
            
            completion?(indexPath)
        }
    }
    
    // important!: completion closure will be invoked on background queue
    func fetch(_ completion: ((Bool) -> ())?) {
        dataService.getNotes {
            [weak self]
            notes in
            guard let sself = self else {
                completion?(false)
                return
            }
            
            guard let notes = notes else {
                completion?(false)
                return
            }
            
            sself.fetchedItems.removeAll()
            sself.fetchedItems.append(contentsOf: notes)
            
            // build dictionary for note_id -> IndexPath
            sself.indexPathsDictionary.removeAll()
            for i in 0..<notes.count {
                let note = notes[i]
                let noteId = note.id
                let indexPath = IndexPath(row: i, section: 0)
                sself.indexPathsDictionary[noteId] = indexPath
            }
            
            completion?(true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return fetchedItems.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoteListCell", for: indexPath)
            if let cell = cell as? NoteListViewCell {
                let row = indexPath.row
                guard row >= 0 && row < fetchedItems.count else {
                    return cell
                }
                
                let note = fetchedItems[indexPath.row]
                
                cell.title = note.title
                cell.descriptionText = note.desc
                cell.backgroundColor = serviceLocator.defaultSettings.availableNoteColors[note.colorId]
            }
            return cell
        }
        return tableView.dequeueReusableCell(withIdentifier: "AddCell", for: indexPath)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}
