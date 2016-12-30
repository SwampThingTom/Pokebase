//
//  Pokémon.swift
//  Pokebase
//
//  Created by Thomas Aylesworth on 12/11/16.
//  Copyright © 2016 Thomas H Aylesworth. All rights reserved.
//

import Foundation

typealias MinMaxRange = (min: Int, max: Int)

protocol TrainerLevelProvider {
    var trainerLevel: Int { get }
}

/// An individual Pokémon.
struct Pokémon {
    
    /// User-provided name for Pokémon
    var name: String?
    
    /// Pokémon species
    let species: String
    
    /// Pokédex number
    let pokédex: Int?
    
    /// Combat Power
    let cp: Int
    
    /// Hit Points
    let hp: Int
    
    /// Dust price for powering up
    let dustPrice: Int
    
    /// Has this Pokémon been powered up?
    let poweredUp: Bool
    
    /// Trainer appraisal
    let appraisal: StatsAppraisal
    
    /// Individual Values (if known)
    let ivs: IndividualValues?
    
    /// Individual Value Calculator for this Pokémon
    let ivCalculator: IVCalculator
    
    /// All possible Individual Values based on CP, HP, and Dust Price
    let possibleIvs: [IndividualValues]
    
    /// Pokémon level (if known)
    var level: Double? {
        return ivs?.level
    }
    
    /// Attack IV (if known)
    var atk: Int? {
        return ivs?.atk
    }
    
    /// Defense IV (if known)
    var def: Int? {
        return ivs?.def
    }

    /// Stamina IV (if known)
    var sta: Int? {
        return ivs?.sta
    }

    /// How close IVs are to perfect (0 = terrible, 100 = perfect), if known
    var ivPercent: Int? {
        guard let ivs = ivs else {
            return nil
        }
        return Pokémon.percentOfMax(ivs: ivs)
    }
    
    /// Range of IV percentages based on possible IVs
    var ivPercentRange: MinMaxRange {
        return possibleIvs.reduce((min: 100, max: 0), { (range, ivs) -> MinMaxRange in
            let ivPercent = Pokémon.percentOfMax(ivs: ivs)
            return (min: min(range.min, ivPercent), max: max(range.max, ivPercent))
        })
    }
    
    /// The CP of this Pokémon if it had perfect IVs
    var perfectCP: Int? {
        guard let level = ivs?.level else {
            return nil
        }
        return ivCalculator.calcCP(forLevel: level, atk: 15, def: 15, sta: 15)
    }
    
    /// The CP of this Pokémon if it were powered up to the maximum based on the trainer's current level
    var poweredUpCP: Int? {
        guard let ivs = ivs, let maxLevel = maxLevel else {
            return nil
        }
        return ivCalculator.calcCP(forLevel: maxLevel, atk: ivs.atk, def: ivs.def, sta: ivs.sta)
    }
    
    /// The CP of this Pokémon if it were fully evolved and powered up to the maximum based on the trainer's current level
    var maxCP: Int? {
        guard let ivs = ivs,
            let maxLevel = maxLevel,
            let evolvedSpecies = Species.finalEvolution(forSpecies: species) else {
                return nil
        }
        let evolvedCalculator = IVCalculator(species: evolvedSpecies,
                                             cp: cp,
                                             hp: hp,
                                             dustPrice: dustPrice,
                                             poweredUp: poweredUp,
                                             appraisal: appraisal)
        return evolvedCalculator?.calcCP(forLevel: maxLevel, atk: ivs.atk, def: ivs.def, sta: ivs.sta)
    }
    
    /// An object that provides the current trainer level
    static var trainerLevelProvider: TrainerLevelProvider?
    
    /// The maximum level for the Pokémon based on the current trainer level
    var maxLevel: Double? {
        guard let trainerLevel = Pokémon.trainerLevelProvider?.trainerLevel else {
            return nil
        }
        return Double(trainerLevel) + 1.5
    }
    
    init(_ pokémon: IVCalculator) {
        self.species = pokémon.species
        self.pokédex = Species.names.index(of: self.species)
        
        self.cp = pokémon.cp
        self.hp = pokémon.hp
        self.dustPrice = pokémon.dustPrice
        self.poweredUp = pokémon.poweredUp
        
        self.appraisal = pokémon.appraisal
        self.ivCalculator = pokémon
        self.possibleIvs = pokémon.derivePossibleIVs()
        self.ivs = self.possibleIvs.count == 1 ? self.possibleIvs[0] : nil
    }
    
