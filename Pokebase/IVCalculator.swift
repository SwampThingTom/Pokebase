//
//  IVCalculator.swift
//  Pokebase
//
//  Created by Thomas Aylesworth on 12/13/16.
//  Copyright © 2016 Thomas H Aylesworth. All rights reserved.
//

import Foundation

/// An IVCalculator instance is used to calculate possible or actual Individual Values based on
/// Species, CP, HP, Dust Price, and whether the Pokémon has ever been powered up.
struct IVCalculator {
    
    static let ivRange = 0...15

    let species: String
    let cp: Int
    let hp: Int
    let dustPrice: Int
    let poweredUp: Bool
    
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
    
    func derivePossibleIVs() -> [IndividualValues] {
        var possibleIVs = [IndividualValues]()
        
        guard let minLevel = Species.levelForStardust[dustPrice] else {
            return possibleIVs
        }
        let maxLevel = minLevel + 2.0
        
        for level in stride(from: minLevel, to: maxLevel, by: poweredUp ? 0.5 : 1.0 ) {
            possibleIVs.append(contentsOf: self.possibleIVsForLevel(level))
        }
        
        return possibleIVs
    }
    
    func calcCP(forLevel level: Double, atk: Int, def: Int, sta: Int) -> Int {
        guard let cpMultiplier = Species.cpMultiplierForLevel[level] else {
            return 0
        }
        
        let actualAtk = Double(getATK(atkIv: atk))
        let actualDef = Double(getDEF(defIv: def))
        let actualSta = Double(getSTA(staIv: sta))
        let cp = (actualAtk * pow(actualDef, 0.5) * pow(actualSta, 0.5) * pow(cpMultiplier, 2)) / 10
        return max(10, Int(floor(cp)))
    }
    
    private func possibleIVsForLevel(_ level: Double) -> [IndividualValues] {
        var possibleIVs = [IndividualValues]()
        let possibleSTAs = self.possibleSTAs(level: level)
        for sta in possibleSTAs {
            for def in IVCalculator.ivRange {
                for atk in IVCalculator.ivRange {
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
        let minHp = self.calcHP(forLevel: level, sta: IVCalculator.ivRange.lowerBound)
        let maxHp = self.calcHP(forLevel: level, sta: IVCalculator.ivRange.upperBound)
        if hp < minHp || hp > maxHp {
            return []
        }
        
        return IVCalculator.ivRange.filter( { return self.calcHP(forLevel: level, sta: $0) == hp } )
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
