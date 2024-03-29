/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Widgets.EmulatorHeaderBar : Hdy.HeaderBar {

    public unowned Replay.Windows.EmulatorWindow window { get; construct; }

    private Replay.Widgets.Dialogs.RestartConfirmationDialog? restart_confirmation_dialog = null;

    private Gtk.Button pause_button;
    private Gtk.Button resume_button;

    private Granite.Widgets.ModeButton video_filter_button;

    private Gee.Map<int, Retro.VideoFilter> video_filter_button_map;

    public EmulatorHeaderBar (Replay.Windows.EmulatorWindow window, string title) {
        Object (
            window: window,
            title: title,
            show_close_button: true,
            has_subtitle: false
        );
    }

    construct {
        get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        pause_button = new Gtk.Button () {
            image = new Gtk.Image.from_icon_name ("media-playback-pause", Gtk.IconSize.SMALL_TOOLBAR),
            tooltip_text = _("Pause"),
            relief = Gtk.ReliefStyle.NONE,
            valign = Gtk.Align.CENTER
        };

        resume_button = new Gtk.Button () {
            image = new Gtk.Image.from_icon_name ("media-playback-start", Gtk.IconSize.SMALL_TOOLBAR),
            tooltip_text = _("Resume"),
            relief = Gtk.ReliefStyle.NONE,
            valign = Gtk.Align.CENTER
        };

        var restart_button = new Gtk.Button () {
            image = new Gtk.Image.from_icon_name ("view-refresh", Gtk.IconSize.SMALL_TOOLBAR),
            tooltip_text = _("Restart"),
            relief = Gtk.ReliefStyle.NONE,
            valign = Gtk.Align.CENTER
        };

        var menu_button = new Gtk.MenuButton () {
            image = new Gtk.Image.from_icon_name ("preferences-system-symbolic", Gtk.IconSize.SMALL_TOOLBAR),
            tooltip_text = _("Menu"),
            relief = Gtk.ReliefStyle.NONE,
            valign = Gtk.Align.CENTER
        };

        video_filter_button_map = new Gee.HashMap<int, Retro.VideoFilter> ();
        video_filter_button_map.set (0, Retro.VideoFilter.SHARP);
        video_filter_button_map.set (1, Retro.VideoFilter.SMOOTH);
        video_filter_button_map.set (2, Retro.VideoFilter.CRT);

        video_filter_button = new Granite.Widgets.ModeButton () {
            margin = 12
        };
        video_filter_button.mode_added.connect ((index, widget) => {
            widget.set_tooltip_markup (Replay.Models.VideoFilterMapping.get_descriptions ().get (video_filter_button_map.get (index)));
        });
        video_filter_button.mode_changed.connect (() => {
            video_filter_changed (video_filter_button_map.get (video_filter_button.selected));
        });
        foreach (var entry in video_filter_button_map.entries) {
            video_filter_button.append_text (Replay.Models.VideoFilterMapping.get_display_strings ().get (entry.value));
        }

        //  var decrease_speed_button = new Gtk.Button.from_icon_name ("zoom-out-symbolic", Gtk.IconSize.MENU);
        //  //  decrease_speed_button.action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_ZOOM_OUT;
        //  decrease_speed_button.tooltip_markup = _("Increase Speed");

        //  var default_speed_button = new Gtk.Button.with_label ("100%");
        //  //  default_speed_button.action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_ZOOM_DEFAULT;
        //  default_speed_button.tooltip_markup = _("Default Speed");

        //  var increase_speed_button = new Gtk.Button.from_icon_name ("zoom-in-symbolic", Gtk.IconSize.MENU);
        //  //  increase_speed_button.action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_ZOOM_IN;
        //  increase_speed_button.tooltip_markup = _("Decrease Speed");

        //  var speed_grid = new Gtk.Grid ();
        //  speed_grid.column_homogeneous = true;
        //  speed_grid.hexpand = true;
        //  speed_grid.margin = 12;
        //  speed_grid.get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);
        //  speed_grid.add (decrease_speed_button);
        //  speed_grid.add (default_speed_button);
        //  speed_grid.add (increase_speed_button);

        var speed_label = new Gtk.Label (_("Emulation speed:")) {
            halign = Gtk.Align.END
        };
        var speed_spin_button = create_spin_button (1.0, 3.0, Replay.Application.settings.emu_default_speed);
        var speed_grid = new Gtk.Grid () {
            column_homogeneous = true,
            hexpand = true,
            margin_start = 12,
            margin_end = 12,
            margin_bottom = 12,
            column_spacing = 6
        };
        speed_grid.attach (speed_label, 0, 0);
        speed_grid.attach (speed_spin_button, 1, 0);

        //  var controller_button = new Gtk.ModelButton () {
        //      text = _("Controller"),
        //      menu_name = "controller"
        //  }; //new Gtk.MenuItem.with_label ("Controller");
        //  var controller_menu = new Gtk.Grid () {
        //      margin_top = 3,
        //      margin_bottom = 3,
        //      orientation = Gtk.Orientation.VERTICAL,
        //      width_request = 200
        //  };
        //  //  foreach (var core in Replay.Core.Client.get_default ().core_repository.get_cores_for_rom (GLib.File.new_for_path (library_item.game.rom_path))) {
        //      //  var core_name = core.info.core_name;
        //  var keyboard_item = new Gtk.MenuItem.with_label ("Keyboard");
        //  keyboard_item.activate.connect (() => {
        //      //  on_item_run_selected (library_item, core_name);
        //  });
        //  controller_menu.attach (keyboard_item, 0, 0);
        //  controller_menu.show_all ();
        //  }
        //  controller_button.set_submenu (controller_menu);

        // TODO: Add item for snapshot savestate?
        // TODO: Add item for screenshot?
        // TODO: Add item for opening the library
        // TODO: Add item for showing emulator mapped controls?

        var toggle_statsbar_accellabel = new Granite.AccelLabel.from_action_name (
            _("Toggle Statsbar"),
            Replay.Services.EmulatorWindowActionManager.ACTION_PREFIX + Replay.Services.EmulatorWindowActionManager.ACTION_TOGGLE_STATSBAR
        );

        var toggle_statsbar_menu_item = new Gtk.ModelButton ();
        toggle_statsbar_menu_item.action_name = Replay.Services.EmulatorWindowActionManager.ACTION_PREFIX + Replay.Services.EmulatorWindowActionManager.ACTION_TOGGLE_STATSBAR;
        toggle_statsbar_menu_item.get_child ().destroy ();
        toggle_statsbar_menu_item.add (toggle_statsbar_accellabel);

        var quit_accellabel = new Granite.AccelLabel.from_action_name (
            _("Quit Game"),
            Replay.Services.EmulatorWindowActionManager.ACTION_PREFIX + Replay.Services.EmulatorWindowActionManager.ACTION_QUIT
        );

        var quit_menu_item = new Gtk.ModelButton ();
        quit_menu_item.action_name = Replay.Services.EmulatorWindowActionManager.ACTION_PREFIX + Replay.Services.EmulatorWindowActionManager.ACTION_QUIT;
        quit_menu_item.get_child ().destroy ();
        quit_menu_item.add (quit_accellabel);

        var main_menu = new Gtk.Grid () {
            margin_bottom = 3,
            orientation = Gtk.Orientation.VERTICAL,
            width_request = 200
        };
        main_menu.attach (video_filter_button, 0, 0, 3, 1);
        main_menu.attach (speed_grid, 0, 1, 3, 1);
        main_menu.attach (create_menu_separator (), 0, 2);
        main_menu.attach (toggle_statsbar_menu_item, 0, 3);
        main_menu.attach (create_menu_separator (), 0, 4);
        main_menu.attach (quit_menu_item, 0, 5);

        main_menu.show_all ();

        var settings_popover = new Gtk.PopoverMenu ();
        settings_popover.add (main_menu);
        menu_button.popover = settings_popover;

        pack_start (pause_button);
        pack_start (resume_button);
        //  pack_start (restart_button);
        pack_end (menu_button);
        //  pack_end (new Gtk.VolumeButton () {
        //      use_symbolic = true
        //  });

        set_pause_button_visible (true);
        set_resume_button_visible (false);

        pause_button.clicked.connect (() => {
            pause_button_clicked ();
            set_pause_button_visible (false);
            set_resume_button_visible (true);
        });
        resume_button.clicked.connect (() => {
            resume_button_clicked ();
            set_pause_button_visible (true);
            set_resume_button_visible (false);
        });
        restart_button.clicked.connect (() => {
            if (restart_confirmation_dialog == null) {
                restart_confirmation_dialog = new Replay.Widgets.Dialogs.RestartConfirmationDialog (window);
                restart_confirmation_dialog.show_all ();
                restart_confirmation_dialog.response.connect ((response_id) => {
                    if (response_id == Gtk.ResponseType.OK) {
                        restart_button_clicked ();
                    }
                    restart_confirmation_dialog.close ();
                });
                restart_confirmation_dialog.destroy.connect (() => {
                    restart_confirmation_dialog = null;
                });
            }
            restart_confirmation_dialog.present ();
        });
        speed_spin_button.value_changed.connect (() => {
            speed_changed (speed_spin_button.value);
        });
    }

    private Gtk.Separator create_menu_separator (int margin_top = 0) {
        var menu_separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        menu_separator.margin_top = margin_top;
        return menu_separator;
    }

    private Gtk.SpinButton create_spin_button (double min_value, double max_value, double default_value) {
        var button = new Gtk.SpinButton.with_range (min_value, max_value, 0.1) {
            halign = Gtk.Align.START
        };
        button.set_value (default_value);
        return button;
    }

    public void set_pause_button_visible (bool visible) {
        pause_button.sensitive = visible;
        pause_button.no_show_all = !visible;
        pause_button.visible = visible;
    }

    public void set_resume_button_visible (bool visible) {
        resume_button.sensitive = visible;
        resume_button.no_show_all = !visible;
        resume_button.visible = visible;
    }

    public void set_filter_mode (Retro.VideoFilter filter) {
        foreach (var entry in video_filter_button_map.entries) {
            if (filter == entry.value) {
                video_filter_button.set_active (entry.key);
                return;
            }
        }
    }

    public signal void pause_button_clicked ();
    public signal void resume_button_clicked ();
    public signal void restart_button_clicked ();
    public signal void video_filter_changed (Retro.VideoFilter filter);
    public signal void speed_changed (double speed);

}
