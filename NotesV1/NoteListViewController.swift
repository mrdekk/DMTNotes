//
//  ViewController.swift
//  NotesV1
//
//  Created by Dmitry Galimzyanov on 01.11.16.
//  Copyright © 2016 Dmitry Galimzyanov. All rights reserved.
//

import UIKit

class NoteListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var notesListGeneration: Int = 0
    private let notesListDataSource: NoteListDataSource = NoteListDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        tableView.dataSource = notesListDataSource
        tableView.delegate = notesListDataSource
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addNewNote" {
            guard let destController = segue.destination as? NoteDetailViewController
                else {
                    print("Can't cast segue.destination as NoteDetailViewController")
                    return
            }
            destController.openAsNew()
        } else if segue.identifier == "editNote" {
            if let selectedNoteIndex = self.tableView.indexPathForSelectedRow?.row {
                guard let destController = segue.destination as? NoteDetailViewController
                    else {
                        print("Can't cast segue.destination as NoteDetailViewController")
                        return
                }
                destController.openAsEdit(noteId: selectedNoteIndex)
            } else {
                // TODO handle error
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        if notesListDataSource.checkNeedsUpdate() {
            tableView.reloadData()
        }
    }
}

class NoteListDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    private let serviceLocator = AppDelegate.sharedInstance.serviceLocator!
    private let dataService: IDataService
    private var gen: Int = -1
    private var prefetchedNotes: InvalidatableComputedValue<[Note]>!

    override init() {
        dataService = serviceLocator.dataService
        super.init()
        prefetchedNotes = InvalidatableComputedValue<[Note]>({
            self.gen = self.dataService.getNotesGeneration()
            return self.dataService.getNotes()
        })
        gen = dataService.getNotesGeneration()
    }

    func checkNeedsUpdate() -> Bool {
        let needsUpdate = gen < dataService.getNotesGeneration()
        if needsUpdate {
            // invalidate prefetched notes
            prefetchedNotes.invalidate()
        }
        return needsUpdate
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return prefetchedNotes.value.count
        }
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoteListCell", for: indexPath)
            let cell2 = cell as? NoteListViewCell

            let notes = prefetchedNotes.value
            let note = notes[indexPath.row]

            cell2?.title = note.title
            cell2?.descriptionText = note.desc
            cell2?.backgroundColor = serviceLocator.defaultSettings
                .availableNoteColors[note.colorId]

            return cell
        }
        return tableView.dequeueReusableCell(withIdentifier: "AddCell", for: indexPath)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}

class NoteListViewCell: UITableViewCell {
    @IBOutlet
    private weak var titleLabel: UILabel!

    @IBOutlet
    private weak var descriptionLabel: UILabel!

    var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }

    var descriptionText: String? {
        get {
            return descriptionLabel.text
        }
        set {
            descriptionLabel.text = newValue
        }
    }
}
