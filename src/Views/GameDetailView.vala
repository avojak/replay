/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Views.GameDetailView : Gtk.Grid {

    private unowned Replay.Widgets.LibraryItem? library_item;

    private Gtk.Label header_title_label;
    private Gtk.Label region_label;
    private Gtk.Label genre_year_publisher_label;
    private Gtk.Label platform_label;
    private Gtk.MenuButton more_button;
    private Gtk.Image favorite_image;

    public GameDetailView () {
        Object (
            expand: true,
            margin: 30
        );
    }

    construct {
        var header_grid = new Gtk.Grid () {
            margin_bottom = 10,
            column_spacing = 10,
            row_spacing = 10,
            hexpand = true,
            vexpand = false
        };

        var header_image = new Gtk.Image () {
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
            expand = true,
            vexpand = false
        };

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
    }

    public void set_library_item (Replay.Widgets.LibraryItem library_item) {
        this.library_item = library_item;
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
    }

    private Gtk.Menu create_run_with_menu () {
        var menu = new Gtk.Menu ();
        foreach (var core in Replay.Core.Client.get_default ().core_repository.get_cores_for_rom (GLib.File.new_for_path (library_item.game.rom_path))) {
            var item = new Gtk.MenuItem.with_label (_("Play with %s").printf (core.info.core_name));
            item.activate.connect (() => {
                // TODO: Pass specific core
                play_button_clicked (library_item);
            });
            menu.add (item);
        }
        menu.show_all ();
        return menu;
    }

    public signal void play_button_clicked (Replay.Widgets.LibraryItem library_item);
    public signal void item_added_to_favorites (Replay.Widgets.LibraryItem library_item);
    public signal void item_removed_from_favorites (Replay.Widgets.LibraryItem library_item);

}
