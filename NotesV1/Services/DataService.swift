//
//  DataService.swift
//  NotesV1
//
//  Created by Dmitry Galimzyanov on 09.11.16.
//  Copyright © 2016 Dmitry Galimzyanov. All rights reserved.
//

import Foundation
import CoreData

class CoreDataBasedDataService: NSObject, DataServiceProtocol {
    
    var dbService: CoreDataContainer!
    
    private lazy var dbCtx: NSManagedObjectContext = {
        return self.dbService.newBackgroundContext()
    }()
    
    override init() {
        super.init()
    }
        
    func getNotesCount(_ completion: ((Int?) -> ())?) {
        self.dbCtx.perform {
            [weak self] in
            guard let sself = self else {
                completion?(nil)
                return
            }
            
            let ctx = sself.dbCtx
            
            let fetchRequest = NSFetchRequest<DbNote>(entityName: "DbNote")
            
            guard let count = try? ctx.count(for: fetchRequest)
                else {
                    completion?(nil)
                    return
            }
            
            completion?(count)
        }
    }
    
    func getNotes(_ completion: (([Note]?) -> ())?) {
        self.dbCtx.perform {
            [weak self] in
            guard let sself = self else {
                completion?(nil)
                return
            }
            
            let ctx = sself.dbCtx
            
            let fetchRequest = NSFetchRequest<DbNote>(entityName: "DbNote")
            
            guard let dbNotes = try? ctx.fetch(fetchRequest)
                else {
                    completion?(nil)
                    return
            }
            
            let notes = dbNotes.map({
                dbNote in Note(from: dbNote)
            })
            
            completion?(notes)
        }
    }
    
    func getNote(noteId: String, _ completion: ((Note?) -> ())?) {
        self.dbCtx.perform {
            [weak self] in
            //Thread.sleep(forTimeInterval: 3)
            guard let sself = self else {
                completion?(nil)
                return
            }
            
            let ctx = sself.dbCtx
            
            let fetchRequest = NSFetchRequest<DbNote>(entityName: "DbNote")
            fetchRequest.predicate = NSPredicate(format: "id == %@", noteId)
            
            guard let dbNote = (try? ctx.fetch(fetchRequest))?.first else {
                completion?(nil)
                return
            }
            
            let note = Note(from: dbNote)
            
            completion?(note)
        }
    }
    
    func addNote(note: Note, _ completion: ((Bool) -> (Swift.Void))?) {
        self.dbCtx.perform {
            [weak self] in
            //Thread.sleep(forTimeInterval: 3)
            guard let sself = self else {
                completion?(false)
                return
            }
            
            guard let dbNoteEntityDescription = NSEntityDescription.entity(forEntityName: "DbNote", in: sself.dbCtx)
                else {
                    completion?(false)
                    return
            }
            
            let newDbNote = DbNote(entity: dbNoteEntityDescription, insertInto: sself.dbCtx)
            note.copyToDbNote(dbNote: newDbNote)
            
            guard (try? sself.dbCtx.save()) != nil else {
                completion?(false)
                return
            }
            
            completion?(true)
        }
    }
    
    func updateNote(noteId: String, note: Note, _ completion: ((Bool) -> (Swift.Void))?) {
        self.dbCtx.perform {
            [weak self] in
            //Thread.sleep(forTimeInterval: 3)
            guard let sself = self else {
                completion?(false)
                return
            }
            
            let ctx = sself.dbCtx
            
            let fetchRequest = NSFetchRequest<DbNote>(entityName: "DbNote")
            fetchRequest.predicate = NSPredicate(format: "id == %@", noteId)
            
            guard let dbNote = (try? ctx.fetch(fetchRequest))?.first else {
                completion?(false)
                return
            }
            
            note.copyToDbNote(dbNote: dbNote)
            
            guard (try? ctx.save()) != nil else {
                completion?(false)
                return
            }
            
            completion?(true)
        }
    }
    
    func removeNote(noteId: String, _ completion: ((Bool) -> (Swift.Void))?) {
        self.dbCtx.perform {
            [weak self] in
            //Thread.sleep(forTimeInterval: 3)
            guard let sself = self else {
                completion?(false)
                return
            }
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DbNote")
            fetchRequest.includesPropertyValues = false
            fetchRequest.predicate = NSPredicate(format: "id == %@", noteId)
            
            guard (try? sself.dbCtx.execute(NSBatchDeleteRequest(fetchRequest: fetchRequest))) != nil
                else {
                    completion?(false)
                    return
            }
            
            completion?(true)
        }
    }
}
