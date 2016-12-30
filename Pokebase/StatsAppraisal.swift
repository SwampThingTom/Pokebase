//
//  StatsAppraisal.swift
//  Pokebase
//
//  Created by Thomas Aylesworth on 12/30/16.
//  Copyright © 2016 Thomas H Aylesworth. All rights reserved.
//

import Foundation

struct StatsAppraisal {
    
    static let statRange = 0...15
    private let BestStatRange = [15...15, 13...14, 8...12, 0...7]
    private let NotBestStatRange = [0...14, 0...13, 0...11, 0...6]
    private let AppraisalRange = [0...45, 37...45, 30...36, 23...29, 0...22]
    
    enum Appraisal: Int {
        case Unknown = 0, Best, Strong, Decent, NeedsImprovement
        
        var stringValue: String {
            get {
                return Appraisal.stringValues[self.rawValue]
            }
        }
        
        static func fromString(_ value: String) -> Appraisal? {
            guard let rawValue = Appraisal.stringValues.index(of: value) else {
                return nil
            }
            return Appraisal(rawValue: rawValue)
        }
        
        private static let stringValues = ["Unknown", "Best", "Strong", "Decent", "NeedsImprovement"]
    }
    
    enum BestStat: Int {
        case Best = 0, Strong, Good, Ok
        
        var stringValue: String {
            get {
                return BestStat.stringValues[self.rawValue]
            }
        }
        
        static func fromString(_ value: String) -> BestStat? {
            guard let rawValue = BestStat.stringValues.index(of: value) else {
                return nil
            }
            return BestStat(rawValue: rawValue)
        }
        
        private static let stringValues = ["Best", "Strong", "Good", "OK"]
    }
    
    let appraisal: Appraisal
    let bestStat: BestStat
    let atkIsBest: Bool
    let defIsBest: Bool
    let staIsBest: Bool
    
    var atkRange: CountableClosedRange<Int> {
        get {
            if appraisal == .Unknown {
                return StatsAppraisal.statRange
            }
            return atkIsBest ? BestStatRange[bestStat.rawValue] : NotBestStatRange[bestStat.rawValue]
        }
    }
    
    var defRange: CountableClosedRange<Int> {
        get {
            if appraisal == .Unknown {
                return StatsAppraisal.statRange
            }
            return defIsBest ? BestStatRange[bestStat.rawValue] : NotBestStatRange[bestStat.rawValue]
        }
    }
    
    var staRange: CountableClosedRange<Int> {
        get {
            if appraisal == .Unknown {
                return StatsAppraisal.statRange
            }
            return staIsBest ? BestStatRange[bestStat.rawValue] : NotBestStatRange[bestStat.rawValue]
        }
    }
    
    static let None = StatsAppraisal()
    
    init() {
        appraisal = .Unknown
        bestStat = .Best
        atkIsBest = false
        defIsBest = false
        staIsBest = false
    }
    
    init(appraisal: Appraisal, bestStat: BestStat, atk: Bool, def: Bool, sta: Bool) {
        self.appraisal = appraisal
        self.bestStat = bestStat
        self.atkIsBest = atk
        self.defIsBest = def
        self.staIsBest = sta
    }
    
    func isValid(iv: IndividualValues) -> Bool {
        if appraisal == .Unknown {
            return true
        }
        
        let totalIv = iv.atk + iv.def + iv.sta
        if !AppraisalRange[appraisal.rawValue].contains(totalIv) {
            return false
        }
        
        if atkIsBest && defIsBest && staIsBest {
            return iv.atk == iv.def && iv.atk == iv.sta
        }
        
        if atkIsBest {
            if defIsBest {
                return iv.atk == iv.def && iv.atk > iv.sta
            }
            if staIsBest {
                return iv.atk == iv.sta && iv.atk > iv.def
            }
            return iv.atk > iv.def && iv.atk > iv.sta
        }
        
        if defIsBest {
            if staIsBest {
                return iv.def == iv.sta && iv.def > iv.atk
            }
            return iv.def > iv.atk && iv.def > iv.sta
        }
        
        if staIsBest {
            return iv.sta > iv.atk && iv.sta > iv.def
        }
        
        return true
    }
}
