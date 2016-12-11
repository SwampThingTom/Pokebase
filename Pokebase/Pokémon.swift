//
//  Pokémon.swift
//  Pokebase
//
//  Created by Thomas Aylesworth on 12/11/16.
//  Copyright © 2016 Thomas H Aylesworth. All rights reserved.
//

import Foundation

typealias IndividualValues = (level: Double, atk: Int, def: Int, sta: Int)

struct Pokémon {
    
    let species: String
    let cp: Int
    let hp: Int
    let dustPrice: Int
    let poweredUp: Bool
    
    var level: Int?
    var atk: Int?
    var def: Int?
    var sta: Int?
    
    var ivPercent: Int? {
        guard let atk = atk, let def = def, let sta = sta else {
            return nil
        }
        return Int(round(Double(atk + def + sta) / 45.0))
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
    
    private let baseATK: Int
    private let baseDEF: Int
    private let baseSTA: Int
    
    init(species: String, cp: Int, hp: Int, dustPrice: Int, poweredUp: Bool) {
        self.species = species
        self.cp = cp
        self.hp = hp
        self.dustPrice = dustPrice
        self.poweredUp = poweredUp
        
        if let baseStats = Species.baseStats(forSpecies: species) {
            self.baseATK = baseStats.atk
            self.baseDEF = baseStats.def
            self.baseSTA = baseStats.sta
        } else {
            self.baseATK = 0
            self.baseDEF = 0
            self.baseSTA = 0
        }
    }
    
    func possibleIVs() -> [IndividualValues] {
        let minLevel = Species.levelForStardust[dustPrice]!
        let maxLevel = minLevel + 1.5
        
        var possibleIVs = [IndividualValues]()
        for level in stride(from: minLevel, to: maxLevel, by: poweredUp ? 0.5 : 1.0 ) {
            possibleIVs.append(contentsOf: self.possibleIVs(level: level))
        }
        
        return possibleIVs
    }
    
    private func possibleIVs(level: Double) -> [IndividualValues] {
        var possibleIVs = [IndividualValues]()
        let possibleSTAs = self.possibleSTAs(level: level)
        for sta in possibleSTAs {
            for def in 0...15 {
                for atk in 0...15 {
                    let possibleCP = self.calcCP(forLevel: level, atk: atk, def: def, sta: sta)
                    if possibleCP == cp {
                        possibleIVs.append((level: level, atk: atk, def: def, sta: sta))
                    }
                }
            }
        }
        return possibleIVs
    }
    
    private func possibleSTAs(level: Double) -> [Int] {
        let minHp = self.calcHP(forLevel: level, sta: 0)
        let maxHp = self.calcHP(forLevel: level, sta: 15)
        if hp < minHp || hp > maxHp {
            return []
        }
        
        return (0...15).filter( { return self.calcHP(forLevel: level, sta: $0) == hp } )
    }
    
    private func calcCP(forLevel level: Double, atk: Int, def: Int, sta: Int) -> Int {
        guard let cpMultiplier = Species.cpMultiplierForLevel[level] else {
            return 0
        }
        let actualAtk = Double(getATK(atkIv: atk))
        let actualDef = Double(getDEF(defIv: def))
        let actualSta = Double(getSTA(staIv: sta))
        let cp = (actualAtk * pow(actualDef, 0.5) * pow(actualSta, 0.5) * pow(cpMultiplier, 2)) / 10
        return max(10, Int(floor(cp)))
    }
    
    private func calcHP(forLevel level: Double, sta: Int) -> Int {
        guard let cpMultiplier = Species.cpMultiplierForLevel[level] else {
            return 0
        }
        let hp = Double(getSTA(staIv: sta)) * cpMultiplier
        return max(10, Int(floor(hp)))
    }
    
    private func getATK(atkIv: Int) -> Int {
        return baseATK + atkIv
    }
    
    private func getDEF(defIv: Int) -> Int {
        return baseDEF + defIv
    }
    
    private func getSTA(staIv: Int) -> Int {
        return baseSTA + staIv
    }
}
