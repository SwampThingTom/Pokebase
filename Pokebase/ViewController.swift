//
//  ViewController.swift
//  Pokebase
//
//  Created by Thomas Aylesworth on 12/10/16.
//  Copyright © 2016 Thomas H Aylesworth. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSControlTextEditingDelegate, NSComboBoxDataSource, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var trainerLevelField: NSTextField?
    @IBOutlet weak var pokémonField: NSComboBox?
    @IBOutlet weak var cpField: NSTextField?
    @IBOutlet weak var hpField: NSTextField?
    @IBOutlet weak var dustField: NSPopUpButton?
    @IBOutlet weak var isPoweredUpField: NSPopUpButton?
    @IBOutlet weak var resultLabel: NSTextField?
    @IBOutlet weak var tableView: NSTableView?
    
    private var savedPokémon = PokémonBox()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trainerLevelField?.stringValue = "\(savedPokémon.trainerLevel)"
        pokémonField?.selectItem(at: 0)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        guard let level = trainerLevelField?.integerValue else {
            return false
        }
        
        if level < 1 || level > 40 {
            return false
        }
        
        savedPokémon.trainerLevel = level
        self.tableView?.reloadData()
        return true
    }
    
    @IBAction func calculateIVs(sender: NSButton) {
        guard let ivCalculator = ivCalculator() else {
            return
        }
        let possibleIVs = ivCalculator.derivePossibleIVs()
        resultLabel?.stringValue = statusString(forIVs: possibleIVs)
    }
    
    @IBAction func savePokémon(sender: NSButton) {
        guard let ivCalculator = ivCalculator() else {
            return
        }
        
        let pokémon = Pokémon(ivCalculator)
        savedPokémon.add(pokémon)
        self.tableView?.reloadData()
    }
    
    private func ivCalculator() -> IVCalculator? {
        guard let pokémonIndex = pokémonField?.indexOfSelectedItem,
            let cp = cpField?.integerValue,
            let hp = hpField?.integerValue,
            let dustString = dustField?.titleOfSelectedItem,
            let dust = Int(dustString) else {
                return nil
        }
        
        let species = Species.names[pokémonIndex]
        let calculator = IVCalculator(species: species, cp: cp, hp: hp, dustPrice: dust, poweredUp: false)
        return calculator
    }
    
    private func statusString(forIVs ivs: [IndividualValues]) -> String {
        let combinations = ivs.count
        
        if combinations == 0 {
            return "No combinations found"
        }
        
        if combinations > 1 {
            let range = ivs.reduce((min: 100, max: 0), { (range, ivs) -> MinMaxRange in
                let ivPercent = Pokémon.percentOfMax(ivs: ivs)
                return (min: min(range.min, ivPercent), max: max(range.max, ivPercent))
            })
            return "There are \(combinations) possible combinations with an IV range of \(range.min) - \(range.max)"
        }
        
        let iv = ivs.first!
        return "Level: \(iv.level) ATK: \(iv.atk) DEF: \(iv.def) STA: \(iv.sta)"
    }
    
    // MARK: - ComboBox Data Source
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return Species.names.count
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return Species.names[index]
    }
    
    // MARK: - TableView Delegate
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return savedPokémon.count
    }
    
    private let editableCellBackgroundColor = CGColor(red: 255.0 / 255.0, green: 250.0 / 255.0, blue: 205.0 / 255.0, alpha: 1.0)
    private let attributeCellBackgroundColor = CGColor(red: 190.0 / 255.0, green: 227.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
    private let maxCpCellBackgroundColor = CGColor(red: 240.0 / 255.0, green: 240.0 / 255.0, blue: 240.0 / 255.0, alpha: 1.0)
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let columnIdentifier = tableColumn?.identifier else {
            return nil
        }
        
        guard let cellView = tableView.make(withIdentifier: columnIdentifier, owner: self) as? NSTableCellView else {
            return nil
        }
        
        let cell = cellTextForColumn(columnIdentifier, row: row)
        cellView.textField?.stringValue = cell.text
        if let color = cell.color {
            cellView.wantsLayer = true
            cellView.layer?.backgroundColor = color
        }
        cellView.textField?.alignment = cellAlignmentForColumn(columnIdentifier)
        return cellView
    }
    
    func cellAlignmentForColumn(_ columnIdentifier: String) -> NSTextAlignment {
        switch columnIdentifier {
        case "NameColumn", "SpeciesColumn":
            return .left
        default:
            return .center
        }
    }
    
    func cellTextForColumn(_ columnIdentifier: String, row: Int) -> (text: String, color: CGColor?) {
        let thisPokémon = savedPokémon[row]
        
        switch columnIdentifier {
        
        case "NameColumn":
            return ("", nil)
            
        case "SpeciesColumn":
            return (thisPokémon.species, editableCellBackgroundColor)
            
        case "CPColumn":
            return ("\(thisPokémon.cp)", editableCellBackgroundColor)
            
        case "HPColumn":
            return ("\(thisPokémon.hp)", editableCellBackgroundColor)
            
        case "DustColumn":
            return ("\(thisPokémon.dustPrice)", editableCellBackgroundColor)
            
        case "PoweredColumn":
            return (thisPokémon.poweredUp ? "yes" : "no", editableCellBackgroundColor)
            
        case "LevelColumn":
            guard let level = thisPokémon.level else {
                return ("", attributeCellBackgroundColor)
            }
            return ("\(level)", attributeCellBackgroundColor)
            
        case "ATKColumn":
            guard let atk = thisPokémon.atk else {
                return ("", attributeCellBackgroundColor)
            }
            return ("\(atk)", attributeCellBackgroundColor)
            
        case "DEFColumn":
            guard let def = thisPokémon.def else {
                return ("", attributeCellBackgroundColor)
            }
            return ("\(def)", attributeCellBackgroundColor)
            
        case "STAColumn":
            guard let sta = thisPokémon.sta else {
                return ("", attributeCellBackgroundColor)
            }
            return ("\(sta)", attributeCellBackgroundColor)
            
        case "PercentColumn":
            if let ivPercent = thisPokémon.ivPercent {
                return ("\(ivPercent)", backgroundColor(forIvPercent: CGFloat(ivPercent) / CGFloat(100.0)))
            }
            let range = thisPokémon.ivPercentRange
            let color = backgroundColor(forIvPercent: CGFloat(range.max) / CGFloat(100.0))
            return ("\(range.min) - \(range.max)", color)
            
        case "PerfectCPColumn":
            guard let perfectCP = thisPokémon.perfectCP else {
                return ("", maxCpCellBackgroundColor)
            }
            return ("\(perfectCP)", maxCpCellBackgroundColor)
            
        case "PoweredUpCPColumn":
            guard let poweredUpCP = thisPokémon.poweredUpCP else {
                return ("", maxCpCellBackgroundColor)
            }
            return ("\(poweredUpCP)", maxCpCellBackgroundColor)
            
        case "MaxedCPColumn":
            guard let maxCP = thisPokémon.maxCP else {
                return ("", maxCpCellBackgroundColor)
            }
            return ("\(maxCP)", maxCpCellBackgroundColor)
            
        default:
            return ("WHOA", nil)
        }
    }
    
    private func backgroundColor(forIvPercent percent: CGFloat) -> CGColor {
        let bad = rgbFloat(red: 230, green: 124, blue: 115)
        let good = rgbFloat(red: 87, green: 187, blue: 138)
        let white = rgbFloat(red: 255, green: 255, blue: 255)
        let rgb = percent <= 0.5 ? gradient(percent: percent, a: bad, b: white) : gradient(percent: percent - 0.5, a: white, b: good)
        return CGColor(red: rgb.red, green: rgb.green, blue: rgb.blue, alpha: 1.0)
    }
    
    private typealias rgb = (red: CGFloat, green: CGFloat, blue: CGFloat)
    
    private func rgbFloat(red: Int, green: Int, blue: Int) -> rgb {
        let maxScalar = CGFloat(255)
        return (red: CGFloat(red) / maxScalar,
                green: CGFloat(green) / maxScalar,
                blue: CGFloat(blue) / maxScalar)
    }
    
    private func gradient(percent: CGFloat, a: rgb, b: rgb) -> rgb {
        return (red: gradient(percent: percent, a: a.red, b: b.red),
                green: gradient(percent: percent, a: a.green, b: b.green),
                blue: gradient(percent: percent, a: a.blue, b: b.blue))
    }
    
    private func gradient(percent: CGFloat, a: CGFloat, b: CGFloat) -> CGFloat {
        let a1 = a * (0.5 - percent)
        let b1 = b * (percent)
        return (a1 + b1) * 2.0
    }
}
