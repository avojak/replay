/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Views.GameDetailView : Gtk.Grid {

    private unowned Replay.Widgets.LibraryItem? library_item;

    private Gtk.Image header_image;
    private Gtk.Label header_title_label;
    private Gtk.Label region_label;
    private Gtk.Label genre_year_publisher_label;
    private Gtk.Label platform_label;
    private Gtk.MenuButton more_button;
    private Gtk.Image favorite_image;

    private Gtk.Grid genre_games;
    private Gtk.Grid franchise_games;
    private Granite.HeaderLabel genre_games_label;
    private Granite.HeaderLabel franchise_games_label;
    private Replay.Widgets.GameGrid genre_games_grid;
    private Replay.Widgets.GameGrid franchise_games_grid;

    public GameDetailView () {
        Object (
            expand: true,
            margin: 30
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

        header_image = new Gtk.Image () {
            gicon = new ThemedIcon ("application-default-icon"),
            pixel_size = 128
        };

        header_title_label = new Gtk.Label ("") {
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

        genre_year_publisher_label = new Gtk.Label ("") {
            valign = Gtk.Align.START,
            halign = Gtk.Align.START,
            hexpand = true,
            wrap = false,
            ellipsize = Pango.EllipsizeMode.END
        };
        genre_year_publisher_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);

        platform_label = new Gtk.Label ("") {
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

        more_button = new Gtk.MenuButton () {
            image = new Gtk.Image.from_icon_name ("view-more", Gtk.IconSize.SMALL_TOOLBAR),
            tooltip_text = _("Choose system…")
        };

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

        franchise_games = new Gtk.Grid () {
            hexpand = true,
            column_homogeneous = false
        };
        franchise_games_label = new Granite.HeaderLabel ("") {
            hexpand = false
        };
        franchise_games_grid = new Replay.Widgets.GameGrid ();
        franchise_games.attach (franchise_games_label, 0, 0);
        franchise_games.attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
            hexpand = true,
            valign = Gtk.Align.CENTER,
            margin_start = 8
        }, 1, 0);
        franchise_games.attach (franchise_games_grid, 0, 1, 2, 1);
        franchise_games.set_visible (false);

        genre_games = new Gtk.Grid () {
            hexpand = true,
            column_homogeneous = false
        };
        genre_games_label = new Granite.HeaderLabel ("") {
            hexpand = false
        };
        genre_games_grid = new Replay.Widgets.GameGrid ();
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

        // TODO: These events are causing the app to crash!

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
    }

    public void set_library_item (Replay.Widgets.LibraryItem library_item) {
        this.library_item = library_item;

        // Update the game image
        load_image ();

        // Update the header label
        header_title_label.set_text (library_item.game.display_name);
        header_title_label.set_tooltip_text (library_item.game.display_name);

        // Update the favorite icon
        favorite_image.icon_name = library_item.game.is_favorite ? "starred" : "non-starred";
        favorite_image.tooltip_text = library_item.game.is_favorite ? _("Remove from favorites") : _("Add to favorites");

        // Update the genre/year/publisher label
        if (library_item.game.libretro_details == null) {
            genre_year_publisher_label.set_text ("");
            platform_label.set_text ("");
        } else {
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
                genre_year_publisher_label.set_text (string.joinv (" • ", genre_year_publisher_data.to_array ()));
            } else {
                genre_year_publisher_label.set_text ("");
            }
            platform_label.set_text (library_item.game.libretro_details.platform_name);
        }

        // Update the "play with" popover menu
        more_button.popup = create_run_with_menu ();

        // Clear out the game grids and re-populate
        genre_games_grid.clear ();
        franchise_games_grid.clear ();
        genre_games.set_visible (false);
        franchise_games.set_visible (false);
        if (library_item.game.libretro_details != null) {
            string? this_genre = library_item.game.libretro_details.genre_name;
            string? this_franchise = library_item.game.libretro_details.franchise_name;

            if (this_genre != null) {
                genre_games_label.set_text (_("Other %s Games").printf (this_genre));
            }
            if (this_franchise != null) {
                franchise_games_label.set_text (_("Other Games in the %s Franchise").printf (this_franchise));
            }

            foreach (var game in Replay.Core.Client.get_default ().game_library.get_games ()) {
                if (library_item.game == game || game.libretro_details == null) {
                    continue;
                }

                string? other_genre = game.libretro_details.genre_name;
                if ((this_genre != null) && (other_genre != null) && (this_genre == other_genre)) {
                    genre_games.set_visible (true);
                    genre_games_grid.add_game (game);
                }

                string? other_franchise = game.libretro_details.franchise_name;
                if ((this_franchise != null) && (other_franchise != null) && (this_franchise == other_franchise)) {
                    franchise_games.set_visible (true);
                    franchise_games_grid.add_game (game);
                }
            }
        }

        this.queue_draw ();
    }

    private void load_image () {
        try {
            string? box_art_file_path = Replay.Core.Client.get_default ().game_art_repository.get_box_art_file_path (library_item.game);
            if (box_art_file_path == null) {
                load_default_image ();
            } else {
                debug (box_art_file_path);
                header_image.set_from_pixbuf (new Gdk.Pixbuf.from_file_at_size (box_art_file_path, 100, 100));
                header_image.margin = 12;
                //  header_image.set_margin_top (16);
                //  header_image.set_margin_start (16);
                //  header_image.set_margin_end (16);
                //  header_image.set_margin_bottom (20);
                //  new Gtk.Image.from_pixbuf (new Gdk.Pixbuf.from_file_at_size (box_art_file_path, 100, 100)) {
                //      margin_top = 16,
                //      margin_start = 16,
                //      margin_end = 16,
                //      margin_bottom = 20
                //  };
            }
        } catch (GLib.Error e) {
            warning (e.message);
            load_default_image ();
        }
    }

    private void load_default_image () {
        header_image.gicon = new ThemedIcon ("application-default-icon");
        header_image.set_pixel_size (128);
        header_image.margin = 8;
        //  header_image.set_margin_bottom (8);
        //  return new Gtk.Image () {
        //      gicon = new ThemedIcon ("application-default-icon"),
        //      pixel_size = 128,
        //      margin_bottom = 8
        //  };
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

    public signal void play_button_clicked (Replay.Widgets.LibraryItem library_item, string? core_name = null);
    public signal void item_selected (Replay.Widgets.LibraryItem library_item);
    public signal void item_added_to_favorites (Replay.Widgets.LibraryItem library_item);
    public signal void item_removed_from_favorites (Replay.Widgets.LibraryItem library_item);
    public signal void item_marked_played (Replay.Widgets.LibraryItem library_item);
    public signal void item_marked_unplayed (Replay.Widgets.LibraryItem library_item);

}
