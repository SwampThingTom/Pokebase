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
        return rawData.map { data in data.0 }
    }()
    
    /// Names of all gen 1 species.
    static let gen1: [String] = {
        let gen1Data = rawData.prefix(upTo: 151)
        let available = gen1Data.filter({ return $0.5 })
        return available.map { data in data.0 }
    }()
    
    /// Names of all gen 2 species.
    static let gen2: [String] = {
        let gen2Data = rawData.suffix(from: 151)
        let available = gen2Data.filter({ return $0.5 })
        return available.map { data in data.0 }
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
    
    /// Base stats by Pokédex index.
    ///
    /// Tuple: (name, att, def, sta, final evolution)
    private static let rawData: Array<(String,Int,Int,Int,String?,Bool)> = [
        
        // Gen 1
        
        ("Bulbasaur",118,118,90,"Venusaur",true),
        ("Ivysaur",151,151,120,"Venusaur",true),
        ("Venusaur",198,198,160,nil,true),
        ("Charmander",116,96,78,"Charizard",true),
        ("Charmeleon",158,129,116,"Charizard",true),
        ("Charizard",223,176,156,nil,true),
        ("Squirtle",94,122,88,"Blastoise",true),
        ("Wartortle",126,155,118,"Blastoise",true),
        ("Blastoise",171,210,158,nil,true),
        ("Caterpie",55,62,90,"Butterfree",true),
        ("Metapod",45,94,100,"Butterfree",true),
        ("Butterfree",167,151,120,nil,true),
        ("Weedle",63,55,80,"Beedrill",true),
        ("Kakuna",46,86,90,"Beedrill",true),
        ("Beedrill",169,150,130,nil,true),
        ("Pidgey",85,76,80,"Pidgeot",true),
        ("Pidgeotto",117,108,126,"Pidgeot",true),
        ("Pidgeot",166,157,166,nil,true),
        ("Rattata",103,70,60,"Raticate",true),
        ("Raticate",161,144,110,nil,true),
        ("Spearow",112,61,80,"Fearow",true),
        ("Fearow",182,135,130,nil,true),
        ("Ekans",110,102,70,"Arbok",true),
        ("Arbok",167,158,120,nil,true),
        ("Pikachu",112,101,70,"Raichu",true),
        ("Raichu",193,165,120,nil,true),
        ("Sandshrew",126,145,100,"Sandslash",true),
        ("Sandslash",182,202,150,nil,true),
        ("Nidoran♀",86,94,110,"Nidoqueen",true),
        ("Nidorina",117,126,140,"Nidoqueen",true),
        ("Nidoqueen",180,174,180,nil,true),
        ("Nidoran♂",105,76,92,"Nidoking",true),
        ("Nidorino",137,112,122,"Nidoking",true),
        ("Nidoking",204,157,162,nil,true),
        ("Clefairy",107,116,140,"Clefable",true),
        ("Clefable",178,171,190,nil,true),
        ("Vulpix",96,122,76,"Ninetales",true),
        ("Ninetales",169,204,146,nil,true),
        ("Jigglypuff",80,44,230,"Wigglytuff",true),
        ("Wigglytuff",156,93,280,nil,true),
        ("Zubat",83,76,80,"Crobat",true),
        ("Golbat",161,153,150,"Crobat",true),
        ("Oddish",131,116,90,"Vileplume",true),    // TODO: Bellossom?
        ("Gloom",153,139,120,"Vileplume",true),    // TODO: Bellossom?
        ("Vileplume",202,170,150,nil,true),
        ("Paras",121,99,70,"Parasect",true),
        ("Parasect",165,146,120,nil,true),
        ("Venonat",100,102,120,"Venomoth",true),
        ("Venomoth",179,150,140,nil,true),
        ("Diglett",109,88,20,"Dugtrio",true),
        ("Dugtrio",167,147,70,nil,true),
        ("Meowth",92,81,80,"Persian",true),
        ("Persian",150,139,130,nil,true),
        ("Psyduck",122,96,100,"Golduck",true),
        ("Golduck",191,163,160,nil,true),
        ("Mankey",148,87,80,"Primeape",true),
        ("Primeape",207,144,130,nil,true),
        ("Growlithe",136,96,110,"Arcanine",true),
        ("Arcanine",227,166,180,nil,true),
        ("Poliwag",101,82,80,"Poliwrath",true),        // TODO: Politoed?
        ("Poliwhirl",130,130,130,"Poliwrath",true),    // TODO: Politoed?
        ("Poliwrath",182,187,180,nil,true),
        ("Abra",195,103,50,"Alakazam",true),
        ("Kadabra",232,138,80,"Alakazam",true),
        ("Alakazam",271,194,110,nil,true),
        ("Machop",137,88,140,"Machamp",true),
        ("Machoke",177,130,160,"Machamp",true),
        ("Machamp",234,162,180,nil,true),
        ("Bellsprout",139,64,100,"Victreebel",true),
        ("Weepinbell",172,95,130,"Victreebel",true),
        ("Victreebel",207,138,160,nil,true),
        ("Tentacool",97,182,80,"Tentacruel",true),
        ("Tentacruel",166,237,160,nil,true),
        ("Geodude",132,163,80,"Graveler",true),
        ("Graveler",164,196,110,"Golem",true),
        ("Golem",211,229,160,nil,true),
        ("Ponyta",170,132,100,"Rapidash",true),
        ("Rapidash",207,167,130,nil,true),
        ("Slowpoke",109,109,180,"Slowbro",true),      // TODO: Slowking?
        ("Slowbro",177,194,190,nil,true),
        ("Magnemite",165,128,50,"Magneton",true),
        ("Magneton",223,182,100,nil,true),
        ("Farfetch'd",124,118,104,nil,true),
        ("Doduo",158,88,70,"Dodrio",true),
        ("Dodrio",218,145,120,nil,true),
        ("Seel",85,128,130,"Dewgong",true),
        ("Dewgong",139,184,180,nil,true),
        ("Grimer",135,90,160,"Muk",true),
        ("Muk",190,184,210,nil,true),
        ("Shellder",116,168,60,"Cloyster",true),
        ("Cloyster",186,323,100,nil,true),
        ("Gastly",186,70,60,"Haunter",true),
        ("Haunter",223,112,90,"Gengar",true),
        ("Gengar",261,156,120,nil,true),
        ("Onix",85,288,70,"Steelix",true),
        ("Drowzee",89,158,120,"Hypno",true),
        ("Hypno",144,215,170,nil,true),
        ("Krabby",181,156,60,"Kingler",true),
        ("Kingler",240,214,110,nil,true),
        ("Voltorb",109,114,80,"Electrode",true),
        ("Electrode",173,179,120,nil,true),
        ("Exeggcute",107,140,120,"Exeggutor",true),
        ("Exeggutor",233,158,190,nil,true),
        ("Cubone",90,165,100,"Marowak",true),
        ("Marowak",144,200,120,nil,true),
        ("Hitmonlee",224,211,100,nil,true),
        ("Hitmonchan",193,212,100,nil,true),
        ("Lickitung",108,137,180,nil,true),
        ("Koffing",119,164,80,"Weezing",true),
        ("Weezing",174,221,130,nil,true),
        ("Rhyhorn",140,157,160,"Rhydon",true),
        ("Rhydon",222,206,210,nil,true),
        ("Chansey",60,176,500,"Blissey",true),
        ("Tangela",183,205,130,nil,true),
        ("Kangaskhan",181,165,210,nil,true),
        ("Horsea",129,125,60,"Kingdra",true),
        ("Seadra",187,182,110,"Kingdra",true),
        ("Goldeen",123,115,90,"Seaking",true),
        ("Seaking",175,154,160,nil,true),
        ("Staryu",137,112,60,"Starmie",true),
        ("Starmie",210,184,120,nil,true),
        ("Mr. Mime",192,233,80,nil,true),
        ("Scyther",218,170,140,"Scizor",true),
        ("Jynx",223,182,130,nil,true),
        ("Electabuzz",198,173,130,nil,true),
        ("Magmar",206,169,130,nil,true),
        ("Pinsir",238,197,130,nil,true),
        ("Tauros",198,197,150,nil,true),
        ("Magikarp",29,102,40,"Gyarados",true),
        ("Gyarados",237,197,190,nil,true),
        ("Lapras",165,180,260,nil,true),
        ("Ditto",91,91,96,nil,true),
        ("Eevee",104,121,110,"Vaporeon",true),       // TODO: Espeon? Umbreon?
        ("Vaporeon",205,177,260,nil,true),
        ("Jolteon",232,201,130,nil,true),
        ("Flareon",246,204,130,nil,true),
        ("Porygon",153,139,130,"Porygon2",true),
        ("Omanyte",155,174,70,"Omastar",true),
        ("Omastar",207,227,140,nil,true),
        ("Kabuto",148,162,60,"Kabutops",true),
        ("Kabutops",220,203,120,nil,true),
        ("Aerodactyl",221,164,160,nil,true),
        ("Snorlax",190,190,320,nil,true),
        ("Articuno",192,249,180,nil,false),
        ("Zapdos",253,188,180,nil,false),
        ("Moltres",251,184,180,nil,false),
        ("Dratini",119,94,82,"Dragonite",true),
        ("Dragonair",163,138,122,"Dragonite",true),
        ("Dragonite",263,201,182,nil,true),
        ("Mewtwo",330,200,212,nil,false),
        ("Mew",210,210,200,nil,false),
        
        // Gen 2
        
        ("Chikorita",92,122,90,"Meganium",true),
        ("Bayleef",122,155,120,"Meganium",true),
        ("Meganium",168,202,160,nil,true),
        ("Cyndaquil",116,96,78,"Typhlosion",true),
        ("Quilava",158,129,116,"Typhlosion",true),
        ("Typhlosion",223,176,156,nil,true),
        ("Totodile",117,116,100,"Feraligatr",true),
        ("Croconaw",150,151,130,"Feraligatr",true),
        ("Feraligatr",205,197,170,nil,true),
        ("Sentret",79,77,70,"Furret",true),
        ("Furret",148,130,170,nil,true),
        ("Hoothoot",67,101,120,"Noctowl",true),
        ("Noctowl",145,179,200,nil,true),
        ("Ledyba",72,142,80,"Ledian",true),
        ("Ledian",107,209,110,nil,true),
        ("Spinarak",105,73,80,"Ariados",true),
        ("Ariados",161,128,140,nil,true),
        ("Crobat",194,178,170,nil,true),
        ("Chinchou",106,106,150,"Lanturn",true),
        ("Lanturn",146,146,250,nil,true),
        ("Pichu",77,63,40,"Raichu",true),
        ("Cleffa",75,91,100,"Clefable",true),
        ("Igglybuff",69,34,180,"Wigglytuff",true),
        ("Togepi",67,116,70,"Togetic",true),
        ("Togetic",139,191,110,nil,true),
        ("Natu",134,89,80,"Xatu",true),
        ("Xatu",192,146,130,nil,true),
        ("Mareep",114,82,110,"Ampharos",true),
        ("Flaaffy",145,112,140,"Ampharos",true),
        ("Ampharos",211,172,180,nil,true),
        ("Bellossom",169,189,150,nil,true),
        ("Marill",37,93,140,"Azumarill",true),
        ("Azumarill",112,152,200,nil,true),
        ("Sudowoodo",167,198,140,nil,true),
        ("Politoed",174,192,180,nil,true),
        ("Hoppip",67,101,70,"Jumpluff",true),
        ("Skiploom",91,127,110,"Jumpluff",true),
        ("Jumpluff",118,197,150,nil,true),
        ("Aipom",136,112,110,nil,true),
        ("Sunkern",55,55,60,"Sunflora",true),
        ("Sunflora",185,148,150,nil,true),
        ("Yanma",154,94,130,nil,true),
        ("Wooper",75,75,110,"Quagsire",true),
        ("Quagsire",152,152,190,nil,true),
        ("Espeon",261,194,130,nil,true),
        ("Umbreon",126,250,190,nil,true),
        ("Murkrow",175,87,120,nil,true),
        ("Slowking",177,194,190,nil,true),
        ("Misdreavus",167,167,120,nil,true),
        ("Unown",136,91,96,nil,true),
        ("Wobbuffet",60,106,380,nil,true),
        ("Girafarig",182,133,140,nil,true),
        ("Pineco",108,146,100,"Forretress",true),
        ("Forretress",161,242,150,nil,true),
        ("Dunsparce",131,131,200,nil,true),
        ("Gligar",143,204,130,nil,true),
        ("Steelix",148,333,150,nil,true),
        ("Snubbull",137,89,120,"Granbull",true),
        ("Granbull",212,137,180,nil,true),
        ("Qwilfish",184,148,130,nil,true),
        ("Scizor",236,191,140,nil,true),
        ("Shuckle",17,396,40,nil,true),
        ("Heracross",234,189,160,"nil",true),
        ("Sneasel",189,157,110,nil,true),
        ("Teddiursa",142,93,120,"Ursaring",true),
        ("Ursaring",236,144,180,nil,true),
        ("Slugma",118,71,80,"Magcargo",true),
        ("Magcargo",139,209,100,nil,true),
        ("Swinub",90,74,100,"Piloswine",true),
        ("Piloswine",181,147,200,nil,true),
        ("Corsola",118,156,110,nil,true),
        ("Remoraid",127,69,70,"Octillery",true),
        ("Octillery",197,141,150,nil,true),
        ("Delibird",128,90,90,nil,false),
        ("Mantine",148,260,130,nil,true),
        ("Skarmory",148,260,130,nil,true),
        ("Houndour",152,93,90,"Houndoom",true),
        ("Houndoom",224,159,150,nil,true),
        ("Kingdra",194,194,150,nil,true),
        ("Phanpy",107,107,180,"Donphan",true),
        ("Donphan",214,214,180,nil,true),
        ("Porygon2",198,183,170,nil,true),
        ("Stantler",192,132,146,nil,true),
        ("Smeargle",40,88,110,nil,false),
        ("Tyrogue",64,64,70,"Hitmontop",true),
        ("Hitmontop",173,214,100,nil,true),
        ("Smoochum",153,116,90,"Jynx",true),
        ("Elekid",135,110,90,"Electabuzz",true),
        ("Magby",151,108,90,"Magmar",true),
        ("Miltank",157,211,190,nil,true),
        ("Blissey",129,229,510,nil,true),
        ("Raikou",241,210,180,nil,false),
        ("Entei",235,176,230,nil,false),
        ("Suicune",180,235,200,nil,false),
        ("Larvitar",115,93,100,"Tyranitar",true),
        ("Pupitar",155,133,140,"Tyranitar",true),
        ("Tyranitar",251,212,200,nil,true),
        ("Lugia",193,323,212,nil,false),
        ("Ho-Oh",263,301,212,nil,false),
        ("Celebi",210,210,200,nil,false)
    ];
    
    private static let baseStats = {
        return Dictionary(rawData.map { data in (data.0, (atk: data.1, def: data.2, sta: data.3, evolution: data.4)) })
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
        (30.5, 0.734741009),
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
