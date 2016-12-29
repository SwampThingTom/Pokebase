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
        csv.keyedRows?.forEach({
            if let pokémon = pokémonFromDictionary($0) {
                pokémonArray.append(pokémon)
            }
        })
        return pokémonArray
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
        
        return Pokémon(name: name, species: species, cp: cp, hp: hp, dustPrice: dustPrice, isPoweredUp: isPoweredUp, ivs: ivs)
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
