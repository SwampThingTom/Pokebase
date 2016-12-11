//
//  ViewController.swift
//  Pokebase
//
//  Created by Thomas Aylesworth on 12/10/16.
//  Copyright © 2016 Thomas H Aylesworth. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSComboBoxDataSource, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var pokémonField: NSComboBox?
    @IBOutlet weak var cpField: NSTextField?
    @IBOutlet weak var hpField: NSTextField?
    @IBOutlet weak var dustField: NSPopUpButton?
    @IBOutlet weak var isPoweredUpField: NSPopUpButton?
    @IBOutlet weak var resultLabel: NSTextField?
    @IBOutlet weak var tableView: NSTableView?
    
    private var savedPokémon = [Pokémon]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pokémonField?.selectItem(at: 0)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func calculateIVs(sender: NSButton) {
        guard let pokémon = newPokémon(), let possibleIVs = pokémon.possibleIVs else {
            return
        }
        resultLabel?.stringValue = statusString(forIVs: possibleIVs)
    }
    
    @IBAction func savePokémon(sender: NSButton) {
        guard let pokémon = newPokémon() else {
            return
        }
        savedPokémon.append(pokémon)
        self.tableView?.reloadData()
    }
    
    private func newPokémon() -> Pokémon? {
        guard let pokémonIndex = pokémonField?.indexOfSelectedItem,
            let cp = cpField?.integerValue,
            let hp = hpField?.integerValue,
            let dustString = dustField?.titleOfSelectedItem,
            let dust = Int(dustString) else {
                return nil
        }
        
        let species = Species.names[pokémonIndex]
        var pokémon = Pokémon(species: species, cp: cp, hp: hp, dustPrice: dust, poweredUp: false)
        pokémon.derivePossibleIVs()
        return pokémon
    }
    
    private func statusString(forIVs ivs: [IndividualValues]) -> String {
        let combinations = ivs.count
        
        if combinations == 0 {
            return "No combinations found"
        }
        
        if combinations > 1 {
            return "There are \(combinations) possible combinations"
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
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let columnIdentifier = tableColumn?.identifier else {
            return nil
        }
        
        guard let cellView = tableView.make(withIdentifier: columnIdentifier, owner: self) as? NSTableCellView else {
            return nil
        }
        
        cellView.textField?.stringValue = cellTextForColumn(columnIdentifier, row: row)
        return cellView
    }
    
    func cellTextForColumn(_ columnIdentifier: String, row: Int) -> String {
        let thisPokémon = savedPokémon[row]
        
        switch columnIdentifier {
        
        case "NameColumn":
            return ""
            
        case "SpeciesColumn":
            return thisPokémon.species
            
        case "CPColumn":
            return "\(thisPokémon.cp)"
            
        case "HPColumn":
            return "\(thisPokémon.hp)"
            
        case "DustColumn":
            return "\(thisPokémon.dustPrice)"
            
        case "PoweredColumn":
            return thisPokémon.poweredUp ? "yes" : "no"
            
        case "LevelColumn":
            guard let level = thisPokémon.level else {
                return ""
            }
            return "\(level)"
            
        case "ATKColumn":
            guard let atk = thisPokémon.atk else {
                return ""
            }
            return "\(atk)"
            
        case "DEFColumn":
            guard let def = thisPokémon.def else {
                return ""
            }
            return "\(def)"
            
        case "STAColumn":
            guard let sta = thisPokémon.sta else {
                return ""
            }
            return "\(sta)"
            
        case "PercentColumn":
            guard let ivPercent = thisPokémon.ivPercent else {
                return ""
            }
            return "\(ivPercent)"
            
        case "PerfectCPColumn":
            guard let perfectCP = thisPokémon.perfectCP else {
                return ""
            }
            return "\(perfectCP)"
            
        case "PoweredUpCPColumn":
            guard let poweredUpCP = thisPokémon.poweredUpCP else {
                return ""
            }
            return "\(poweredUpCP)"
            
        case "MaxedCPColumn":
            guard let maxCP = thisPokémon.maxCP else {
                return ""
            }
            return "\(maxCP)"
            
        default:
            return "WHOA"
        }
    }

}
