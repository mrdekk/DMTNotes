//
//  CoreDataContainer.swift
//  NotesV1
//
//  Created by Dmitry Galimzyanov on 14.11.16.
//  Copyright © 2016 Dmitry Galimzyanov. All rights reserved.
//

import Foundation
import CoreData

class CoreDataContainer: NSObject {
    
    private var storeType: CoreDataStoreType = CoreDataStoreType.SQLite
    private var name: String
    private var model: NSManagedObjectModel
    private var persistentStoreCoordinator: NSPersistentStoreCoordinator
    
    private(set) var viewContext: NSManagedObjectContext
    
    private var rootSaveContext: NSManagedObjectContext
    
    init(name: String) {
        self.name = name
        
        if let model = CoreDataContainer.getModel(by: name) {
            self.model = model
        } else {
            fatalError()
        }
        
        if let coordinator = CoreDataContainer.createPersistentStoreCoordinator(forModel: model,
                                                                             name: name,
                                                                             type: storeType) {
            self.persistentStoreCoordinator = coordinator
        } else {
            fatalError()
        }
        
        self.rootSaveContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.rootSaveContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        self.rootSaveContext.mergePolicy =
            NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType.asMergePolicyObject()
        
        self.viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.viewContext.parent = self.rootSaveContext
        self.viewContext.mergePolicy = NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType.asMergePolicyObject()
        
        super.init()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CoreDataContainer.managedObjectContextDidSave(_:)),
                                               name: .NSManagedObjectContextDidSave,
                                               object: self.rootSaveContext)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CoreDataContainer.managedObjectContextDidSave(_:)),
                                               name: .NSManagedObjectContextDidSave,
                                               object: self.viewContext)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .NSManagedObjectContextDidSave, object: nil)
    }
    
    private static func getModel(by name: String) -> NSManagedObjectModel? {
        let bundle = Bundle.main
        
        for ext in ["momd", "mom"] {
            if let url = bundle.url(forResource: name, withExtension: ext) {
                return NSManagedObjectModel(contentsOf: url)
            }
        }
        
        return nil
    }
    
    private static func createPersistentStoreCoordinator(forModel: NSManagedObjectModel,
                                                      name: String,
                                                      type: CoreDataStoreType
                                                      ) -> NSPersistentStoreCoordinator? {
        let psc = NSPersistentStoreCoordinator(managedObjectModel: forModel)
        
        if type == .SQLite {
            // SQLite
            let fileName = name + ".sqlite"
            guard let defaultDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
                else {
                    print("Can't get default directory for DB")
                    return nil
            }
            let storeUrl = defaultDirectory.appendingPathComponent(fileName)
            let options = [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true]
            
            do {
                try psc.addPersistentStore(ofType: type.asString(),
                                       configurationName: nil, // "PF_DEFAULT_CONFIGURATION_NAME"
                                       at: storeUrl,
                                       options: options)
            } catch {
                return nil
            }
        } else {
            print("Store type \(type) is not implemented")
            // return nil
        }
        
        return psc
    }
    
    internal func managedObjectContextDidSave(_ notification: Notification) {
        if let ctx = notification.object as? NSManagedObjectContext {
            if ctx == rootSaveContext {
                // ignore
            } else if ctx == viewContext {
                rootSaveContext.perform {
                    do {
                        try self.rootSaveContext.save()
                    } catch let e {
                        print(e)
                    }
                }
            } else {
                // background ctx
                
                if Thread.isMainThread {
                    //fatalError("CoreDataContainer - Background context has been saved in the main thread")
                }
                
                viewContext.perform {
                    do {
                        try self.viewContext.save()
                    } catch let e {
                        print(e)
                    }
                }
            }
        }
    }
    
    public func newBackgroundContext() -> NSManagedObjectContext {
        let ctx = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        ctx.parent = viewContext
        ctx.mergePolicy = NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType.asMergePolicyObject()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CoreDataContainer.managedObjectContextDidSave(_:)),
                                               name: .NSManagedObjectContextDidSave,
                                               object: ctx)
        
        return ctx
    }
    
    public func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Swift.Void) {
        let ctx = newBackgroundContext()
        ctx.perform {
            block(ctx)
        }
    }
    
    public func performAndWaitBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Swift.Void) {
        let ctx = newBackgroundContext()
        ctx.performAndWait {
            block(ctx)
        }
    }
}
