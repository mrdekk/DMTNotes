//
//  ServiceLocator.swift
//  NotesV1
//
//  Created by Dmitry Galimzyanov on 09.11.16.
//  Copyright © 2016 Dmitry Galimzyanov. All rights reserved.
//

import Foundation

protocol ServiceLocatorProtocol {
    var coreDataContainer: CoreDataContainer { get }
    var dataService: DataServiceProtocol { get }
    var defaultSettings: Settings { get }
}

class ServiceLocator: ServiceLocatorProtocol {
    var coreDataContainer: CoreDataContainer
    var dataService: DataServiceProtocol
    var defaultSettings: Settings
    
    init() {
        let dataSvc = CoreDataBasedDataService()
        let cdCont = CoreDataContainer(name: "NotesV1")
        let settings = Settings()
        
        dataSvc.dbService = cdCont
        
        coreDataContainer = cdCont
        defaultSettings = settings
        dataService = dataSvc
    }
}
