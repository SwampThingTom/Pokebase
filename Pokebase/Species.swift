//
//  Species.swift
//  Pokebase
//
//  Created by Thomas Aylesworth on 12/10/16.
//  Copyright © 2016 Thomas H Aylesworth. All rights reserved.
//

import Foundation

typealias IndividualValues = (level: Double, atk: Int, def: Int, sta: Int)

struct Species {
    
    /// Names of all of the known species.
    static let names: [String] = {
        return gen1Data.map { data in data.0 }
    }()
    
    /// Map of power-up stardust cost to minimum Pokémon level.
    static let levelForStardust: [Int:Double] = {
        return Dictionary(levels)
    }()
    
    /// Map of Pokémon level to CP multiplier.
    static let cpMultiplierForLevel: [Double:Double] = {
        return Dictionary(cpMultipliers)
    }()
    
    /// Base statistics for a Pokémon species.
    ///
    /// - parameter species: Pokémon species
    ///
    /// - returns: base attack, defense, and stamina values
    static func baseStats(forSpecies species: String) -> (atk: Int, def: Int, sta: Int)? {
        guard let data = baseStats[species] else {
            return nil
        }
        return (atk: data.atk, def: data.def, sta: data.sta)
    }
    
    /// The final evolution for a Pokémon species.
    ///
    /// - parameter species: Pokémon species
    ///
    /// - returns: final evolution species
    static func finalEvolution(forSpecies species: String) -> String? {
        guard let data = baseStats[species] else {
            return nil
        }
        guard let evolution = data.evolution else {
            return species
        }
        return finalEvolution(forSpecies: evolution)
    }
    
    // MARK: - Base Stats
    
