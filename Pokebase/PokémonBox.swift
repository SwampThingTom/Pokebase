//
//  PokémonBox.swift
//  Pokebase
//
//  Created by Thomas Aylesworth on 12/14/16.
//  Copyright © 2016 Thomas H Aylesworth. All rights reserved.
//

import Foundation

class PokémonBox: TrainerLevelProvider {
 
    var trainerLevel: Int {
        didSet {
            if trainerLevel != oldValue {
                save()
            }
        }
    }
    
    var count: Int {
        get {
            return savedPokémon.count
        }
    }
    
    subscript(index: Int) -> Pokémon {
        get {
            return savedPokémon[index]
        }
    }
    
    private var savedPokémon: [Pokémon]
    private let fileUrl: URL
    
    init(file: URL? = nil) {
        do {
            fileUrl = try! file ?? PokémonBox.defaultPokémonFile()
            let jsonData = try Data(contentsOf: fileUrl)
            let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData) as! [String : Any]
            trainerLevel = jsonDictionary["Level"] as? Int ?? 1
            let pokémonArray = jsonDictionary["Pokémon"] as! [[String : Any]]
            savedPokémon = pokémonArray.map({ (json: [String : Any]) -> Pokémon in
                return Pokémon(json: json)!
            })
        }
        catch let error as NSError {
            if let cocoaError = error as? CocoaError {
                if cocoaError.code != CocoaError.fileReadNoSuchFile {
                    print(error.localizedDescription);
                    PokémonBox.backup(fileUrl)
                }
            }
            trainerLevel = 1
            savedPokémon = [Pokémon]()
            save()
        }
        Pokémon.trainerLevelProvider = self
    }
    
    func add(_ pokémonToAdd: Pokémon) {
        self.savedPokémon.append(pokémonToAdd)
        save()
    }
    
    func remove(_ pokémonToRemove: Pokémon) {
        self.savedPokémon = self.savedPokémon.filter({ (pokémon) -> Bool in
            pokémon == pokémonToRemove
        })
        save()
    }
    
    private func save() {
        let pokémonArray = savedPokémon.map { (pokémon: Pokémon) -> [String : Any] in
            return pokémon.toJson()
        }
        
        let jsonDictionary = ["Level": trainerLevel, "Pokémon": pokémonArray] as [String : Any]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonDictionary)
            try jsonData.write(to: fileUrl)
        }
        catch let error as NSError {
            print(error.localizedDescription);
        }
    }
    
    private static func backup(_ fileUrl: URL) {
        do {
            try FileManager.default.moveItem(at: fileUrl, to: fileUrl.appendingPathExtension("bak"))
        }
        catch let error as NSError {
            print(error.localizedDescription);
        }
    }
    
    private static func defaultPokémonFile() throws -> URL {
        let applicationSupportUrl = try FileManager.default.url(for: FileManager.SearchPathDirectory.applicationSupportDirectory,
                                                                in: FileManager.SearchPathDomainMask.userDomainMask,
                                                                appropriateFor: nil,
                                                                create: true)
        let bundleId = Bundle.main.bundleIdentifier!
        let directoryUrl = applicationSupportUrl.appendingPathComponent(bundleId, isDirectory: true)
        try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
        return directoryUrl.appendingPathComponent("pokébase")
    }
}
