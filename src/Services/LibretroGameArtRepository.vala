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

    public Gtk.Image? download_box_art (Replay.Models.Game game) {
        return download_art (game, Replay.Models.LibretroArtType.BOX);
        //  var image_file = get_file (game, Replay.Models.LibretroArtType.BOX);
        //  //  debug (image_file.get_path ());
        //  if (image_file.query_exists ()) {
        //      return new Gtk.Image.from_file (image_file.get_path ());
        //  }
        //  if (game.libretro_details == null) {
        //      return null;
        //  }
        //  var manufacturer = game.libretro_details.manufacturer_name;
        //  if (game.libretro_details.platform_name != null) {
        //      manufacturer += " - %s".printf (game.libretro_details.platform_name);
        //  }
        //  manufacturer = Soup.URI.encode (manufacturer, null);
        //  var filename = Soup.URI.encode (game.libretro_details.full_name, null);
        //  var url = @"http://thumbnails.libretro.com/$manufacturer/Named_Boxarts/$filename.png";

        //  debug (url);
        //  try {
        //      Replay.Utils.HttpUtils.download_file (url, image_file, null);
        //  } catch (GLib.Error e) {
        //      warning ("Error executing request for artwork: %s", e.message);
        //      return null;
        //  }
        //  //  var session = new Soup.Session ();
        //  //  try {
        //  //      var input_stream = new DataInputStream (session.send (new Soup.Message.from_uri ("GET", new Soup.URI (url)), null));
        //  //      var output_stream = image_file.replace (null, false, GLib.FileCreateFlags.NONE, null);
        //  //      size_t bytes_read;
        //  //      uint8[] buffer = new uint8[256];
        //  //      while ((bytes_read = input_stream.read (buffer, null)) != 0) {
        //  //          output_stream.write (buffer, null);
        //  //      }
        //  //  } catch (GLib.Error e) {
        //  //      warning ("Error executing request for artwork: %s", e.message);
        //  //      return null;
        //  //  }
        //  return new Gtk.Image.from_file (image_file.get_path ());
    }

    public Gtk.Image? download_screenshot_art (Replay.Models.Game game) {
        return download_art (game, Replay.Models.LibretroArtType.SCREENSHOT);
    }

    public Gtk.Image? download_titlescreen_art (Replay.Models.Game game) {
        return download_art (game, Replay.Models.LibretroArtType.TITLESCREEN);
    }

    private Gtk.Image? download_art (Replay.Models.Game game, Replay.Models.LibretroArtType art_type) {
        var image_file = get_file (game, art_type);
        //  debug (image_file.get_path ());
        if (image_file.query_exists ()) {
            return new Gtk.Image.from_file (image_file.get_path ());
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

    public signal void box_art_downloaded (Replay.Models.Game game, string image_file_path);
    public signal void screenshot_art_downloaded (Replay.Models.Game game, string image_file_path);
    public signal void titlescreen_art_downloaded (Replay.Models.Game game, string image_file_path);

}
