/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Widgets.MainHeaderBar : Hdy.HeaderBar {

    private Gtk.ToggleButton find_button;
    private Gtk.Button return_button;
    private Gtk.Separator return_button_separator;
    private Gtk.SearchEntry search_entry;

    public MainHeaderBar () {
        Object (
            title: Constants.APP_NAME,
            show_close_button: true,
            has_subtitle: false
            //  decoration_layout: ":maximize"
        );
    }

    construct {
        get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        return_button = new Gtk.Button.with_label (_("Library")) {
            no_show_all = true,
            valign = Gtk.Align.CENTER,
            vexpand = false
        };
        return_button.get_style_context ().add_class ("back-button");
        return_button.clicked.connect (() => {
            view_return ();
        });
        return_button_separator = new Gtk.Separator (Gtk.Orientation.VERTICAL);
        return_button_separator.no_show_all = true;

        // TODO: Add ability to open a ROM file not in the library

        // TODO: Allow changing the icon size for the icons in the view

        find_button = new Gtk.ToggleButton () {
            action_name = Replay.Services.LibraryWindowActionManager.ACTION_PREFIX + Replay.Services.LibraryWindowActionManager.ACTION_SHOW_FIND,
            image = new Gtk.Image.from_icon_name ("edit-find-symbolic", Gtk.IconSize.SMALL_TOOLBAR),
            tooltip_markup = Granite.markup_accel_tooltip (
                Replay.Application.get_instance ().get_accels_for_action (Replay.Services.LibraryWindowActionManager.ACTION_PREFIX + Replay.Services.LibraryWindowActionManager.ACTION_SHOW_FIND),
                _("Find…")
            ),
            relief = Gtk.ReliefStyle.NONE,
            valign = Gtk.Align.CENTER
        };

        var settings_button = new Gtk.MenuButton () {
            image = new Gtk.Image.from_icon_name ("preferences-system-symbolic", Gtk.IconSize.SMALL_TOOLBAR),
            tooltip_text = _("Menu"),
            relief = Gtk.ReliefStyle.NONE,
            valign = Gtk.Align.CENTER
        };

        var toggle_sidebar_accellabel = new Granite.AccelLabel.from_action_name (
            _("Toggle Sidebar"),
            Replay.Services.LibraryWindowActionManager.ACTION_PREFIX + Replay.Services.LibraryWindowActionManager.ACTION_TOGGLE_SIDEBAR
        );

        var toggle_sidebar_menu_item = new Gtk.ModelButton ();
        toggle_sidebar_menu_item.action_name = Replay.Services.LibraryWindowActionManager.ACTION_PREFIX + Replay.Services.LibraryWindowActionManager.ACTION_TOGGLE_SIDEBAR;
        toggle_sidebar_menu_item.get_child ().destroy ();
        toggle_sidebar_menu_item.add (toggle_sidebar_accellabel);

        var preferences_accellabel = new Granite.AccelLabel.from_action_name (
            _("Preferences…"),
            Replay.Services.LibraryWindowActionManager.ACTION_PREFIX + Replay.Services.LibraryWindowActionManager.ACTION_PREFERENCES
        );

        var preferences_menu_item = new Gtk.ModelButton ();
        preferences_menu_item.action_name = Replay.Services.LibraryWindowActionManager.ACTION_PREFIX + Replay.Services.LibraryWindowActionManager.ACTION_PREFERENCES;
        preferences_menu_item.get_child ().destroy ();
        preferences_menu_item.add (preferences_accellabel);

        var about_accellabel = new Granite.AccelLabel.from_action_name (
            _("About…"),
            Replay.Services.LibraryWindowActionManager.ACTION_PREFIX + Replay.Services.LibraryWindowActionManager.ACTION_ABOUT
        );

        var about_menu_item = new Gtk.ModelButton ();
        about_menu_item.action_name = Replay.Services.LibraryWindowActionManager.ACTION_PREFIX + Replay.Services.LibraryWindowActionManager.ACTION_ABOUT;
        about_menu_item.get_child ().destroy ();
        about_menu_item.add (about_accellabel);

        var quit_accellabel = new Granite.AccelLabel.from_action_name (
            _("Quit"),
            Replay.Services.LibraryWindowActionManager.ACTION_PREFIX + Replay.Services.LibraryWindowActionManager.ACTION_QUIT
        );

        var quit_menu_item = new Gtk.ModelButton ();
        quit_menu_item.action_name = Replay.Services.LibraryWindowActionManager.ACTION_PREFIX + Replay.Services.LibraryWindowActionManager.ACTION_QUIT;
        quit_menu_item.get_child ().destroy ();
        quit_menu_item.add (quit_accellabel);

        var settings_popover_grid = new Gtk.Grid () {
            margin_top = 3,
            margin_bottom = 3,
            orientation = Gtk.Orientation.VERTICAL,
            width_request = 200
        };
        settings_popover_grid.attach (toggle_sidebar_menu_item, 0, 0);
        settings_popover_grid.attach (preferences_menu_item, 0, 1);
        settings_popover_grid.attach (create_menu_separator (), 0, 2);
        settings_popover_grid.attach (about_menu_item, 0, 3);
        settings_popover_grid.attach (create_menu_separator (), 0, 4);
        settings_popover_grid.attach (quit_menu_item, 0, 5);
        settings_popover_grid.show_all ();

        var settings_popover = new Gtk.Popover (null);
        settings_popover.add (settings_popover_grid);

        settings_button.popover = settings_popover;

        search_entry = new Gtk.SearchEntry () {
            placeholder_text = _("Search Games")
        };
        search_entry.search_changed.connect (() => {
            search_changed (search_entry.get_text ());
        });

        pack_start (return_button);
        pack_start (return_button_separator);

        pack_end (settings_button);
        //  pack_end (new Gtk.Separator (Gtk.Orientation.VERTICAL));
        //  pack_end (find_button);
        pack_end (search_entry);
    }

    private Gtk.Separator create_menu_separator (int margin_top = 0) {
        var menu_separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        menu_separator.margin_top = margin_top;
        return menu_separator;
    }

    public void set_return_button_visible (bool visible) {
        return_button.no_show_all = !visible;
        return_button.visible = visible;
        return_button_separator.no_show_all = !visible;
        return_button_separator.visible = visible;
    }

    public void set_return_button_game (string? game_display_name) {
        if (game_display_name == null) {
            return_button.set_label (_("Library"));
            return_button.set_tooltip_text (null);
        } else {
            return_button.set_label (game_display_name.length > 20 ? "%s…".printf (game_display_name.substring (0, 20)) : game_display_name);
            return_button.set_tooltip_text (game_display_name.length > 20 ? game_display_name : null);
        }
    }

    public void update_find_button_state (bool new_state) {
        find_button.active = new_state;
        if (new_state) {
            find_button.action_name = Replay.Services.LibraryWindowActionManager.ACTION_PREFIX + Replay.Services.LibraryWindowActionManager.ACTION_HIDE_FIND;
            find_button.tooltip_markup = Granite.markup_accel_tooltip (
                {"Escape"},
                _("Hide search bar")
            );
        } else {
            find_button.action_name = Replay.Services.LibraryWindowActionManager.ACTION_PREFIX + Replay.Services.LibraryWindowActionManager.ACTION_SHOW_FIND;
            find_button.tooltip_markup = Granite.markup_accel_tooltip (
                Replay.Application.get_instance ().get_accels_for_action (Replay.Services.LibraryWindowActionManager.ACTION_PREFIX + Replay.Services.LibraryWindowActionManager.ACTION_SHOW_FIND),
                _("Find…")
            );
        }
    }

    public signal void view_return ();
    public signal void search_changed (string search_text);

}
