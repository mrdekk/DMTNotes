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

    let serviceLocator = AppDelegate.sharedInstance.serviceLocator!

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
        if textEditingFrame != nil {
            if !visibleRect.contains(textEditingFrame!.origin) {
                scrollView.scrollRectToVisible(textEditingFrame!, animated: true)
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
        if textEditingControl?.selectedTextRange != nil {
            let a = textEditingControl!.caretRect(for: textEditingControl!.selectedTextRange!.start)
            let c = self.scrollView.convert(a, from: textEditingControl as? UIView)
            return c
        }
        return nil
    }

    @IBAction
    private func deleteTapped(_ sender: Any) {
        let alert = UIAlertController.init(
            title: "Delete",
            message: "Are you sure?",
            preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { act in
            self.deleteConfirmed()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

    private func deleteConfirmed() {
        if noteId != nil {
            serviceLocator.dataService.removeNote(noteId: noteId!)
        }

        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction
    private func saveTapped(_ sender: Any) {
        // copy data from cotrols into dataObject
        dataItem?.colorId = colorSelector.selectedIndex
        dataItem?.color = colorSelector.colors[colorSelector.selectedIndex].toHexRgbString()
        dataItem?.desc = descriptionField.text
        dataItem?.title = titleField.text

        if noteId == nil {
            serviceLocator.dataService.addNote(note: dataItem!)
        } else {
            serviceLocator.dataService.updateNote(noteId: noteId!, note: dataItem!)
        }

        _ = self.navigationController?.popViewController(animated: true)
    }

    func openAsNew() {
        self.noteId = nil

        let n = Note()
        n.colorId = 0
        let ts = Date().description(with: Locale.current)
        n.title = "Note " + ts
        n.desc = "Note created at " + ts
        self.dataItem = n
    }

    func openAsEdit(noteId: Int) {
        self.noteId = noteId

        if let note = serviceLocator.dataService.getNote(noteId: noteId) {
            dataItem = note
        } else {
            // TODO handle error. Should we show an error message to the user?
        }
    }

    private var noteId: Int?

    private var dataItem: Note? {
        didSet {
            self.configureView()
        }
    }

    private func configureView() {
        if titleField == nil ||
            descriptionField == nil ||
            colorSelector == nil {
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
