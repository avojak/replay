/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

 public class Replay.Services.LibretroGameArtRepository : GLib.Object {

    private static GLib.Once<Replay.Services.LibretroGameArtRepository> instance;
    public static unowned Replay.Services.LibretroGameArtRepository get_default () {
        return instance.once (() => { return new Replay.Services.LibretroGameArtRepository (); });
    }

    private string cache_dir_path = GLib.Environment.get_user_config_dir () + "/libretro_art";

    private LibretroGameArtRepository () {
        info ("Game art cache: %s", cache_dir_path);
        initialize_cache_directories ();
    }

    private void initialize_cache_directories () {
        // Create the directories for storing all types of art
        initialize_directory (GLib.File.new_for_path (cache_dir_path));
        initialize_directory (GLib.File.new_for_path (cache_dir_path + "/" + Replay.Models.LibretroArtType.BOX.to_string ()));
        initialize_directory (GLib.File.new_for_path (cache_dir_path + "/" + Replay.Models.LibretroArtType.SCREENSHOT.to_string ()));
        initialize_directory (GLib.File.new_for_path (cache_dir_path + "/" + Replay.Models.LibretroArtType.TITLESCREEN.to_string ()));
    }

    private void initialize_directory (GLib.File dir) {
        try {
            if (!dir.query_exists ()) {
                debug ("Directory does not exist - creating it now");
                dir.make_directory ();
            }
        } catch (GLib.Error e) {
            warning ("Error creating directory: %s", e.message);
            return;
        }
    }

    public string? get_box_art_file_path (Replay.Models.Game game) {
        var image_file = get_file (game, Replay.Models.LibretroArtType.BOX);
        return image_file.query_exists () ? image_file.get_path () : null;
    }

    public string? get_screenshot_art_file_path (Replay.Models.Game game) {
        var image_file = get_file (game, Replay.Models.LibretroArtType.SCREENSHOT);
        return image_file.query_exists () ? image_file.get_path () : null;
    }

    public string? get_titlescreen_art_file_path (Replay.Models.Game game) {
        var image_file = get_file (game, Replay.Models.LibretroArtType.TITLESCREEN);
        return image_file.query_exists () ? image_file.get_path () : null;
    }

    public async void download_box_art_async (Replay.Models.Game game) {
        GLib.SourceFunc callback = download_box_art_async.callback;
        Gtk.Image? image = null;
        new GLib.Thread<void> ("download-box-art", () => {
            image = download_art (game, Replay.Models.LibretroArtType.BOX);
            Idle.add ((owned) callback);
        });
        yield;
        if (image != null) {
            box_art_downloaded (game);
        }
    }

    public async void download_screenshot_art_async (Replay.Models.Game game) {
        GLib.SourceFunc callback = download_screenshot_art_async.callback;
        Gtk.Image? image = null;
        new GLib.Thread<void> ("download-screenshot-art", () => {
            image = download_art (game, Replay.Models.LibretroArtType.SCREENSHOT);
            Idle.add ((owned) callback);
        });
        yield;
        if (image != null) {
            screenshot_art_downloaded (game);
        }
    }

    public async void download_titlescreen_art_async (Replay.Models.Game game) {
        GLib.SourceFunc callback = download_titlescreen_art_async.callback;
        Gtk.Image? image = null;
        new GLib.Thread<void> ("download-titlescreen-art", () => {
            image = download_art (game, Replay.Models.LibretroArtType.TITLESCREEN);
            Idle.add ((owned) callback);
        });
        yield;
        if (image != null) {
            titlescreen_art_downloaded (game);
        }
    }

    private Gtk.Image? download_art (Replay.Models.Game game, Replay.Models.LibretroArtType art_type) {
        var image_file = get_file (game, art_type);
        //  debug (image_file.get_path ());
        if (image_file.query_exists ()) {
            return null;
        }
        // Downloading artwork from Libretro requires metadata from the Libretro database
        if (game.libretro_details == null) {
            return null;
        }

        try {
            var url = build_url (game, art_type);
            debug (url);
            Replay.Utils.HttpUtils.download_file (url, image_file);
        } catch (GLib.Error e) {
            warning ("Error executing request for %s art for game %s: %s", art_type.to_string (), game.libretro_details.display_name, e.message);
            return null;
        }
        return new Gtk.Image.from_file (image_file.get_path ());
    }

    // TODO: Need to handle a bug where there might be an "incorrect" URL
    //       For example: http://thumbnails.libretro.com/Sega%20-%20Mega%20Drive%20-%20Genesis/Named_Snaps/Sonic%20The%20Hedgehog%20(USA,%20Europe).png
    //       Should be:   http://thumbnails.libretro.com/Sega%20-%20Mega%20Drive%20-%20Genesis/Named_Snaps/Sonic%20the%20Hedgehog%20(USA,%20Europe).png
    //       where "the" is not capitalized

    // TODO: Probably also need to better follow the file name guide:
    //       https://docs.libretro.com/guides/roms-playlists-thumbnails/#thumbnail-paths-and-filenames

    private string build_url (Replay.Models.Game game, Replay.Models.LibretroArtType art_type) {
        var manufacturer = game.libretro_details.manufacturer_name;
        if (game.libretro_details.platform_name != null) {
            manufacturer += " - %s".printf (game.libretro_details.platform_name);
        }
        manufacturer = Soup.URI.encode (manufacturer, null);
        var filename = Soup.URI.encode (game.libretro_details.full_name, null);
        var art_type_uri_parameter = art_type.get_url_parameter ();
        return @"http://thumbnails.libretro.com/$manufacturer/$art_type_uri_parameter/$filename.png";
    }

    private GLib.File get_file (Replay.Models.Game game, Replay.Models.LibretroArtType art_type) {
        return GLib.File.new_for_path ("%s/%s/%s.png".printf (cache_dir_path, art_type.to_string (), game.rom_md5));
    }

    public signal void box_art_downloaded (Replay.Models.Game game);
    public signal void screenshot_art_downloaded (Replay.Models.Game game);
    public signal void titlescreen_art_downloaded (Replay.Models.Game game);

}
