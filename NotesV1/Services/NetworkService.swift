//
//  NetworkService.swift
//  NotesV1
//
//  Created by Dmitry Galimzyanov on 17.11.16.
//  Copyright © 2016 Dmitry Galimzyanov. All rights reserved.
//

import Foundation

class NetworkService: NSObject, DataServiceProtocol {
    
    var settings: Settings!
    
    override init() {
        super.init()
    }
    
    private func getFullUrl(tail: String) -> URL? {
        guard let baseUrl = settings.api?.baseUrl else {
            return nil
        }
        
        let url = baseUrl.appendingPathComponent(tail)
        
        return url
    }
    
    private func performRequest(_ request: URLRequest,
                                _ completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) {
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
    func getNotesCount(_ completion: ((Int?) -> ())?) {
        getNotes {
            notes in
            completion?(notes?.count)
        }
    }
    
    func getNotes(_ completion: (([Note]?) -> ())?) {
        guard let url = getFullUrl(tail: "notes") else {
            completion?(nil)
            return
        }
        
        let request = URLRequest(url: url)
        performRequest(request) {
            data, response, error in
            guard let data = data,
                let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [.mutableContainers]),
                let jsonNotesArray = jsonObject as? [[String: Any]]
                else {
                    completion?(nil)
                    return
            }
            
            var notes: [Note] = []
            for jsonNote in jsonNotesArray {
                guard let note = Note(fromDict: jsonNote) else {
                    continue
                }
                notes.append(note)
            }
            
            completion?(notes)
        }
    }
    
    func getNote(noteId: String, _ completion: ((Note?) -> (Swift.Void))?) {
        guard let url = getFullUrl(tail: "notes/"+noteId) else {
            completion?(nil)
            return
        }
        
        let request = URLRequest(url: url)
        performRequest(request) {
            data, response, error in
            guard
                let data = data,
                let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [.mutableContainers]),
                let jsonNote = jsonObject as? [String: Any],
                let note = Note(fromDict: jsonNote)
                else {
                    completion?(nil)
                    return
            }
            
            completion?(note)
        }
    }
    
    func addNote(note: Note, _ completion: ((Bool) -> (Swift.Void))?) {
        guard let url = getFullUrl(tail: "notes") else {
            completion?(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        guard let data = try? JSONSerialization.data(withJSONObject: note.mapToDictionary(), options: [])
            else {
                completion?(false)
                return
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        performRequest(request) {
            data, response, error in
            guard
                error == nil
                else {
                    completion?(false)
                    return
            }
            
            completion?(true)
        }
    }
    
    func updateNote(noteId: String, note: Note, _ completion: ((Bool) -> (Swift.Void))?) {
        guard let url = getFullUrl(tail: "notes/"+noteId) else {
            completion?(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        guard let data = try? JSONSerialization.data(withJSONObject: note.mapToDictionary(), options: [])
            else {
                completion?(false)
                return
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        performRequest(request) {
            data, response, error in
            guard
                error == nil
                else {
                    completion?(false)
                    return
            }
            
            completion?(true)
        }
    }
    
    func removeNote(noteId: String, _ completion: ((Bool) -> ())?) {
        guard let url = getFullUrl(tail: "notes/"+noteId) else {
            completion?(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        performRequest(request) {
            data, response, error in
            guard
                error == nil
                else {
                    completion?(false)
                    return
            }
            
            completion?(true)
        }
    }
}
