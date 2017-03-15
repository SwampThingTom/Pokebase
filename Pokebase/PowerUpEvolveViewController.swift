//
//  PowerUpEvolveViewController.swift
//  Pokebase
//
//  Created by Thomas Aylesworth on 3/4/17.
//  Copyright © 2017 Thomas H Aylesworth. All rights reserved.
//

import Cocoa

protocol PowerUpEvolveDelegate {
    func cancelPowerUpEvolve()
    func updateAfterPowerUpEvolve(pokémon: Pokémon)
}

class PowerUpEvolveViewController: NSViewController {

    var delegate: PowerUpEvolveDelegate?
    var pokémon: Pokémon?
    
    @IBOutlet weak var species: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        delegate?.cancelPowerUpEvolve()
    }
    
    @IBAction func ok(_ sender: AnyObject) {
        delegate?.updateAfterPowerUpEvolve(pokémon: pokémon!)
    }
}