    private static let gen1Data: Array<(String,Int,Int,Int,String?)> = [
        ("Bulbasaur",118,118,90,"Venusaur"),
        ("Ivysaur",151,151,120,"Venusaur"),
        ("Venusaur",198,198,160,nil),
        ("Charmander",116,96,78,"Charizard"),
        ("Charmeleon",158,129,116,"Charizard"),
        ("Charizard",223,176,156,nil),
        ("Squirtle",94,122,88,"Blastoise"),
        ("Wartortle",126,155,118,"Blastoise"),
        ("Blastoise",171,210,158,nil),
        ("Caterpie",55,62,90,"Butterfree"),
        ("Metapod",45,94,100,"Butterfree"),
        ("Butterfree",167,151,120,nil),
        ("Weedle",63,55,80,"Beedrill"),
        ("Kakuna",46,86,90,"Beedrill"),
        ("Beedrill",169,150,130,nil),
        ("Pidgey",85,76,80,"Pidgeot"),
        ("Pidgeotto",117,108,126,"Pidgeot"),
        ("Pidgeot",166,157,166,nil),
        ("Rattata",103,70,60,"Raticate"),
        ("Raticate",161,144,110,nil),
        ("Spearow",112,61,80,"Fearow"),
        ("Fearow",182,135,130,nil),
        ("Ekans",110,102,70,"Arbok"),
        ("Arbok",167,158,120,nil),
        ("Pikachu",112,101,70,"Raichu"),
        ("Raichu",193,165,120,nil),
        ("Sandshrew",126,145,100,"Sandslash"),
        ("Sandslash",182,202,150,nil),
        ("Nidoran♀",86,94,110,"Nidoqueen"),
        ("Nidorina",117,126,140,"Nidoqueen"),
        ("Nidoqueen",180,174,180,nil),
        ("Nidoran♂",105,76,92,"Nidoking"),
        ("Nidorino",137,112,122,"Nidoking"),
        ("Nidoking",204,157,162,nil),
        ("Clefairy",107,116,140,"Clefable"),
        ("Clefable",178,171,190,nil),
        ("Vulpix",96,122,76,"Ninetales"),
        ("Ninetales",169,204,146,nil),
        ("Jigglypuff",80,44,230,"Wigglytuff"),
        ("Wigglytuff",156,93,280,nil),
        ("Zubat",83,76,80,"Golbat"),
        ("Golbat",161,153,150,nil),
        ("Oddish",131,116,90,"Vileplume"),
        ("Gloom",153,139,120,"Vileplume"),
        ("Vileplume",202,170,150,nil),
        ("Paras",121,99,70,"Parasect"),
        ("Parasect",165,146,120,nil),
        ("Venonat",100,102,120,"Venomoth"),
        ("Venomoth",179,150,140,nil),
        ("Diglett",109,88,20,"Dugtrio"),
        ("Dugtrio",167,147,70,nil),
        ("Meowth",92,81,80,"Persian"),
        ("Persian",150,139,130,nil),
        ("Psyduck",122,96,100,"Golduck"),
        ("Golduck",191,163,160,nil),
        ("Mankey",148,87,80,"Primeape"),
        ("Primeape",207,144,130,nil),
        ("Growlithe",136,96,110,"Arcanine"),
        ("Arcanine",227,166,180,nil),
        ("Poliwag",101,82,80,"Poliwrath"),
        ("Poliwhirl",130,130,130,"Poliwrath"),
        ("Poliwrath",182,187,180,nil),
        ("Abra",195,103,50,"Alakazam"),
        ("Kadabra",232,138,80,"Alakazam"),
        ("Alakazam",271,194,110,nil),
        ("Machop",137,88,140,"Machamp"),
        ("Machoke",177,130,160,"Machamp"),
        ("Machamp",234,162,180,nil),
        ("Bellsprout",139,64,100,"Victreebel"),
        ("Weepinbell",172,95,130,"Victreebel"),
        ("Victreebel",207,138,160,nil),
        ("Tentacool",97,182,80,"Tentacruel"),
        ("Tentacruel",166,237,160,nil),
        ("Geodude",132,163,80,"Graveler"),
        ("Graveler",164,196,110,"Golem"),
        ("Golem",211,229,160,nil),
        ("Ponyta",170,132,100,"Rapidash"),
        ("Rapidash",207,167,130,nil),
        ("Slowpoke",109,109,180,"Slowbro"),
        ("Slowbro",177,194,190,nil),
        ("Magnemite",165,128,50,"Magneton"),
        ("Magneton",223,182,100,nil),
        ("Farfetch'd",124,118,104,nil),
        ("Doduo",158,88,70,"Dodrio"),
        ("Dodrio",218,145,120,nil),
        ("Seel",85,128,130,"Dewgong"),
        ("Dewgong",139,184,180,nil),
        ("Grimer",135,90,160,"Muk"),
        ("Muk",190,184,210,nil),
        ("Shellder",116,168,60,"Cloyster"),
        ("Cloyster",186,323,100,nil),
        ("Gastly",186,70,60,"Haunter"),
        ("Haunter",223,112,90,"Gengar"),
        ("Gengar",261,156,120,nil),
        ("Onix",85,288,70,nil),
        ("Drowzee",89,158,120,"Hypno"),
        ("Hypno",144,215,170,nil),
        ("Krabby",181,156,60,"Kingler"),
        ("Kingler",240,214,110,nil),
        ("Voltorb",109,114,80,"Electrode"),
        ("Electrode",173,179,120,nil),
        ("Exeggcute",107,140,120,"Exeggutor"),
        ("Exeggutor",233,158,190,nil),
        ("Cubone",90,165,100,"Marowak"),
        ("Marowak",144,200,120,nil),
        ("Hitmonlee",224,211,100,nil),
        ("Hitmonchan",193,212,100,nil),
        ("Lickitung",108,137,180,nil),
        ("Koffing",119,164,80,"Weezing"),
        ("Weezing",174,221,130,nil),
        ("Rhyhorn",140,157,160,"Rhydon"),
        ("Rhydon",222,206,210,nil),
        ("Chansey",60,176,500,nil),
        ("Tangela",183,205,130,nil),
        ("Kangaskhan",181,165,210,nil),
        ("Horsea",129,125,60,"Seadra"),
        ("Seadra",187,182,110,nil),
        ("Goldeen",123,115,90,"Seaking"),
        ("Seaking",175,154,160,nil),
        ("Staryu",137,112,60,"Starmie"),
        ("Starmie",210,184,120,nil),
        ("Mr. Mime",192,233,80,nil),
        ("Scyther",218,170,140,nil),
        ("Jynx",223,182,130,nil),
        ("Electabuzz",198,173,130,nil),
        ("Magmar",206,169,130,nil),
        ("Pinsir",238,197,130,nil),
        ("Tauros",198,197,150,nil),
        ("Magikarp",29,102,40,"Gyarados"),
        ("Gyarados",237,197,190,nil),
        ("Lapras",186,190,260,nil),
        ("Ditto",91,91,96,nil),
        ("Eevee",104,121,110,"Vaporeon"),
        ("Vaporeon",205,177,260,nil),
        ("Jolteon",232,201,130,nil),
        ("Flareon",246,204,130,nil),
        ("Porygon",153,139,130,nil),
        ("Omanyte",155,174,70,"Omastar"),
        ("Omastar",207,227,140,nil),
        ("Kabuto",148,162,60,"Kabutops"),
        ("Kabutops",220,203,120,nil),
        ("Aerodactyl",221,164,160,nil),
        ("Snorlax",190,190,320,nil),
        ("Articuno",192,249,180,nil),
        ("Zapdos",253,188,180,nil),
        ("Moltres",251,184,180,nil),
        ("Dratini",119,94,82,"Dragonite"),
        ("Dragonair",163,138,122,"Dragonite"),
        ("Dragonite",263,201,182,nil),
        ("Mewtwo",330,200,212,nil),
        ("Mew",210,210,200,nil)];
    