    init?(name: String?,
          species: String,
          cp: Int,
          hp: Int,
          dustPrice: Int,
          isPoweredUp: Bool,
          appraisal: StatsAppraisal,
          ivs: IndividualValues?) {
        
        if !Species.names.contains(species) {
            return nil
        }
        
        self.species = species
        self.pokédex = Species.names.index(of: self.species)
        
        self.cp = cp
        self.hp = hp
        self.dustPrice = dustPrice
        
        self.name = name?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        self.poweredUp = isPoweredUp
        self.appraisal = appraisal
        
        self.ivCalculator = IVCalculator(species: self.species,
                                         cp: self.cp,
                                         hp: self.hp,
                                         dustPrice: self.dustPrice,
                                         poweredUp: self.poweredUp,
                                         appraisal: appraisal)!
        
        self.ivs = ivs
        self.possibleIvs = ivs == nil ? self.ivCalculator.derivePossibleIVs() : [self.ivs!]
    }
    
    init?(json: [String: Any]) {
        guard let species = json["species"] as? String,
            let cp = json["cp"] as? Int,
            let hp = json["hp"] as? Int,
            let dustPrice = json["dustPrice"] as? Int else {
                return nil
        }
        
        let name = json["name"] as! String?
        let isPoweredUp = json["poweredUp"] as? Bool ?? false
        let appraisal = Pokémon.appraisalFromJsonDictionary(json["appraisal"] as! [String : Any]?)
        let ivs = Pokémon.ivsFromJsonDictionary(json["ivs"] as! [String : Any]?)
        
        self.init(name: name,
                  species: species,
                  cp: cp,
                  hp: hp,
                  dustPrice: dustPrice,
                  isPoweredUp: isPoweredUp,
                  appraisal: appraisal,
                  ivs: ivs)
    }
    
    func toJson() -> [String: Any] {
        var json: [String: Any] = ["name": name ?? "",
                                   "species": species,
                                   "cp": cp,
                                   "hp": hp,
                                   "dustPrice": dustPrice,
                                   "poweredUp": poweredUp]
        
        if appraisal.appraisal != .Unknown {
            json["appraisal"] = [
                "appraisal": appraisal.appraisal.stringValue,
                "atk": appraisal.atkIsBest,
                "def": appraisal.defIsBest,
                "sta": appraisal.staIsBest,
                "best": appraisal.bestStat.stringValue]
        }
        
        if let ivs = self.ivs {
            json["ivs"] = ["level": ivs.level, "atk": ivs.atk, "def": ivs.def, "sta": ivs.sta]
        }
        
        return json
    }
    
    static func percentOfMax(ivs: IndividualValues) -> Int {
        return Int(round(100.0 * Double(ivs.atk + ivs.def + ivs.sta) / 45.0))
    }
    
    private static func appraisalFromJsonDictionary(_ dictionary: [String : Any]?) -> StatsAppraisal {
        guard let appraisal = dictionary else {
            return StatsAppraisal.None
        }
        
        guard let ivAppraisalString = appraisal["appraisal"] as? String,
            let ivAppraisal = StatsAppraisal.Appraisal.fromString(ivAppraisalString),
            let atkIsBest = appraisal["atk"] as? Bool,
            let defIsBest = appraisal["def"] as? Bool,
            let staIsBest = appraisal["sta"] as? Bool,
            let bestStatString = appraisal["best"] as? String,
            let bestStat = StatsAppraisal.BestStat.fromString(bestStatString) else {
                return StatsAppraisal.None
        }
        
        return StatsAppraisal(appraisal: ivAppraisal,
                              bestStat: bestStat,
                              atk: atkIsBest,
                              def: defIsBest,
                              sta: staIsBest)
    }
    
    private static func ivsFromJsonDictionary(_ dictionary: [String : Any]?) -> IndividualValues? {
        guard let ivs = dictionary else {
            return nil
        }
        
        guard let level = ivs["level"] as? Double,
            let atk = ivs["atk"] as? Int,
            let def = ivs["def"] as? Int,
            let sta = ivs["sta"] as? Int else {
                return nil
        }
        
        return (level: level, atk: atk, def: def, sta: sta)
    }
}
