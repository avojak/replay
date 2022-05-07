/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

 public class Replay.Services.LibretroGameArtRepository : GLib.Object {

    private static GLib.Once<Replay.Services.LibretroGameArtRepository> instance;
    public static unowned Replay.Services.LibretroGameArtRepository get_default () {
        return instance.once (() => { return new Replay.Services.LibretroGameArtRepository (); });
    }

    private string cache_dir_path = GLib.Environment.get_user_config_dir () + "/" + Constants.APP_ID + "/libretro_art";

    private LibretroGameArtRepository () {
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

    public Gtk.Image? download_box_art (Replay.Models.Game game) {
        var image_file = get_file (game, Replay.Models.LibretroArtType.BOX);
        debug (image_file.get_path ());
        if (image_file.query_exists ()) {
            return new Gtk.Image.from_file (image_file.get_path ());
        }
        if (game.libretro_details == null) {
            return null;
        }
        var manufacturer = game.libretro_details.manufacturer_name;
        if (game.libretro_details.platform_name != null) {
            manufacturer += " - %s".printf (game.libretro_details.platform_name);
        }
        manufacturer = Soup.URI.encode (manufacturer, null);
        var display_name = Soup.URI.encode (game.display_name, null);
        var url = @"http://thumbnails.libretro.com/$manufacturer/Named_Boxarts/$display_name.png";
        debug (url);
        var session = new Soup.Session ();
        try {
            var input_stream = new DataInputStream (session.send (new Soup.Message.from_uri ("GET", new Soup.URI (url)), null));
            var output_stream = image_file.replace (null, false, GLib.FileCreateFlags.NONE, null);
            size_t bytes_read;
            uint8[] buffer = new uint8[256];
            while ((bytes_read = input_stream.read (buffer, null)) != 0) {
                output_stream.write (buffer, null);
            }
        } catch (GLib.Error e) {
            warning ("Error executing request for artwork: %s", e.message);
            return null;
        }
        return new Gtk.Image.from_file (image_file.get_path ());
    }

    //  public Gtk.Image? get_screenshot_art (string display_name, string rom_md5) {
    //  }

    //  public Gtk.Image? get_titlescreen_art (string display_name, string rom_md5) {
    //  }

    private GLib.File? download_art (Replay.Models.Game game, Replay.Models.LibretroArtType art_type) {
        // Downloading artwork from Libretro requires metadata from the Libretro database
        if (game.libretro_details == null) {
            return null;
        }

        var image_file = get_file (game, art_type);
        try {
            Replay.Utils.HttpUtils.download_file (build_url (game, art_type), image_file);
        } catch (GLib.Error e) {
            warning ("Error executing request for %s art for game %s: %s", art_type.to_string (), game.libretro_details.display_name, e.message);
            return null;
        }
        return image_file;
    }

    private string build_url (Replay.Models.Game game, Replay.Models.LibretroArtType art_type) {
        var manufacturer = game.libretro_details.manufacturer_name;
        if (game.libretro_details.platform_name != null) {
            manufacturer += " - %s".printf (game.libretro_details.platform_name);
        }
        manufacturer = Soup.URI.encode (manufacturer, null);
        var display_name = Soup.URI.encode (game.display_name, null);
        var art_type_uri_parameter = art_type.get_url_parameter ();
        return @"http://thumbnails.libretro.com/$manufacturer/$art_type_uri_parameter/$display_name.png";
    }

    private GLib.File get_file (Replay.Models.Game game, Replay.Models.LibretroArtType art_type) {
        return GLib.File.new_for_path ("%s/%s/%s.png".printf (cache_dir_path, art_type.to_string (), game.rom_md5));
    }

    public signal void box_art_downloaded (Replay.Models.Game game, string image_file_path);
    public signal void screenshot_art_downloaded (Replay.Models.Game game, string image_file_path);
    public signal void titlescreen_art_downloaded (Replay.Models.Game game, string image_file_path);

}
