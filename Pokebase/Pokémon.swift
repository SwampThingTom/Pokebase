//
//  Pokémon.swift
//  Pokebase
//
//  Created by Thomas Aylesworth on 12/11/16.
//  Copyright © 2016 Thomas H Aylesworth. All rights reserved.
//

import Foundation

struct Pokémon: Equatable {
    
    let species: String
    let cp: Int
    let hp: Int
    let dustPrice: Int
    let poweredUp: Bool
    let ivs: IndividualValues?
    
    var level: Double? {
        guard let ivs = ivs else {
            return nil
        }
        return ivs.level
    }
    
    var atk: Int? {
        guard let ivs = ivs else {
            return nil
        }
        return ivs.atk
    }
    
    var def: Int? {
        guard let ivs = ivs else {
            return nil
        }
        return ivs.def
    }

    var sta: Int? {
        guard let ivs = ivs else {
            return nil
        }
        return ivs.sta
    }

    var ivPercent: Int? {
        guard let ivs = ivs else {
            return nil
        }
        return Int(round(100.0 * Double(ivs.atk + ivs.def + ivs.sta) / 45.0))
    }
    
    var perfectCP: Int? {
        return nil
    }
    
    var poweredUpCP: Int? {
        return nil
    }
    
    var maxCP: Int? {
        return nil
    }
    
    init(_ pokémon: IVCalculator) {
        self.species = pokémon.species
        self.cp = pokémon.cp
        self.hp = pokémon.hp
        self.dustPrice = pokémon.dustPrice
        self.poweredUp = pokémon.poweredUp
        
        let ivs = pokémon.derivePossibleIVs()
        self.ivs = ivs.count == 1 ? ivs[0] : nil
    }
    
    init?(json: [String: Any]) {
        guard let species = json["species"] as? String,
            let cp = json["cp"] as? Int,
            let hp = json["hp"] as? Int,
            let dustPrice = json["dustPrice"] as? Int,
            let poweredUp = json["poweredUp"] as? Bool else {
                return nil
        }
        
        self.species = species
        self.cp = cp
        self.hp = hp
        self.dustPrice = dustPrice
        self.poweredUp = poweredUp
        
        guard let ivs = json["ivs"] as? [String: Any] else {
            self.ivs = nil
            return
        }
        
        guard let level = ivs["level"] as? Double,
            let atk = ivs["atk"] as? Int,
            let def = ivs["def"] as? Int,
            let sta = ivs["sta"] as? Int else {
                return nil
        }
        
        self.ivs = (level: level, atk: atk, def: def, sta: sta)
    }
    
    func toJson() -> [String: Any] {
        var json: [String: Any] = ["species": species,
                                   "cp": cp,
                                   "hp": hp,
                                   "dustPrice": dustPrice,
                                   "poweredUp": poweredUp]
        if let ivs = self.ivs {
            json["ivs"] = ["level": ivs.level, "atk": ivs.atk, "def": ivs.def, "sta": ivs.sta]
        }
        return json
    }
    
    // MARK: Equatable
    
    static func ==(lhs: Pokémon, rhs: Pokémon) -> Bool {
        return lhs.id == rhs.id
    }
    
    private let id = Pokémon.nextUniqueId()
    
    private static var lastUniqueId = 0
    private static func nextUniqueId() -> Int {
        lastUniqueId += 1
        return lastUniqueId
    }
}
