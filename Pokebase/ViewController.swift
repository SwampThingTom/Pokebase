//
//  ViewController.swift
//  Pokebase
//
//  Created by Thomas Aylesworth on 12/10/16.
//  Copyright © 2016 Thomas H Aylesworth. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSComboBoxDataSource {

    @IBOutlet weak var pokémonField: NSComboBox?
    @IBOutlet weak var cpField: NSTextField?
    @IBOutlet weak var hpField: NSTextField?
    @IBOutlet weak var dustField: NSPopUpButton?
    @IBOutlet weak var isPoweredUpField: NSPopUpButton?
    @IBOutlet weak var resultLabel: NSTextField?
    
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
        guard let pokémonIndex = pokémonField?.indexOfSelectedItem,
            let cp = cpField?.integerValue,
            let hp = hpField?.integerValue,
            let dustString = dustField?.titleOfSelectedItem,
            let dust = Int(dustString) else {
                return
        }
        
        let species = Species.names[pokémonIndex]
        let pokémon = Species(species: species)
        let possibleIVs = pokémon.possibleIVs(cp: cp, hp: hp, dustPrice: dust, poweredUp: false)
        
        resultLabel?.stringValue = statusString(forIVs: possibleIVs)
    }
    
    func statusString(forIVs ivs: [(level: Double, att: Int, def: Int, sta: Int)]) -> String {
        let combinations = ivs.count
        
        if combinations == 0 {
            return "No combinations found"
        }
        
        if combinations > 1 {
            return "There are \(combinations) possible combinations"
        }
        
        let iv = ivs.first!
        return "Level: \(iv.level) Att: \(iv.att) Def: \(iv.def) Sta: \(iv.sta)"
    }
    
    // MARK: - ComboBox Data Source
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return Species.names.count
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return Species.names[index]
    }
}
