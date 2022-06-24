/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Models.LibretroSystemMapping : GLib.Object {

    // TODO: Need a better-modeled solution. This would be a good place to provide non-default icons as well:

    //  public class System : GLib.Object {

    //      public string libretro_name { get; construct; }
    //      public string display_name { get; construct; }
    //      public string icon_name { get; construct; }

    //      public System (string libretro_name, string? display_name = null, string icon_name = "input-gaming") {
    //          Object (
    //              libretro_name: libretro_name,
    //              display_name: display_name != null ? display_name : libretro_name,
    //              icon_name: icon_name
    //          );
    //      }

    //  }

    //  public static System neo_geo_cd = new System ("Neo Geo CD");

    private static GLib.Once<Replay.Models.LibretroSystemMapping> instance;
    public static unowned Replay.Models.LibretroSystemMapping get_default () {
        return instance.once (() => { return new Replay.Models.LibretroSystemMapping (); });
    }

    private LibretroSystemMapping () {}

    private Gee.Map<string, string> mapping;

    construct {
        mapping = new Gee.HashMap<string, string> ();
        mapping.set ("Neo Geo CD", "Neo Geo CD");
        mapping.set ("Mega-CD - Sega CD", "Sega CD");
        mapping.set ("PC Engine SuperGrafx", "SuperGrafx");
        mapping.set ("Quake II", "Quake II");
        mapping.set ("Game.com", "Game.com");
        mapping.set ("PlayStation", "PlayStation");
        mapping.set ("Game Master", "Game Master");
        mapping.set ("Adventure Vision", "Adventure Vision");
        mapping.set ("Neo Geo Pocket", "Neo Geo Pocket");
        mapping.set ("DOS", "DOS");
        mapping.set ("Jump 'n Bump", "Jump 'n Bump");
        mapping.set ("PC Engine CD - TurboGrafx-CD", "TurboGrafx-CD");
        mapping.set ("PlayStation Vita", "PlayStation Vita");
        mapping.set ("32X", "Sega 32X");
        mapping.set ("Mega Drive - Genesis", "Sega Genesis");
        mapping.set ("Tomb Raider", "Tomb Raider");
        mapping.set ("RPG Maker", "RPG Maker");
        mapping.set ("Lutro", "Lutro");
        mapping.set ("Cannonball", "Cannonball");
        mapping.set ("PC-FX", "PC-FX");
        mapping.set ("Nintendo 3DS", "Nintendo 3DS");
        mapping.set ("Nintendo 64", "Nintendo 64");
        mapping.set ("Quake", "Quake");
        mapping.set ("Satellaview", "Satellaview");
        mapping.set ("TIC-80", "TIC-80");
        mapping.set ("Handheld Electronic Game", "Handheld Electronic Game");
        mapping.set ("Nintendo Entertainment System", "Nintendo (NES)");
        mapping.set ("Jaguar", "Jaguar");
        mapping.set ("Pokemon Mini", "Pokemon Mini");
        mapping.set ("Quake III", "Quake III");
        mapping.set ("Sufami Turbo", "Sufami Turbo");
        mapping.set ("WonderSwan", "WonderSwan");
        mapping.set ("7800", "Atari 7800");
        mapping.set ("Odyssey2", "Odyssey²");
        mapping.set ("MSX", "MSX");
        mapping.set ("Super Nintendo Entertainment System", "Super Nintendo (SNES)");
        mapping.set ("2600", "Atari 2600");
        mapping.set ("MAME 2003-Plus", "MAME 2003-Plus");
        mapping.set ("Family Computer Disk System", "Famicom Disk System");
        mapping.set ("Arcade Games", "Arcade Games");
        mapping.set ("e-Reader", "e-Reader");
        mapping.set ("Arcadia 2001", "Arcadia 2001");
        mapping.set ("MAME", "MAME");
        mapping.set ("ZX Spectrum +3", "ZX Spectrum +3");
        mapping.set ("PV-1000", "PV-1000");
        mapping.set ("Saturn", "Sega Saturn");
        mapping.set ("PlayStation 3", "PlayStation 3");
        mapping.set ("Wii (Digital)", "Wii (Digital)");
        mapping.set ("ZX 81", "ZX 81");
        mapping.set ("GameCube", "GameCube");
        mapping.set ("VIC-20", "VIC-20");
        mapping.set ("DOOM", "DOOM");
        mapping.set ("Channel F", "Channel F");
        mapping.set ("ST", "ST");
        mapping.set ("PlayStation 2", "PlayStation 2");
        mapping.set ("Loopy", "Loopy");
        mapping.set ("MAME 2003", "MAME 2003");
        mapping.set ("Wolfenstein 3D", "Wolfenstein 3D");
        mapping.set ("Dinothawr", "Dinothawr");
        mapping.set ("PlayStation Portable", "Sony PSP");
        mapping.set ("MAME 2016", "MAME 2016");
        mapping.set ("MSX2", "MSX2");
        mapping.set ("ZX Spectrum", "ZX Spectrum");
        mapping.set ("MrBoom", "MrBoom");
        mapping.set ("MAME 2000", "MAME 2000");
        mapping.set ("MOTO", "MOTO");
        mapping.set ("Super Cassette Vision", "Super Cassette Vision");
        mapping.set ("Vectrex", "Vectrex");
        mapping.set ("Rick Dangerous", "Rick Dangerous");
        mapping.set ("Neo Geo Pocket Color", "Neo Geo Pocket Color");
        mapping.set ("Uzebox", "Uzebox");
        mapping.set ("3DO", "3DO");
        mapping.set ("MAME 2015", "MAME 2015");
        mapping.set ("Game Boy", "Game Boy");
        mapping.set ("SG-1000", "SG-1000");
        mapping.set ("5200", "Atari 5200");
        mapping.set ("Game Gear", "Game Gear");
        mapping.set ("Lynx", "Atari Lynx");
        mapping.set ("CPC", "CPC");
        mapping.set ("MAME 2010", "MAME 2010");
        mapping.set ("Supervision", "Supervision");
        mapping.set ("Master System - Mark III", "Sega Master System");
        mapping.set ("X68000", "X68000");
        mapping.set ("PC-98", "PC-98");
        mapping.set ("Game Boy Color", "Game Boy Color");
        mapping.set ("GX4000", "GX4000");
        mapping.set ("Cave Story", "Cave Story");
        mapping.set ("Amiga", "Amiga");
        mapping.set ("Nintendo DS", "Nintendo DS");
        mapping.set ("PICO", "PICO");
        mapping.set ("Intellivision", "Intellivision");
        mapping.set ("PlayStation Portable (PSN)", "PlayStation Portable (PSN)");
        mapping.set ("Leapster Learning Game System", "Leapster Learning Game System");
        mapping.set ("Nintendo 64DD", "Nintendo 64DD");
        mapping.set ("WASM-4", "WASM-4");
        mapping.set ("CreatiVision", "CreatiVision");
        mapping.set ("Super Acan", "Super Acan");
        mapping.set ("Dreamcast", "Sega Dreamcast");
        mapping.set ("64", "64");
        mapping.set ("Wii", "Wii");
        mapping.set ("Videopac+", "Videopac+");
        mapping.set ("Nintendo DSi", "Nintendo DSi");
        mapping.set ("V.Smile", "V.Smile");
        mapping.set ("Xbox", "Xbox");
        mapping.set ("PlayStation 3 (PSN)", "PlayStation 3 (PSN)");
        mapping.set ("GP32", "GP32");
        mapping.set ("PC Engine - TurboGrafx 16", "TurboGrafx-16");
        mapping.set ("WonderSwan Color", "WonderSwan Color");
        mapping.set ("ChaiLove", "ChaiLove");
        mapping.set ("LowRes NX", "LowRes NX");
        mapping.set ("Studio II", "Studio II");
        mapping.set ("Virtual Boy", "Virtual Boy");
        mapping.set ("ColecoVision", "ColecoVision");
        mapping.set ("Game Boy Advance", "Game Boy Advance");
        mapping.set ("HBMAME", "HBMAME");
        mapping.set ("Flashback", "Flashback");
        mapping.set ("ScummVM", "ScummVM");
        mapping.set ("Plus-4", "Plus-4");
    }

    public string? get_display_name (string libretro_name) {
        if (!mapping.has_key (libretro_name)) {
            warning ("No mapping for %s", libretro_name);
            return null;
        }
        return mapping.get (libretro_name);
    }

}
