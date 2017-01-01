//
//  ViewController.swift
//  Pokebase
//
//  Created by Thomas Aylesworth on 12/10/16.
//  Copyright © 2016 Thomas H Aylesworth. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSControlTextEditingDelegate, NSComboBoxDataSource, NSComboBoxDelegate, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var trainerLevelField: NSTextField!
    @IBOutlet weak var pokémonField: NSComboBox!
    @IBOutlet weak var cpField: NSTextField!
    @IBOutlet weak var hpField: NSTextField!
    @IBOutlet weak var dustField: NSPopUpButton!
    @IBOutlet weak var isPoweredUpField: NSPopUpButton!
    @IBOutlet weak var appraisalField: NSPopUpButton!
    @IBOutlet weak var isAttBestField: NSButton!
    @IBOutlet weak var isDefBestField: NSButton!
    @IBOutlet weak var isHpBestField: NSButton!
    @IBOutlet weak var bestStatField: NSPopUpButton!
    @IBOutlet weak var resultLabel: NSTextField!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    
    private var savedPokémon = PokémonBox()
    
    private var selectedAppraisal: StatsAppraisal.Appraisal {
        get {
            guard let appraisal = StatsAppraisal.Appraisal(rawValue: appraisalField.indexOfSelectedItem) else {
                return StatsAppraisal.Appraisal.Unknown
            }
            return appraisal
        }
    }
    
    private var selectedBestStat: StatsAppraisal.BestStat {
        get {
            guard let bestStat = StatsAppraisal.BestStat(rawValue: bestStatField.indexOfSelectedItem) else {
                return StatsAppraisal.BestStat.Best
            }
            return bestStat
        }
    }
    
    private var isAtkBest: Bool {
        get {
            return isAttBestField.state == NSOnState
        }
    }
    
    private var isDefBest: Bool {
        get {
            return isDefBestField.state == NSOnState
        }
    }
    
    private var isStaBest: Bool {
        get {
            return isHpBestField.state == NSOnState
        }
    }
    
    private var appraisal: StatsAppraisal {
        get {
            if selectedAppraisal == .Unknown {
                return StatsAppraisal.None
            }
            return StatsAppraisal(appraisal: selectedAppraisal,
                                  bestStat: selectedBestStat,
                                  atk: isAtkBest,
                                  def: isDefBest,
                                  sta: isStaBest)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trainerLevelField.stringValue = "\(savedPokémon.trainerLevel)"
        pokémonField.selectItem(at: 0)
        statusLabel.stringValue = statusString()
        tableView.sortDescriptors = [NSSortDescriptor(key: "pokédex", ascending: true)]
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func importFromCsv() {
        let fileSelectionPanel = NSOpenPanel.init()
        fileSelectionPanel.begin { (result) in
            if result != NSFileHandlingPanelOKButton {
                return
            }
            
            guard let fileUrl = fileSelectionPanel.urls.first else {
                return
            }
            
            self.savedPokémon.importFromCsv(file: fileUrl)
            self.refresh()
        }
    }
    
    @IBAction func calculateIVs(sender: NSButton) {
        guard let ivCalculator = ivCalculator() else {
            return
        }
        
        let possibleIVs = ivCalculator.derivePossibleIVs()
        resultLabel.stringValue = ivResultString(forIVs: possibleIVs)
    }
    
    @IBAction func savePokémon(sender: NSButton) {
        guard let ivCalculator = ivCalculator() else {
                return
        }
        
        let pokémon = Pokémon(ivCalculator)
        savedPokémon.add(pokémon)
        savedPokémon.sort(using: tableView.sortDescriptors)
        refresh()
    }
    
    @IBAction func removePokémon(_ sender: NSButton) {
        let remove = confirm(question: "Are you sure you want to remove this Pokémon?",
                             text: "This can not be undone")
        if remove {
            let index = tableView.row(for: sender)
            savedPokémon.remove(at: index)
            refresh()
        }
    }
    
    private func confirm(question: String, text: String) -> Bool {
        let alert: NSAlert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = NSAlertStyle.warning
        alert.addButton(withTitle: "Yes")
        alert.addButton(withTitle: "No")
        return alert.runModal() == NSAlertFirstButtonReturn
    }
    
    private func ivCalculator() -> IVCalculator? {
        guard let dustString = dustField.titleOfSelectedItem,
            let dust = Int(dustString) else {
                return nil
        }
        
        let pokémonIndex = pokémonField.indexOfSelectedItem
        if pokémonIndex < 0 {
            return nil
        }
        
        let species = Species.names[pokémonIndex]
        let cp = cpField.integerValue
        let hp = hpField.integerValue
        let poweredUp = isPoweredUpField.titleOfSelectedItem == "Yes"
        
        let calculator = IVCalculator(species: species,
                                      cp: cp,
                                      hp: hp,
                                      dustPrice: dust,
                                      poweredUp: poweredUp,
                                      appraisal: appraisal)
        return calculator
    }
    
    private func ivResultString(forIVs ivs: [IndividualValues]) -> String {
        let combinations = ivs.count
        
        if combinations == 0 {
            return "No combinations found"
        }
        
        if combinations > 1 {
            let range = ivs.reduce((min: 100, max: 0), { (range, ivs) -> MinMaxRange in
                let perfection = Pokémon.percentOfMax(ivs: ivs)
                return (min: min(range.min, perfection), max: max(range.max, perfection))
            })
            return "There are \(combinations) possible combinations with an IV range of \(range.min) - \(range.max)"
        }
        
        let iv = ivs.first!
        let perfection = Pokémon.percentOfMax(ivs: iv)
        return "Level: \(iv.level) ATK: \(iv.atk) DEF: \(iv.def) STA: \(iv.sta) Perfection: \(perfection)"
    }
    
    private func refresh() {
        tableView.reloadData()
        statusLabel.stringValue = statusString()
    }
    
    private func statusString() -> String {
        let numberOfPokémon = savedPokémon.count
        let numberOfSpecies = savedPokémon.uniqueSpeciesCount
        return "Total Pokémon: \(numberOfPokémon)     Unique Species: \(numberOfSpecies)"
    }
    
    // MARK: - Appraisal
    
    @IBAction func appraisalChanged(_ sender: NSPopUpButton) {
        let enableAppraisal = sender.indexOfSelectedItem != StatsAppraisal.Appraisal.Unknown.rawValue
        isAttBestField.isEnabled = enableAppraisal
        isDefBestField.isEnabled = enableAppraisal
        isHpBestField.isEnabled = enableAppraisal
        bestStatField.isEnabled = enableAppraisal
    }
    
    // MARK: - NSControlTextEditingDelegate
    
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        guard let identifier = control.identifier else {
            return true
        }
        
        switch(identifier) {
        case "trainerLevelField":
            return trainerLevelFieldShouldEndEditing()
        case "ivCalcSpeciesField":
            return ivCalcSpeciesFieldShouldEndEditing()
        default:
            return true
        }
    }
    
    func trainerLevelFieldShouldEndEditing() -> Bool {
        let level = trainerLevelField.integerValue
        if level < 1 || level > 40 {
            return false
        }
        
        savedPokémon.trainerLevel = level
        refresh()
        return true
    }
    
    func ivCalcSpeciesFieldShouldEndEditing() -> Bool {
        guard let speciesIndex = Species.names.index(of: pokémonField.stringValue) else {
            return false
        }
        
        pokémonField.selectItem(at: speciesIndex)
        return true
    }
    
    // MARK: - ComboBox Data Source
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return Species.names.count
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return Species.names[index]
    }
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        let pokémonIndex = pokémonField.indexOfSelectedItem
        if pokémonIndex < 0 {
            return
        }
        
        let species = Species.names[pokémonIndex]
        scroll(toSpecies: species)
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
        
        let cell = cellTextForColumn(columnIdentifier, row: row)
        cellView.textField?.stringValue = cell.text
        cellView.textField?.alignment = cellAlignmentForColumn(columnIdentifier)
        cellView.wantsLayer = cell.color != nil
        cellView.layer?.backgroundColor = cell.color
        return cellView
    }
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        savedPokémon.sort(using: tableView.sortDescriptors)
        tableView.reloadData()
    }
    
    func scroll(toSpecies species: String) {
        guard let speciesRow = savedPokémon.indexOfFirst(species: species) else {
            return
        }
        
        guard let visibleRows = visibleRows() else {
            return
        }
        
        if visibleRows.contains(speciesRow) {
            return
        }
        
        let headerHeight = tableView.headerView?.headerRect(ofColumn: 0).height ?? 0
        let rowRect = tableView.rect(ofRow: speciesRow)
        let rowOrigin = CGPoint(x: rowRect.origin.x,
                                y: rowRect.origin.y - headerHeight)
        tableView.scroll(rowOrigin)
    }
    
    func visibleRows() -> Range<Int>? {
        let visibleRect = tableView.visibleRect
        let visibleRows = tableView.rows(in: visibleRect)
        return visibleRows.toRange()
    }
    
    /// MARK: - TableView Cell Configuration
    
    private func cellAlignmentForColumn(_ columnIdentifier: String) -> NSTextAlignment {
        switch columnIdentifier {
        case "NameColumn", "SpeciesColumn":
            return .left
        default:
            return .center
        }
    }
    
    private let editableCellBackgroundColor = CGColor(red: 255.0 / 255.0, green: 250.0 / 255.0, blue: 205.0 / 255.0, alpha: 1.0)
    private let attributeCellBackgroundColor = CGColor(red: 190.0 / 255.0, green: 227.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
    private let maxCpCellBackgroundColor = CGColor(red: 240.0 / 255.0, green: 240.0 / 255.0, blue: 240.0 / 255.0, alpha: 1.0)
    
    private func cellTextForColumn(_ columnIdentifier: String, row: Int) -> (text: String, color: CGColor?) {
        let thisPokémon = savedPokémon[row]
        
        switch columnIdentifier {
        
        case "NameColumn":
            guard let name = thisPokémon.name else {
                return ("", editableCellBackgroundColor)
            }
            return (name, editableCellBackgroundColor)
            
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
            if range.max < range.min {
                return ("unknown", nil)
            }
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
            
        case "RemoveColumn":
            return ("", nil)
            
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
