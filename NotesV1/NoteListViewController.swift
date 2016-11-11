//
//  ViewController.swift
//  NotesV1
//
//  Created by Dmitry Galimzyanov on 01.11.16.
//  Copyright © 2016 Dmitry Galimzyanov. All rights reserved.
//

import UIKit

class NoteListViewController: UIViewController {

    private let serviceLocator = AppDelegate.shared.serviceLocator!

    @IBOutlet weak var tableView: UITableView!
    private var notesListGeneration: Int = 0
    private let notesListDataSource: NoteListDataSource = NoteListDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        tableView.dataSource = notesListDataSource
        tableView.delegate = notesListDataSource
    }
    
    var selectedNoteId: Int?
    var noteObjectToEdit: Note?
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "addNewNote" {
            selectedNoteId = nil
            noteObjectToEdit = nil
        } else if identifier == "editNote" {
            guard let selectedNoteIndex = self.tableView.indexPathForSelectedRow?.row
                else {
                    return false
            }
            
            guard let note = serviceLocator.dataService.getNote(noteId: selectedNoteIndex)
                else {
                    let alert = UIAlertController(
                        title: "We are sorry",
                        message: "The note is unavailable or was removed",
                        preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default)
                    alert.addAction(okAction)
                    self.present(alert, animated: true)
                    
                    return false
            }
            
            selectedNoteId = selectedNoteIndex
            noteObjectToEdit = note
        }
        return super.shouldPerformSegue(withIdentifier: identifier, sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addNewNote" ||
           segue.identifier == "editNote" {
            guard let destController = segue.destination as? NoteDetailViewController
                else {
                    print("Can't cast segue.destination as NoteDetailViewController")
                    return
            }
            destController.dataObjectUpdated = noteUpdated
            destController.openWithObject(noteObjectToEdit)
        }
    }
    
    private func noteUpdated(_ note: Note?) {
        let ds = serviceLocator.dataService
        if let noteId = selectedNoteId {
            if let note = note {
                ds.updateNote(noteId: noteId, note: note)
                tableView.reloadRows(at: [IndexPath(row: noteId, section: 0)], with: .automatic)
            } else {
                ds.removeNote(noteId: noteId)
                tableView.deleteRows(at: [IndexPath(row: noteId, section: 0)], with: .automatic)
            }
        } else {
            guard let note = note else { return }
            
            let newNoteId = ds.addNote(note: note)
            
            tableView.insertRows(at: [IndexPath(row: newNoteId, section: 0)], with: .automatic)
        }
    }
}

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
