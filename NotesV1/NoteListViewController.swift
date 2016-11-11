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
