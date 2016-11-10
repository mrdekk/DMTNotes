//
//  ServiceLocator.swift
//  NotesV1
//
//  Created by Dmitry Galimzyanov on 09.11.16.
//  Copyright © 2016 Dmitry Galimzyanov. All rights reserved.
//

import Foundation

protocol ServiceLocatorProtocol {
    var dataService: IDataService { get }
    var defaultSettings: Settings { get }
}

class ServiceLocator: ServiceLocatorProtocol {
    var dataService: IDataService = DumbDataService()
    var defaultSettings: Settings = Settings()
}
