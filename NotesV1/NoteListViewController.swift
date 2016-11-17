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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let tableDataSource = tableView.dataSource as? NoteListDataSource {
            tableDataSource.fetch {
                [weak self]
                isSuccess in
                if !isSuccess {
                    return
                }
                DispatchQueue.main.async {
                    self?.tableView?.reloadData()
                }
            }
        }
    }
    
    var selectedNoteId: String?
    var noteObjectToEdit: Note?
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "addNewNote" {
            selectedNoteId = nil
            noteObjectToEdit = nil
        } else if identifier == "editNote" {
            guard let selectedNoteIndexPath = self.tableView.indexPathForSelectedRow
                else {
                    return false
            }
            
            guard let note = (self.tableView.dataSource as? NoteListDataSource)?
                .getNoteBy(indexPath: selectedNoteIndexPath)
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
            
            selectedNoteId = note.id
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
        guard let ds = self.tableView.dataSource as? NoteListDataSource else {
            return
        }
        if let noteId = selectedNoteId {
            if let note = note {
                ds.updateNote(noteId: noteId, note: note) {
                    [weak self]
                    updatedAtIndexPath in
                    guard let updatedAtIndexPath = updatedAtIndexPath else {
                        return
                    }
                    DispatchQueue.main.async {
                        self?.tableView?.reloadRows(at: [updatedAtIndexPath], with: .automatic)
                    }
                }
            } else {
                ds.removeNote(noteId: noteId) {
                    [weak self]
                    removedAtIndexPath in
                    guard let removedAtIndexPath = removedAtIndexPath else {
                        return
                    }
                    DispatchQueue.main.async {
                        self?.tableView?.deleteRows(at: [removedAtIndexPath], with: .automatic)
                    }
                }
            }
        } else {
            guard let note = note else { return }
            
            ds.addNote(note: note) {
                [weak self]
                addedAtIndexPath in
                guard let addedAtIndexPath = addedAtIndexPath else {
                    return
                }
                DispatchQueue.main.async {
                    self?.tableView?.insertRows(at: [addedAtIndexPath], with: .automatic)
                }
            }
        }
    }
}
