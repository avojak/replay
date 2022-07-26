/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Widgets.ControllerSettingsRow : Gtk.ListBoxRow {

    //  public enum InputType {
    //      KEYBOARD,
    //      GAMEPAD;
    //  }

    public enum Status {
        NOT_CONFIGURED,
        CONFIGURING,
        CONFIGURED;

        public string to_string () {
            switch (this) {
                case NOT_CONFIGURED:
                    return _("Not Configured");
                case CONFIGURING:
                    return _("Configuring…");
                case CONFIGURED:
                    return _("Configured");
                default:
                    assert_not_reached ();
            }
        }
    }

    public Manette.Device? device { get; construct; }
    //  public InputType input_type { get; construct; }
    public string title { get; construct; }
    public string icon_name { get; construct; }

    private Gtk.Image status_icon;
    private Gtk.Label status_label;

    public ControllerSettingsRow.for_device (Manette.Device device) {
        Object (
            device: device,
            //  input_type: InputType.GAMEPAD,
            title: device.get_name (),
            icon_name: "input-gaming"
        );
    }

    public ControllerSettingsRow.for_keyboard () {
        Object (
            title: _("Keyboard"),
            //  input_type: InputType.KEYBOARD,
            icon_name: "input-keyboard"
        );
    }

    private ControllerSettingsRow () {}

    construct {
        status_icon = new Gtk.Image.from_icon_name ("user-offline", Gtk.IconSize.MENU) {
            halign = Gtk.Align.END,
            valign = Gtk.Align.END
        };

        status_label = new Gtk.Label (null) {
            xalign = 0,
            use_markup = true
        };

        var overlay = new Gtk.Overlay ();
        overlay.add (new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.DND));
        overlay.add_overlay (status_icon);

        var grid = new Gtk.Grid () {
            margin = 6,
            column_spacing = 6,
            orientation = Gtk.Orientation.HORIZONTAL
        };
        grid.attach (overlay, 0, 0, 1, 2);
        grid.attach (new Gtk.Label (title) {
            ellipsize = Pango.EllipsizeMode.END,
            hexpand = true,
            xalign = 0
        }, 1, 0);
        grid.attach (status_label, 1, 1);

        add (grid);

        show_all ();
    }

    public void set_status (Status status) {
        status_label.label = GLib.Markup.printf_escaped ("<span font_size='small'>%s</span>", status.to_string ());
        switch (status) {
            case Status.NOT_CONFIGURED:
                status_icon.icon_name = "user-offline";
                break;
            case Status.CONFIGURING:
                status_icon.icon_name = "user-away";
                break;
            case Status.CONFIGURED:
                status_icon.icon_name = "user-available";
                break;
            default:
                assert_not_reached ();
        }
    }

}
