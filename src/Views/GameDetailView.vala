/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Views.GameDetailView : Gtk.Grid {

    public unowned Replay.Widgets.LibraryItem library_item { get; construct; }

    private Gtk.Image favorite_image;

    public GameDetailView.for_library_item (Replay.Widgets.LibraryItem library_item) {
        Object (
            expand: true,
            margin: 30,
            library_item: library_item
        );
    }

    construct {
        // TODO: This entire view should be in a scrolled window

        var header_grid = new Gtk.Grid () {
            margin_bottom = 10,
            column_spacing = 10,
            row_spacing = 10,
            hexpand = true,
            vexpand = false
        };

        var header_image = get_image ();

        var header_title_label = new Gtk.Label (library_item.game.display_name) {
            tooltip_text = library_item.game.display_name,
            valign = Gtk.Align.END,
            halign = Gtk.Align.START,
            hexpand = true,
            vexpand = true,
            wrap = false,
            ellipsize = Pango.EllipsizeMode.END
        };
        header_title_label.get_style_context ().add_class (Granite.STYLE_CLASS_H1_LABEL);

        //  region_label = new Gtk.Label ("USA") {

        //  };
        //  region_label.get_style_context ().add_class ("region-label");

        var genre_year_publisher_label = new Gtk.Label (library_item.game.libretro_details == null ? "" : build_genre_year_publisher_text ()) {
            valign = Gtk.Align.START,
            halign = Gtk.Align.START,
            hexpand = true,
            wrap = false,
            ellipsize = Pango.EllipsizeMode.END
        };
        genre_year_publisher_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);

        var platform_label = new Gtk.Label (library_item.game.libretro_details == null ? "" : library_item.game.libretro_details.platform_name) {
            valign = Gtk.Align.START,
            halign = Gtk.Align.START,
            hexpand = true,
            wrap = false,
            ellipsize = Pango.EllipsizeMode.END
        };
        platform_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);

        var play_button = new Gtk.Button () {
            always_show_image = true,
            image = new Gtk.Image.from_icon_name ("media-playback-start", Gtk.IconSize.SMALL_TOOLBAR),
            image_position = Gtk.PositionType.LEFT,
            label = _("Play"),
            tooltip_text = _("Play"),
            width_request = 100 // Make the button a bit larger for emphasis
        };
        play_button.clicked.connect (() => {
            play_button_clicked (library_item);
        });

        var more_button = new Gtk.MenuButton () {
            image = new Gtk.Image.from_icon_name ("view-more", Gtk.IconSize.SMALL_TOOLBAR),
            tooltip_text = _("Choose system…")
        };
        more_button.popup = create_run_with_menu ();

        var play_button_grid = new Gtk.Grid () {
            valign = Gtk.Align.CENTER,
            halign = Gtk.Align.START,
        };
        play_button_grid.get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);
        play_button_grid.add (play_button);
        play_button_grid.add (more_button);

        var favorite_event_box = new Gtk.EventBox () {
            halign = Gtk.Align.END
        };
        favorite_image = new Gtk.Image.from_icon_name ("non-starred", Gtk.IconSize.DIALOG);
        favorite_event_box.add (favorite_image);
        favorite_event_box.button_press_event.connect (() => {
            if (library_item.game.is_favorite) {
                favorite_image.icon_name = "non-starred";
                favorite_image.tooltip_text = _("Add to favorites");
                item_removed_from_favorites (library_item);
            } else {
                favorite_image.icon_name = "starred";
                favorite_image.tooltip_text = _("Remove from favorites");
                item_added_to_favorites (library_item);
            }
        });

        var metadata_grid = new Gtk.Grid () {
            row_spacing = 0,
            margin_bottom = 8
        };
        metadata_grid.attach (genre_year_publisher_label, 0, 0);
        metadata_grid.attach (platform_label, 0, 1);

        //  var header_title_grid = new Gtk.Grid () {
        //      hexpand = true
        //  };
        //  header_title_grid.attach (header_title_label, 0, 0);
        //  header_title_grid.attach (region_label, 1, 0);

        header_grid.attach (header_image, 0, 0, 1, 2);
        header_grid.attach (header_title_label, 1, 0, 1, 1);
        header_grid.attach (metadata_grid, 1, 1, 1, 1);
        //  header_grid.attach (platform_label, 1, 2, 1, 1);
        header_grid.attach (favorite_event_box, 2, 0, 1, 1);
        header_grid.attach (play_button_grid, 2, 1, 1, 1);

        var body_grid = new Gtk.Grid () {
            expand = true
        };

        var media_grid = new Gtk.Grid () {
            hexpand = true
        };
        media_grid.attach (new Granite.HeaderLabel ("Media") {
            hexpand = false
        }, 0, 0);
        media_grid.attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
            hexpand = true,
            valign = Gtk.Align.CENTER,
            margin_start = 8
        }, 1, 0);

        string? franchise = library_item.game.libretro_details == null ? null : library_item.game.libretro_details.franchise_name;
        var franchise_games = new Gtk.Grid () {
            hexpand = true,
            column_homogeneous = false
        };
        var franchise_games_label = new Granite.HeaderLabel (franchise == null ? "" : _("Other Games in the %s Franchise").printf (franchise)) {
            hexpand = false
        };
        var franchise_games_grid = new Replay.Widgets.GameGrid ();
        franchise_games.attach (franchise_games_label, 0, 0);
        franchise_games.attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
            hexpand = true,
            valign = Gtk.Align.CENTER,
            margin_start = 8
        }, 1, 0);
        franchise_games.attach (franchise_games_grid, 0, 1, 2, 1);
        franchise_games.set_visible (false);

        string? genre = library_item.game.libretro_details == null ? null : library_item.game.libretro_details.genre_name;
        var genre_games = new Gtk.Grid () {
            hexpand = true,
            column_homogeneous = false
        };
        var genre_games_label = new Granite.HeaderLabel (genre == null ? "" : _("Other %s Games").printf (genre)) {
            hexpand = false
        };
        var genre_games_grid = new Replay.Widgets.GameGrid ();
        genre_games.attach (genre_games_label, 0, 0);
        genre_games.attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
            hexpand = true,
            valign = Gtk.Align.CENTER,
            margin_start = 8
        }, 1, 0);
        genre_games.attach (genre_games_grid, 0, 1, 2, 1);
        genre_games.set_visible (false);

        body_grid.attach (media_grid, 0, 0);
        body_grid.attach (franchise_games, 0, 1);
        body_grid.attach (genre_games, 0, 2);

        //  var activity_header_label = new Granite.HeaderLabel (_("Activity"));
        //  var last_played_label = new Gtk.Label (_("Last played:")) {
        //      halign = Gtk.Align.END
        //  };
        //  var last_played_value_label = new Gtk.Label ("") {
        //      halign = Gtk.Align.START
        //  };
        //  var play_time_label = new Gtk.Label (_("Play time:")) {
        //      halign = Gtk.Align.END
        //  };
        //  var play_time_value_label = new Gtk.Label ("") {
        //      halign = Gtk.Align.START
        //  };

        attach (header_grid, 0, 0);
        attach (body_grid, 0, 1);
        show_all ();

        // Populate the franchise and genre game grids
        franchise_games.set_visible (false);
        genre_games.set_visible (false);
        foreach (var game in Replay.Core.Client.get_default ().game_library.get_games ()) {
            if (library_item.game == game || game.libretro_details == null) {
                continue;
            }
            string? other_franchise = game.libretro_details.franchise_name;
            if ((franchise != null) && (other_franchise != null) && (franchise == other_franchise)) {
                franchise_games.set_visible (true);
                franchise_games_grid.add_game (game);
                // Don't duplicate a game in both the franchise and the genre section, but prefer franchise over genre
                continue;
            }
            string? other_genre = game.libretro_details.genre_name;
            if ((genre != null) && (other_genre != null) && (genre == other_genre)) {
                genre_games.set_visible (true);
                genre_games_grid.add_game (game);
            }
        }

        // Connect to signals for the franchise games grid
        franchise_games_grid.item_selected.connect ((library_item) => {
            item_selected (library_item);
        });
        franchise_games_grid.item_run.connect ((library_item, core_name) => {
            play_button_clicked (library_item, core_name);
        });
        franchise_games_grid.item_added_to_favorites.connect ((library_item) => {
            item_added_to_favorites (library_item);
        });
        franchise_games_grid.item_removed_from_favorites.connect ((library_item) => {
            item_removed_from_favorites (library_item);
        });
        franchise_games_grid.item_marked_played.connect ((library_item) => {
            item_marked_played (library_item);
        });
        franchise_games_grid.item_marked_unplayed.connect ((library_item) => {
            item_marked_unplayed (library_item);
        });

        // Connect to signals for the genre games grid
        genre_games_grid.item_selected.connect ((library_item) => {
            item_selected (library_item);
        });
        genre_games_grid.item_run.connect ((library_item, core_name) => {
            play_button_clicked (library_item, core_name);
        });
        genre_games_grid.item_added_to_favorites.connect ((library_item) => {
            item_added_to_favorites (library_item);
        });
        genre_games_grid.item_removed_from_favorites.connect ((library_item) => {
            item_removed_from_favorites (library_item);
        });
        genre_games_grid.item_marked_played.connect ((library_item) => {
            item_marked_played (library_item);
        });
        genre_games_grid.item_marked_unplayed.connect ((library_item) => {
            item_marked_unplayed (library_item);
        });

        library_item.game.notify["is-favorite"].connect (update_favorite);
        update_favorite ();
    }

    private string build_genre_year_publisher_text () {
        var genre_year_publisher_data = new Gee.ArrayList<string> ();
        if (library_item.game.libretro_details.genre_name != null) {
            genre_year_publisher_data.add (library_item.game.libretro_details.genre_name);
        }
        if (library_item.game.libretro_details.release_year != null) {
            genre_year_publisher_data.add (library_item.game.libretro_details.release_year.to_string ());
        }
        if (library_item.game.libretro_details.developer_name != null) {
            genre_year_publisher_data.add (library_item.game.libretro_details.developer_name);
        }
        if (genre_year_publisher_data.size > 0) {
            return string.joinv (" • ", genre_year_publisher_data.to_array ());
        } else {
            return "";
        }
    }

    public void update_favorite () {
        favorite_image.icon_name = library_item.game.is_favorite ? "starred" : "non-starred";
        favorite_image.tooltip_text = library_item.game.is_favorite ? _("Remove from favorites") : _("Add to favorites");
    }

    private Gtk.Image get_image () {
        try {
            string? box_art_file_path = Replay.Core.Client.get_default ().game_art_repository.get_box_art_file_path (library_item.game);
            if (box_art_file_path == null) {
                return get_default_image ();
            } else {
                return new Gtk.Image.from_pixbuf (new Gdk.Pixbuf.from_file_at_size (box_art_file_path, 100, 100)) {
                    margin = 12
                };
            }
        } catch (GLib.Error e) {
            warning (e.message);
            return get_default_image ();
        }
    }

    private Gtk.Image get_default_image () {
        return new Gtk.Image () {
            gicon = new ThemedIcon ("application-default-icon"),
            pixel_size = 128,
            margin = 8
        };
    }

    private Gtk.Menu create_run_with_menu () {
        var menu = new Gtk.Menu ();
        foreach (var core in Replay.Core.Client.get_default ().core_repository.get_cores_for_rom (GLib.File.new_for_path (library_item.game.rom_path))) {
            var core_name = core.info.core_name;
            var item = new Gtk.MenuItem.with_label (_("Play with %s").printf (core_name));
            item.activate.connect (() => {
                play_button_clicked (library_item, core_name);
            });
            menu.add (item);
        }
        menu.show_all ();
        return menu;
    }

    public signal void play_button_clicked (Replay.Widgets.LibraryItem? library_item, string? core_name = null);
    public signal void item_selected (Replay.Widgets.LibraryItem library_item);
    public signal void item_added_to_favorites (Replay.Widgets.LibraryItem library_item);
    public signal void item_removed_from_favorites (Replay.Widgets.LibraryItem library_item);
    public signal void item_marked_played (Replay.Widgets.LibraryItem library_item);
    public signal void item_marked_unplayed (Replay.Widgets.LibraryItem library_item);

}
