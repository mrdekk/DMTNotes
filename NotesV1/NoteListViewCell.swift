//
//  NoteListViewCell.swift
//  NotesV1
//
//  Created by Dmitry Galimzyanov on 11.11.16.
//  Copyright © 2016 Dmitry Galimzyanov. All rights reserved.
//

import UIKit

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
