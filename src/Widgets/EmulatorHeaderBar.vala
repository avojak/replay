/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Widgets.EmulatorHeaderBar : Hdy.HeaderBar {

    private Gtk.Button pause_button;
    private Gtk.Button resume_button;

    public EmulatorHeaderBar (string title) {
        Object (
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

        var menu_button = new Gtk.MenuButton () {
            image = new Gtk.Image.from_icon_name ("preferences-system-symbolic", Gtk.IconSize.SMALL_TOOLBAR),
            tooltip_text = _("Menu"),
            relief = Gtk.ReliefStyle.NONE,
            valign = Gtk.Align.CENTER
        };

        var video_filter_button = new Granite.Widgets.ModeButton () {
            margin = 12
        };
        video_filter_button.mode_added.connect ((index, widget) => {
            switch (index) {
                case 0:
                    widget.set_tooltip_markup (Replay.Models.VideoFilterMapping.get_descriptions ().get (Retro.VideoFilter.SHARP));
                    break;
                case 1:
                    widget.set_tooltip_markup (Replay.Models.VideoFilterMapping.get_descriptions ().get (Retro.VideoFilter.SMOOTH));
                    break;
                case 2:
                    widget.set_tooltip_markup (Replay.Models.VideoFilterMapping.get_descriptions ().get (Retro.VideoFilter.CRT));
                    break;
                default:
                    assert_not_reached ();
            }
        });
        video_filter_button.append_text (Replay.Models.VideoFilterMapping.get_display_strings ().get (Retro.VideoFilter.SHARP));
        video_filter_button.append_text (Replay.Models.VideoFilterMapping.get_display_strings ().get (Retro.VideoFilter.SMOOTH));
        video_filter_button.append_text (Replay.Models.VideoFilterMapping.get_display_strings ().get (Retro.VideoFilter.CRT));

        // TODO: Add item for core speed
        // TODO: Add item for snapshot savestate?
        // TODO: Add item for screenshot?
        // TODO: Add item for opening the library
        // TODO: Add item for showing emulator mapped controls?

        var menu_popover_grid = new Gtk.Grid () {
            margin_bottom = 3,
            orientation = Gtk.Orientation.VERTICAL,
            width_request = 200
        };
        menu_popover_grid.attach (video_filter_button, 0, 0, 3, 1);

        menu_popover_grid.show_all ();

        var settings_popover = new Gtk.Popover (null);
        settings_popover.add (menu_popover_grid);
        menu_button.popover = settings_popover;

        pack_start (pause_button);
        pack_start (resume_button);
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

    public signal void pause_button_clicked ();
    public signal void resume_button_clicked ();

}
