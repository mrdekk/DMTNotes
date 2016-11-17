//
//  Settings.swift
//  NotesV1
//
//  Created by Dmitry Galimzyanov on 08.11.16.
//  Copyright © 2016 Dmitry Galimzyanov. All rights reserved.
//

import UIKit
import Foundation

class SettingsApi {
    lazy var baseUrl: URL? = {
        [weak self] in
        guard let urlStr = self?.dict.value(forKey: "BaseUrl") as? String else {
            return nil
        }
        
        return URL(string: urlStr)
    }()
    
    private var dict: NSDictionary
    
    init(dict: NSDictionary) {
        self.dict = dict
    }
}

class Settings {
    lazy var availableNoteColors: [UIColor] = {
        [unowned self] in
        if let colorsStr = self.dict.value(forKey: "AvailableNoteColors") as? [String] {
            let colors = colorsStr.map({ s in return UIColor(hexRgbString: s) })
            return colors
        }
        return []
    }()
    
    lazy var api: SettingsApi? = {
        [weak self] in
        guard let apiDict = self?.dict.value(forKey: "Api") as? NSDictionary else {
            return nil
        }
        
        return SettingsApi(dict: apiDict)
    }()

    private let dict: NSDictionary

    // default constructor load settings from Settings.plist from main bundle
    convenience init() {
        self.init(path: Bundle.main.path(forResource: "Settings", ofType: "plist")!)
    }

    init(path: String) {
        dict = NSDictionary(contentsOfFile: path)!
    }
}
