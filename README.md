# Pokebase
A tool for organizing and tracking Pokémon Go.

This is based on the awesome [IV Calculator Spreadsheet](https://docs.google.com/spreadsheets/d/1wbtIc33K45iU1ScUnkB0PlslJ-eLaJlSZY47sPME2Uk/edit#gid=1812532592) created by [/u/aggixx](https://www.reddit.com/r/TheSilphRoad/comments/4tkk75/updated_iv_calculator_automatically_calculate_ivs/).
I found the spreadsheet became unwieldy for me with more than 100 Pokémon and I wanted something that was easier to extend.
Specifically, I wanted to be able to easily sort by Max CP in order to help prioritize which Pokémon to power up.
And I wanted to add the appraisal fields to make it easier to determine a Pokémon's exact IVs.

## Features

* Save and remove Pokémon
* Calculates IVs based on CP, HP, and appraisal
* Calculates Perfect, Powered-Up, and Max CP for Pokémon based on IVs and current trainer level
* Sort by any field
* Shows total number of saved Pokémon and number of unique species

## To Do

* Edit a saved Pokémon
* Filter and find
* Store movesets
* Ability to store additional metadata, such as location caught, whether it was caught or hatched, and freeform notes
* Rank saved Pokémon for Attacking, Defending, and Prestiging gyms

# System Requirements

MacOS 10.11 (El Capitan) or newer

# Installing

1. Download pokebase.dmg from Releases
2. Double-click to open
3. Drag Pokebase to your Applications folder

Pokébase is currently released as an unsigned application, meaning you may have to change your MacOS security settings to install it. To do so, go to `System Preferences -> Security & Privacy` and select `Allow apps downloaded from: Anywhere`.

# Using

* Set your Trainer Level
* Enter Species, CP, HP, Stardust, and whether the Pokémon has ever been powered up.
* Enter appraisal, if desired
* Press Calculate to see the possible IV ranges (or the actual IVs if known)
* Press Save to save the Pokémon
* Click on a column header to sort by that column
* Press the trashcan next to a Pokémon to remove it

Editing functionality is coming soon. Until then, if you power up or evolve a Pokémon, simply save its new values and remove the original.

## Importing

Pokébase can import Pokémon from an [IV Calculator Spreadsheet](https://docs.google.com/spreadsheets/d/1wbtIc33K45iU1ScUnkB0PlslJ-eLaJlSZY47sPME2Uk/edit#gid=1812532592) or CSV file.

### Importing from IV Calculator

1. In the spreadsheet, highlight columns 'B' through 'K' ('Name' through 'STA')
2. Type `cmd-C` to copy the rows
3. Still in the spreadsheet, select `File -> New -> Spreadsheet`
4. In the new spreadshet, type `cmd-V` to paste the rows from the original spreadsheet
5. Select `File -> Download As -> Comma-separated Values`
6. Open Pokébase
7. Select `File -> Import`
8. Find the csv file you downloaded and select `Open`

The Pokémon from your spreadsheet are now in Pokébase.

__Note that if you have entered multiple lines of a powered-up Pokémon, Pokébase will only import the final version of it.__

### Importing from other spreadsheet

If you have Pokémon stored in a different spreadsheet (or other file), Pokébase can import it as long as you can export it to a CSV with the fields in the correct order.
Simply reorder the columns of your spreadsheet before saving in CSV format.

The expected order is:

> Name,Species,CP,HP,DustPrice,PoweredUp?,Level,ATK,DEF,STA

The `Powered Up?` column must be set to "TRUE", "true", "YES", or "yes" if the Pokémon has been powered up.
Any other value, including no value at all, is treated as false.

# Issues / New Features

If you find any problems or have suggestions for new features, please create an Issue here on GitHub.

If you want to help with the development, PRs are welcome!
