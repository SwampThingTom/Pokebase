//
//  PokémonImporter.swift
//  Pokebase
//
//  Created by Thomas Aylesworth on 12/29/16.
//  Copyright © 2016 Thomas H Aylesworth. All rights reserved.
//

import Foundation
import CSwiftV

struct PokémonImporter {
    
    /// Return an array of Pokémon from a CSV file.
    ///
    /// Each line of the file should have fields in the following order:
    /// - Name
    /// - Species
    /// - CP
    /// - HP
    /// - Dust Price
    /// - Powered Up?  ("TRUE" or "YES" if the Pokémon has ever been powered up)
    /// - Level        (if known)
    /// - ATK          (if known)
    /// - DEF          (if known)
    /// - STA          (if known)
    ///
    static func pokémonFromCsv(file: URL) -> [Pokémon] {
        var pokémonArray = [Pokémon]()
        
        guard let csvString = readCsv(file: file) else {
            return pokémonArray
        }
        
        let csvHeaders = ["Name", "Pokémon", "CP", "HP", "Dust Price", "Powered Up?", "Level", "ATK", "DEF", "STA"]
        let csv = CSwiftV(with: csvString, separator: ",", headers: csvHeaders)
        
        var previousName = ("", 0)
        csv.keyedRows?.forEach({
            guard var pokémon = pokémonFromDictionary($0) else {
                return
            }
            
            if shouldReplace(name: pokémon.name, previousName: &previousName) {
                let removed = pokémonArray.popLast()
                print("Removed \(removed?.name)")
                pokémon.name = previousName.0
            }
            
            pokémonArray.append(pokémon)
        })
        return pokémonArray
    }
    
    /// Returns true if the previously added pokémon should be replaced by the new pokémon.
    private static func shouldReplace(name: String?, previousName: inout (String, Int)) -> Bool {
        guard let name = name else {
            return false
        }
        
        if let nameAndSequence = nameAndSequence(from: name) {
            if isSameName(current: nameAndSequence, previous: previousName) {
                previousName = nameAndSequence
                return true
            }
        }
        
        previousName = (name, 0)
        return false
    }
    
    /// Returns true if the current name matches the previous name and the sequence has advanced by 1.
    private static func isSameName(current: (String, Int), previous: (String, Int)?) -> Bool {
        guard let previous = previous else {
            return false
        }
        return current.0 == previous.0 && current.1 == previous.1 + 1
    }
    
    private static func nameAndSequence(from string: Any?) -> (String, Int)? {
        let nameRegEx = try! NSRegularExpression(pattern: "^(.+) (\\d+)$", options: [])
        
        guard let name = string as! String? else {
            return nil
        }
        
        let nameMatches = nameRegEx.matches(in: name, options: [], range: NSRange(location: 0, length: name.characters.count))
        guard let nameMatch = nameMatches.first else {
            return nil
        }
        
        if nameMatch.numberOfRanges != 3 {
            return nil
        }
        
        return nameAndSequence(from: name, nameRange: nameMatch.rangeAt(1), sequenceRange: nameMatch.rangeAt(2))
    }
    
    private static func nameAndSequence(from string: String, nameRange: NSRange, sequenceRange: NSRange) -> (String, Int)? {
        let name = substring(of: string, range: nameRange)
        let sequenceString = substring(of: string, range: sequenceRange)
        guard let sequence = Int(sequenceString) else {
            return nil
        }
        return (name, sequence)
    }
    
    private static func substring(of string: String, range: NSRange) -> String {
        let start = string.index(string.startIndex, offsetBy: range.location)
        let end = string.index(start, offsetBy: range.length)
        return string.substring(with: start ..< end)
    }
    
    private static func readCsv(file: URL) -> String? {
        do {
            let csvString = try String(contentsOf: file)
            return csvString
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
    
    private static func pokémonFromDictionary(_ dictionary: [String : String]) -> Pokémon? {
        guard let species = dictionary["Pokémon"],
            let cpString = dictionary["CP"],
            let hpString = dictionary["HP"],
            let dustPriceString = dictionary["Dust Price"] else {
                return nil
        }
        
        guard let cp = Int(cpString),
            let hp = Int(hpString),
            let dustPrice = Int(dustPriceString) else {
                return nil
        }
        
        let name = dictionary["Name"]
        let isPoweredUp = boolFromString(dictionary["Powered Up?"])
        let ivs = ivsFromDictionary(dictionary)
        
        return Pokémon(name: name,
                         species: species,
                         cp: cp,
                         hp: hp,
                         dustPrice: dustPrice,
                         isPoweredUp: isPoweredUp,
                         appraisal: StatsAppraisal.None,
                         ivs: ivs)
    }
    
    private static func boolFromString(_ stringValue: String?) -> Bool {
        guard let stringValue = stringValue else {
            return false
        }
        
        if stringValue.caseInsensitiveCompare("true") == .orderedSame {
            return true
        }
        
        if stringValue.caseInsensitiveCompare("yes") == .orderedSame {
            return true
        }
        
        return false
    }
    
    private static func ivsFromDictionary(_ dictionary: [String : String]) -> IndividualValues? {
        guard let levelString = dictionary["Level"],
            let atkString = dictionary["ATK"],
            let defString = dictionary["DEF"],
            let staString = dictionary["STA"] else {
                return nil
        }
        
        guard let level = Double(levelString),
            let atk = Int(atkString),
            let def = Int(defString),
            let sta = Int(staString) else {
                return nil
        }
        
        return (level: level, atk: atk, def: def, sta: sta)
    }
}
