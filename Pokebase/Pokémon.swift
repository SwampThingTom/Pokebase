//
//  Pokémon.swift
//  Pokebase
//
//  Created by Thomas Aylesworth on 12/11/16.
//  Copyright © 2016 Thomas H Aylesworth. All rights reserved.
//

import Foundation

typealias IndividualValues = (level: Double, att: Int, def: Int, sta: Int)

struct Pokémon {
    
    let species: String
    let cp: Int
    let hp: Int
    let dustPrice: Int
    let poweredUp: Bool
    
    private let baseATT: Int
    private let baseDEF: Int
    private let baseSTA: Int
    
    init(species: String, cp: Int, hp: Int, dustPrice: Int, poweredUp: Bool) {
        self.species = species
        self.cp = cp
        self.hp = hp
        self.dustPrice = dustPrice
        self.poweredUp = poweredUp
        
        if let baseStats = Species.baseStats(forSpecies: species) {
            self.baseATT = baseStats.att
            self.baseDEF = baseStats.def
            self.baseSTA = baseStats.sta
        } else {
            self.baseATT = 0
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
                for att in 0...15 {
                    let possibleCP = self.calcCP(forLevel: level, att: att, def: def, sta: sta)
                    if possibleCP == cp {
                        possibleIVs.append((level: level, att: att, def: def, sta: sta))
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
    
    private func calcCP(forLevel level: Double, att: Int, def: Int, sta: Int) -> Int {
        guard let cpMultiplier = Species.cpMultiplierForLevel[level] else {
            return 0
        }
        let actualAtt = Double(getAtt(attIv: att))
        let actualDef = Double(getDef(defIv: def))
        let actualSta = Double(getSta(staIv: sta))
        let cp = (actualAtt * pow(actualDef, 0.5) * pow(actualSta, 0.5) * pow(cpMultiplier, 2)) / 10
        return max(10, Int(floor(cp)))
    }
    
    private func calcHP(forLevel level: Double, sta: Int) -> Int {
        guard let cpMultiplier = Species.cpMultiplierForLevel[level] else {
            return 0
        }
        let hp = Double(getSta(staIv: sta)) * cpMultiplier
        return max(10, Int(floor(hp)))
    }
    
    private func getAtt(attIv: Int) -> Int {
        return baseATT + attIv
    }
    
    private func getDef(defIv: Int) -> Int {
        return baseDEF + defIv
    }
    
    private func getSta(staIv: Int) -> Int {
        return baseSTA + staIv
    }
}
