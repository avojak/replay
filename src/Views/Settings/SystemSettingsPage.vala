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

public class Replay.Views.Settings.SystemSettingsPage : Granite.SimpleSettingsPage {

    public Replay.Models.LibretroCore core { get; construct; }

    public SystemSettingsPage.for_core (Replay.Models.LibretroCore core, bool show_header) {
        Object (
            activatable: false,
            description: core.info.system_name,
            header: show_header ? core.info.manufacturer : null,
            icon_name: "application-x-firmware",
            title: core.info.core_name,
            //  status: core.info.display_version,
            core: core
        );
    }

    construct {
        var info_header_label = new Granite.HeaderLabel (_("Core Details"));

        var version_label = new Gtk.Label (_("Version:")) {
            halign = Gtk.Align.END
        };
        var version_value_label = new Gtk.Label (core.info.display_version) {
            halign = Gtk.Align.START
        };

        var location_label = new Gtk.Label (_("Installation Location:")) {
            halign = Gtk.Align.END
        };
        var location_link_button = new Gtk.LinkButton.with_label (GLib.File.new_for_path (core.path).get_uri (), core.path) {
            halign = Gtk.Align.START
        };

        var extensions_label = new Gtk.Label (_("Supported Extensions:")) {
            halign = Gtk.Align.END
        };
        var extensions_value_label = new Gtk.Label (string.joinv (", ", core.info.supported_extensions)) {
            halign = Gtk.Align.START
        };

        var about_header_label = new Granite.HeaderLabel (_("About"));
        var about_label = new Gtk.Label (core.info.description) {
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD,
            max_width_chars = 100
        };

        var row = 0;
        content_area.attach (info_header_label, 0, row++, 2);
        if (core.info.display_version != null) {
            content_area.attach (version_label, 0, row, 1);
            content_area.attach (version_value_label, 1, row++, 1);
        }
        content_area.attach (location_label, 0, row, 1);
        content_area.attach (location_link_button, 1, row++, 1);
        content_area.attach (extensions_label, 0, row, 1);
        content_area.attach (extensions_value_label, 1, row++, 1);
        if (core.info.description != null) {
            content_area.attach (about_header_label, 0, row++, 2);
            content_area.attach (about_label, 0, row++, 2);
        }
    }

}
