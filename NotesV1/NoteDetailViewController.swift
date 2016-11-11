//
//  NoteDetailViewController.swift
//  NotesV1
//
//  Created by Dmitry Galimzyanov on 01.11.16.
//  Copyright © 2016 Dmitry Galimzyanov. All rights reserved.
//

import UIKit

class NoteDetailViewController: UIViewController, UITextViewDelegate,
    MyUISegmentedColorSelectorDelegate {

    let serviceLocator = AppDelegate.shared.serviceLocator!

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var colorSelector: MyUISegmentedColorSelector!

    // delete button ref must be strong so we can add or remove it to/from navbar
    @IBOutlet var deleteButton: UIBarButtonItem!

    // save button ref must be strong so we can add or remove it to/from navbar
    @IBOutlet var saveButton: UIBarButtonItem!

    @IBOutlet weak var scrollView: UIScrollView!

    var textEditingControl: UITextInput? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        colorSelector.colors = serviceLocator.defaultSettings.availableNoteColors
        colorSelector.delegate = self

        descriptionField.delegate = self

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(NoteDetailViewController.keyboardWillShow(notification:)),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(NoteDetailViewController.keyboardWillHide(notification:)),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil)

        configureView()
    }

    internal func colorSelectorDidSelect(_ colorSelector: MyUISegmentedColorSelector,
                                         colorAt index: Int) {
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc
    private func keyboardWillShow(notification: NSNotification) {
        guard let value = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue
            else { return }
        let keyboardFrame = self.view.convert(value.cgRectValue, from: nil)

        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0,
                                         bottom: keyboardFrame.height, right: 0.0)

        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets

        // scroll to active field if it's hidden by kb
        var visibleRect = self.view.frame
        visibleRect.size.height -= keyboardFrame.height
        let textEditingFrame = getTextEditingFrame()
        if let textEditingFrame = textEditingFrame {
            if !visibleRect.contains(textEditingFrame.origin) {
                scrollView.scrollRectToVisible(textEditingFrame, animated: true)
            }
        }
    }

    @objc
    private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }

    // Handles text editing on text field
    @IBAction private func textFieldDidBeginEditing(_ sender: Any) {
        if let senderAsTextField = sender as? UITextField {
            textEditingControl = senderAsTextField
        }
    }

    @IBAction private func textFieldDidEndEditing(_ sender: Any) {
        textEditingControl = nil
    }

    // Handles text editing on text view
    internal func textViewDidBeginEditing(_ textView: UITextView) {
        textEditingControl = textView
    }

    internal func textViewDidEndEditing(_ textView: UITextView) {
        textEditingControl = nil
    }

    private func getTextEditingFrame() -> CGRect? {
        guard
            let control = textEditingControl,
            let range = control.selectedTextRange
            else {
            return nil
        }
        
        let caretRect = control.caretRect(for: range.start)
        let caretRectConverted = self.scrollView.convert(caretRect, from: textEditingControl as? UIView)
        return caretRectConverted
    }

    @IBAction
    private func deleteTapped(_ sender: Any) {
        let alert = UIAlertController.init(
            title: "Delete",
            message: "Are you sure?",
            preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {
            [weak self]
            act in
            guard let sself = self else { return } // sself - strong self
            sself.deleteConfirmed()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

    private func deleteConfirmed() {
        if let noteId = noteId {
            serviceLocator.dataService.removeNote(noteId: noteId)
        }

        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction
    private func saveTapped(_ sender: Any) {
        if let item = dataItem {
            // copy data from cotrols into dataObject
            item.colorId = colorSelector.selectedIndex
            item.color = colorSelector.colors[colorSelector.selectedIndex].toHexRgbString()
            item.desc = descriptionField.text
            item.title = titleField.text
            
            if let noteId = noteId {
                serviceLocator.dataService.updateNote(noteId: noteId, note: dataItem!)
            } else {
                serviceLocator.dataService.addNote(note: dataItem!)
            }
        }

        _ = self.navigationController?.popViewController(animated: true)
    }

    func openAsNew() {
        self.noteId = nil

        let n = Note()
        n.colorId = 0
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        let ts = dateFormatter.string(from: Date())
        n.title = "Note " + ts
        n.desc = "Note created at " + ts
        self.dataItem = n
    }

    func openAsEdit(noteId: Int) -> Bool {
        // TODO move this logic to parent VC
        self.noteId = noteId

        guard let note = serviceLocator.dataService.getNote(noteId: noteId)
            else {
            return false
        }
        
        dataItem = note
        
        return true
    }

    private var noteId: Int?

    private var dataItem: Note? {
        didSet {
            self.configureView()
        }
    }

    private func configureView() {
        guard
            titleField != nil,
            descriptionField != nil,
            colorSelector != nil
            else {
            return
        }

        if noteId == nil {
            // hide delete button
            self.navigationItem.setRightBarButtonItems([saveButton], animated: false)
        } else {
            // show delete button
            self.navigationItem.setRightBarButtonItems([deleteButton, saveButton], animated: false)
        }

        if let data = dataItem {
            titleField.text = data.title
            descriptionField.text = data.desc ?? ""
            colorSelector.selectedIndex = Int(data.colorId)
        }
    }
}
