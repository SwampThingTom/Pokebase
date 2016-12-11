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
    
    static let ivRange = 0...15
    
    let species: String
    let cp: Int
    let hp: Int
    let dustPrice: Int
    let poweredUp: Bool
    
    var possibleIVs: [IndividualValues]?
    
    var level: Double? {
        guard let possibleIVs = self.possibleIVs else {
            return nil
        }
        return possibleIVs.count == 1 ? possibleIVs[0].level : nil
    }
    
    var atk: Int? {
        guard let possibleIVs = self.possibleIVs else {
            return nil
        }
        return possibleIVs.count == 1 ? possibleIVs[0].atk : nil
    }
    
    var def: Int? {
        guard let possibleIVs = self.possibleIVs else {
            return nil
        }
        return possibleIVs.count == 1 ? possibleIVs[0].def : nil
    }

    var sta: Int? {
        guard let possibleIVs = self.possibleIVs else {
            return nil
        }
        return possibleIVs.count == 1 ? possibleIVs[0].sta : nil
    }

    var ivPercent: Int? {
        guard let atk = atk, let def = def, let sta = sta else {
            return nil
        }
        return Int(round(100.0 * Double(atk + def + sta) / 45.0))
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
    
    mutating func derivePossibleIVs() {
        if self.possibleIVs != nil {
            return
        }
        let minLevel = Species.levelForStardust[dustPrice]!
        let maxLevel = minLevel + 1.5
        
        var possibleIVs = [IndividualValues]()
        for level in stride(from: minLevel, to: maxLevel, by: poweredUp ? 0.5 : 1.0 ) {
            possibleIVs.append(contentsOf: self.possibleIVsForLevel(level))
        }
        
        self.possibleIVs = possibleIVs
    }
    
    private func possibleIVsForLevel(_ level: Double) -> [IndividualValues] {
        var possibleIVs = [IndividualValues]()
        let possibleSTAs = self.possibleSTAs(level: level)
        for sta in possibleSTAs {
            for def in Pokémon.ivRange {
                for atk in Pokémon.ivRange {
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
        let minHp = self.calcHP(forLevel: level, sta: Pokémon.ivRange.lowerBound)
        let maxHp = self.calcHP(forLevel: level, sta: Pokémon.ivRange.upperBound)
        if hp < minHp || hp > maxHp {
            return []
        }
        
        return Pokémon.ivRange.filter( { return self.calcHP(forLevel: level, sta: $0) == hp } )
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
