/*
 * Copyright (c) 2022 Andrew Vojak (https://avojak.com)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 *
 * Authored by: Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Views.GameDetailView : Gtk.Grid {

    private unowned Replay.Widgets.LibraryItem? library_item;

    private Gtk.Label header_title_label;
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
            hexpand = true
        };

        var header_image = new Gtk.Image () {
            gicon = new ThemedIcon ("application-default-icon"),
            pixel_size = 128
        };

        header_title_label = new Gtk.Label ("") {
            valign = Gtk.Align.END,
            halign = Gtk.Align.START,
            hexpand = true,
            wrap = false,
            ellipsize = Pango.EllipsizeMode.END
        };
        header_title_label.get_style_context ().add_class (Granite.STYLE_CLASS_H1_LABEL);

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
            tooltip_text = _("Choose System…")
        };

        var play_button_grid = new Gtk.Grid () {
            valign = Gtk.Align.START,
            halign = Gtk.Align.START,
        };
        play_button_grid.get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);
        play_button_grid.add (play_button);
        play_button_grid.add (more_button);

        var favorite_event_box = new Gtk.EventBox ();
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

        header_grid.attach (header_image, 0, 0, 1, 2);
        header_grid.attach (header_title_label, 1, 0, 1, 1);
        header_grid.attach (play_button_grid, 1, 1, 1, 1);
        header_grid.attach (favorite_event_box, 2, 0, 1, 1);

        var body_grid = new Gtk.Grid () {
            expand = true
        };

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
