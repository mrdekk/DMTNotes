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
    //private var prefetchedNotes: [Note]?
    
    override init() {
        dataService = serviceLocator.dataService
        super.init()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return dataService.getNotesCount()
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoteListCell", for: indexPath)
            if let cell = cell as? NoteListViewCell {
                guard let note = dataService.getNote(noteId: indexPath.row)
                    else {
                        return cell
                }
                
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
