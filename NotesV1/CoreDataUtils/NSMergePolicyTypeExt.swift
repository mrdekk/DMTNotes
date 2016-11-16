//
//  NSMergePolicyTypeExt.swift
//  NotesV1
//
//  Created by Dmitry Galimzyanov on 14.11.16.
//  Copyright © 2016 Dmitry Galimzyanov. All rights reserved.
//

import Foundation
import CoreData

extension NSMergePolicyType {
    func asMergePolicyObject() -> AnyObject {
        switch self {
        case .errorMergePolicyType:
            return NSErrorMergePolicy
            
        case .mergeByPropertyStoreTrumpMergePolicyType:
            return NSMergeByPropertyStoreTrumpMergePolicy
            
        case .mergeByPropertyObjectTrumpMergePolicyType:
            return NSMergeByPropertyObjectTrumpMergePolicy
            
        case .overwriteMergePolicyType:
            return NSOverwriteMergePolicy
            
        case .rollbackMergePolicyType:
            return NSRollbackMergePolicy
        }
    }
}
