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
        savedPokémon.append(pokémonToAdd)
        save()
    }
    
    func remove(at index: Int) {
        savedPokémon.remove(at: index)
        save()
    }
    
    func sort(using descriptors: [NSSortDescriptor]) {
        guard let descriptor = descriptors.first else {
            return
        }
        sort(using: descriptor)
    }
    
    private func sort(using descriptor: NSSortDescriptor) {
        guard let key = descriptor.key else {
            return
        }
        
        switch key {
        case "name":
            sortByName(ascending: descriptor.ascending)
        case "pokédex":
            sortByPokédex(ascending: descriptor.ascending)
        case "species":
            sortBySpecies(ascending: descriptor.ascending)
        case "cp":
            sortByCP(ascending: descriptor.ascending)
        case "hp":
            sortByHP(ascending: descriptor.ascending)
        case "dustPrice":
            sortByDustPrice(ascending: descriptor.ascending)
        case "level":
            sortByLevel(ascending: descriptor.ascending)
        case "atk":
            sortByATK(ascending: descriptor.ascending)
        case "def":
            sortByDEF(ascending: descriptor.ascending)
        case "sta":
            sortBySTA(ascending: descriptor.ascending)
        case "perfection":
            sortByPerfection(ascending: descriptor.ascending)
        case "perfectCP":
            sortByPerfectCP(ascending: descriptor.ascending)
        case "poweredUpCP":
            sortByPoweredUpCP(ascending: descriptor.ascending)
        case "maxCP":
            sortByMaxCP(ascending: descriptor.ascending)
        default:
            return
        }
    }
    
    private func sortByName(ascending: Bool) {
        let comparisonResult: ComparisonResult = ascending ? .orderedAscending : .orderedDescending
        savedPokémon.sort(by: {
            let a = $0.name ?? ""
            let b = $1.name ?? ""
            return a.compare(b) == comparisonResult
        })
    }
    
    private func sortByPokédex(ascending: Bool) {
        savedPokémon.sort(by: {
            let a = $0.pokédex ?? Int.max
            let b = $1.pokédex ?? Int.max
            if a == b {
                return comparePerfection(a: $0, b: $1, ascending: false)
            }
            return ascending ? a < b : a > b
        })
    }
    
    private func sortBySpecies(ascending: Bool) {
        let comparisonResult: ComparisonResult = ascending ? .orderedAscending : .orderedDescending
        savedPokémon.sort(by: { $0.species.compare($1.species) == comparisonResult })
    }
    
    private func sortByPerfection(ascending: Bool) {
        savedPokémon.sort(by: { comparePerfection(a: $0, b: $1, ascending: ascending )})
    }
    
    private func comparePerfection(a: Pokémon, b: Pokémon, ascending: Bool) -> Bool {
        let ivA = a.ivPercent ?? a.ivPercentRange.max
        let ivB = b.ivPercent ?? b.ivPercentRange.max
        return ascending ? ivA < ivB : ivA > ivB
    }
    
    private func sortByCP(ascending: Bool) {
        savedPokémon.sort(by: { ascending ? $0.cp < $1.cp : $0.cp > $1.cp })
    }
    
    private func sortByHP(ascending: Bool) {
        savedPokémon.sort(by: { ascending ? $0.hp < $1.hp : $0.hp > $1.hp })
    }
    
    private func sortByDustPrice(ascending: Bool) {
        savedPokémon.sort(by: { ascending ? $0.dustPrice < $1.dustPrice : $0.dustPrice > $1.dustPrice })
    }
    
    private func sortByLevel(ascending: Bool) {
        savedPokémon.sort(by: {
            let a = $0.level ?? -1
            let b = $1.level ?? -1
            return ascending ? a < b : a > b
        })
    }
    
    private func sortByATK(ascending: Bool) {
        savedPokémon.sort(by: {
            let a = $0.atk ?? Int.min
            let b = $1.atk ?? Int.min
            return ascending ? a < b : a > b
        })
    }
    
    private func sortByDEF(ascending: Bool) {
        savedPokémon.sort(by: {
            let a = $0.def ?? Int.min
            let b = $1.def ?? Int.min
            return ascending ? a < b : a > b
        })
    }
    
    private func sortBySTA(ascending: Bool) {
        savedPokémon.sort(by: {
            let a = $0.sta ?? Int.min
            let b = $1.sta ?? Int.min
            return ascending ? a < b : a > b
        })
    }
    
    private func sortByPerfectCP(ascending: Bool) {
        savedPokémon.sort(by: {
            let a = $0.perfectCP ?? Int.min
            let b = $1.perfectCP ?? Int.min
            return ascending ? a < b : a > b
        })
    }
    
    private func sortByPoweredUpCP(ascending: Bool) {
        savedPokémon.sort(by: {
            let a = $0.poweredUpCP ?? Int.min
            let b = $1.poweredUpCP ?? Int.min
            return ascending ? a < b : a > b
        })
    }
    
    private func sortByMaxCP(ascending: Bool) {
        savedPokémon.sort(by: {
            let a = $0.maxCP ?? Int.min
            let b = $1.maxCP ?? Int.min
            return ascending ? a < b : a > b
        })
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
