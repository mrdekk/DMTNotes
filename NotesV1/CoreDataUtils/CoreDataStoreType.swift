//
//  CoreDataStoreType.swift
//  NotesV1
//
//  Created by Dmitry Galimzyanov on 14.11.16.
//  Copyright © 2016 Dmitry Galimzyanov. All rights reserved.
//

import Foundation
import CoreData

enum CoreDataStoreType {
    case SQLite
    //case Xml
    case InMemory
    case Binary
    
    public func asString() -> String {
        switch self {
        case .SQLite:
            return NSSQLiteStoreType
        case .Binary:
            return NSBinaryStoreType
        case .InMemory:
            return NSInMemoryStoreType
        }
    }
}
