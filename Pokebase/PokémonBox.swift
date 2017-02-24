//
//  PokémonBox.swift
//  Pokebase
//
//  Created by Thomas Aylesworth on 12/14/16.
//  Copyright © 2016 Thomas H Aylesworth. All rights reserved.
//

import Foundation

extension Int {
    init(_ bool: Bool) {
        self = bool ? 1 : 0
    }
}

/// Model object for the user's currently saved Pokémon.
class PokémonBox: TrainerLevelProvider {
    
    private var savedPokémon: [Pokémon]
    private let fileUrl: URL

    // MARK: - Public
    
    /// The trainer's level
    var trainerLevel: Int {
        didSet {
            if trainerLevel != oldValue {
                save()
            }
        }
    }
    
    /// Number of Pokémon in box
    var count: Int {
        get {
            return savedPokémon.count
        }
    }
    
    /// Number of unique species in box
    var uniqueSpeciesCount: Int {
        get {
            let species = savedPokémon.map { $0.species }
            let uniqueSpecies = Set(species)
            return uniqueSpecies.count
        }
    }
    
    /// Number of unique gen 1 species in box
    var gen1SpeciesCaughtCount: Int {
        get {
            let species = savedPokémon.map { $0.species }.filter({ Species.gen1.contains($0) })
            let uniqueSpecies = Set(species)
            return uniqueSpecies.count
        }
    }
    
    /// Number of total gen 1 species available
    var gen1SpeciesTotalCount: Int {
        get {
            return Species.gen1.count
        }
    }
    
    /// Number of unique gen 2 species in box
    var gen2SpeciesCaughtCount: Int {
        get {
            let species = savedPokémon.map { $0.species }.filter({ Species.gen2.contains($0) })
            let uniqueSpecies = Set(species)
            return uniqueSpecies.count
        }
    }
    
    /// Number of total gen 2 species available
    var gen2SpeciesTotalCount: Int {
        get {
            return Species.gen2.count
        }
    }
    
    /// The Pokémon at the given index
    subscript(index: Int) -> Pokémon {
        get {
            return savedPokémon[index]
        }
    }
    
    /// Initialize PokémonBox from saved JSON file
    init(file: URL? = nil) {
        do {
            fileUrl = try! file ?? PokémonBox.defaultPokémonFile()
            
            // For now, always backup on startup so user can recover to last good save
            PokémonBox.backup(fileUrl)
            
            let jsonData = try Data(contentsOf: fileUrl)
            let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData) as! [String : Any]
            trainerLevel = jsonDictionary["Level"] as? Int ?? 1
            
            let pokémonArray = jsonDictionary["Pokémon"] as! [[String : Any]]
            savedPokémon = pokémonArray.map({ Pokémon(json: $0)! })
        }
        catch let error as NSError {
            if let cocoaError = error as? CocoaError {
                if cocoaError.code != CocoaError.fileReadNoSuchFile {
                    print(error.localizedDescription);
                }
            }
            trainerLevel = 1
            savedPokémon = [Pokémon]()
            save()
        }
        Pokémon.trainerLevelProvider = self
    }
    
    /// Import Pokémon from CSV file
    func importFromCsv(file: URL? = nil) {
        let importFileUrl = try! file ?? PokémonBox.defaultPokémonCsvFile()
        let pokémonArray = PokémonImporter.pokémonFromCsv(file: importFileUrl)
        pokémonArray.forEach({ savedPokémon.append($0) })
        save()        
    }
    
    /// Add a Pokémon to the box
    func add(_ pokémonToAdd: Pokémon) {
        savedPokémon.append(pokémonToAdd)
        save()
    }
    
    /// Remove the Pokémon at the given index from the box
    func remove(at index: Int) {
        savedPokémon.remove(at: index)
        save()
    }
    
    /// Sort the box
    func sort(using descriptors: [NSSortDescriptor]) {
        guard let descriptor = descriptors.first else {
            return
        }
        sort(using: descriptor)
    }
    
    /// Find first index containing given species
    func indexOfFirst(species: String) -> Int? {
        return savedPokémon.index(where: { $0.species == species })
    }
    
    func updatePokémon(at index: Int, name: String) {
        savedPokémon[index].name = name
        save()
    }
    
    // MARK: - Sorting
    
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
        case "isPoweredUp":
            sortByIsPoweredUp(ascending: descriptor.ascending)
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
    
    private func sortByIsPoweredUp(ascending: Bool) {
        savedPokémon.sort(by: { ascending ? Int($0.poweredUp) < Int($1.poweredUp) : Int($0.poweredUp) > Int($1.poweredUp) })
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
    
    // MARK: - File management
    
    private func save() {
        let pokémonArray = savedPokémon.map { (pokémon: Pokémon) -> [String : Any] in
            return pokémon.toJson()
        }
        
        let jsonDictionary = ["Level": trainerLevel, "Pokémon": pokémonArray] as [String : Any]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
            try jsonData.write(to: fileUrl)
        }
        catch let error as NSError {
            print(error.localizedDescription);
        }
    }
    
    private static func backup(_ fileUrl: URL) {
        do {
            if !FileManager.default.fileExists(atPath: fileUrl.path) {
                return
            }
            
            let backupFileUrl = fileUrl.appendingPathExtension("bak")
            if FileManager.default.fileExists(atPath: backupFileUrl.path) {
                try FileManager.default.removeItem(at: backupFileUrl)
            }
            
            try FileManager.default.copyItem(at: fileUrl, to: backupFileUrl)
        }
        catch let error as NSError {
            print(error.localizedDescription);
        }
    }
    
    private static func defaultPokémonFile() throws -> URL {
        let directoryUrl = try defaultPokémonDirectory()
        try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
        return directoryUrl.appendingPathComponent("pokebase")
    }
    
    private static func defaultPokémonCsvFile() throws -> URL {
        let directoryUrl = try defaultPokémonDirectory()
        return directoryUrl.appendingPathComponent("pokemon.csv")
    }
    
    private static func defaultPokémonDirectory() throws -> URL {
        let documentDirectoryUrl = try FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory,
                                                                in: FileManager.SearchPathDomainMask.userDomainMask,
                                                                appropriateFor: nil,
                                                                create: true)
        let directoryUrl = documentDirectoryUrl.appendingPathComponent("Pokébase", isDirectory: true)
        return directoryUrl
    }
}