    private static let baseStats = {
        return Dictionary(gen1Data.map { data in (data.0, (atk: data.1, def: data.2, sta: data.3, evolution: data.4)) })
    }()
    
    // MARK: - Levels
    
    private static let levels: Array<(Int,Double)> = [
        (200, 1),
        (400, 3),
        (600, 5),
        (800, 7),
        (1000, 9),
        (1300, 11),
        (1600, 13),
        (1900, 15),
        (2200, 17),
        (2500, 19),
        (3000, 21),
        (3500, 23),
        (4000, 25),
        (4500, 27),
        (5000, 29),
        (6000, 31),
        (7000, 33),
        (8000, 35),
        (9000, 37),
        (10000, 39)
    ]
    
    // MARK: - CP Multiplier
    
    private static let cpMultipliers: Array<(Double,Double)> = [
        (1, 0.0940000),
        (1.5, 0.1351374),
        (2, 0.1663979),
        (2.5, 0.1926509),
        (3, 0.2157325),
        (3.5, 0.2365727),
        (4, 0.2557201),
        (4.5, 0.2735304),
        (5, 0.2902499),
        (5.5, 0.3060574),
        (6, 0.3210876),
        (6.5, 0.3354450),
        (7, 0.3492127),
        (7.5, 0.3624578),
        (8, 0.3752356),
        (8.5, 0.3875924),
        (9, 0.3995673),
        (9.5, 0.4111936),
        (10, 0.4225000),
        (10.5, 0.4335117),
        (11, 0.4431076),
        (11.5, 0.4530600),
        (12, 0.4627984),
        (12.5, 0.4723361),
        (13, 0.4816850),
        (13.5, 0.4908558),
        (14, 0.4998584),
        (14.5, 0.5087018),
        (15, 0.5173940),
        (15.5, 0.5259425),
        (16, 0.5343543),
        (16.5, 0.5426358),
        (17, 0.5507927),
        (17.5, 0.5588306),
        (18, 0.5667545),
        (18.5, 0.5745692),
        (19, 0.5822789),
        (19.5, 0.5898879),
        (20, 0.5974000),
        (20.5, 0.6048188),
        (21, 0.6121573),
        (21.5, 0.6194041),
        (22, 0.6265671),
        (22.5, 0.6336492),
        (23, 0.6406530),
        (23.5, 0.6475810),
        (24, 0.6544356),
        (24.5, 0.6612193),
        (25, 0.6679340),
        (25.5, 0.6745819),
        (26, 0.6811649),
        (26.5, 0.6876849),
        (27, 0.6941437),
        (27.5, 0.7005429),
        (28, 0.7068842),
        (28.5, 0.7131691),
        (29, 0.7193991),
        (29.5, 0.7255756),
        (30, 0.7317000),
        (30.5, 0.7377735),
        (31, 0.7377695),
        (31.5, 0.7407856),
        (32, 0.7437894),
        (32.5, 0.7467812),
        (33, 0.7497610),
        (33.5, 0.7527291),
        (34, 0.7556855),
        (34.5, 0.7586304),
        (35, 0.7615638),
        (35.5, 0.7644861),
        (36, 0.7673972),
        (36.5, 0.7702973),
        (37, 0.7731865),
        (37.5, 0.7760650),
        (38, 0.7789328),
        (38.5, 0.7817901),
        (39, 0.7846370),
        (39.5, 0.7874736),
        (40, 0.7903000),
        (40.5, 0.7931164)
    ]
}
