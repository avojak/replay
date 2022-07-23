/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Views.Settings.ControllerSettingsPage : Granite.SimpleSettingsPage {

    public ControllerSettingsPage.for_keyboard (bool show_header) {
        Object (
            activatable: false,
            //  description: core.info.system_name,
            header: show_header ? _("Keyboards") : null,
            icon_name: "input-keyboard",
            title: _("Keyboard")
            //  status: core.info.display_version,
            //  core: core
        );
    }

    construct {
        //  var info_header_label = new Granite.HeaderLabel (_("Core Details"));

        //  var version_label = new Gtk.Label (_("Version:")) {
        //      halign = Gtk.Align.END
        //  };
        //  var version_value_label = new Gtk.Label (core.info.display_version) {
        //      halign = Gtk.Align.START
        //  };

        //  var location_label = new Gtk.Label (_("Installation Location:")) {
        //      halign = Gtk.Align.END
        //  };
        //  var location_link_button = new Gtk.LinkButton.with_label (GLib.File.new_for_path (core.path).get_uri (), core.path) {
        //      halign = Gtk.Align.START
        //  };

        //  var extensions_label = new Gtk.Label (_("Supported Extensions:")) {
        //      halign = Gtk.Align.END
        //  };
        //  var extensions_value_label = new Gtk.Label (string.joinv (", ", core.info.supported_extensions)) {
        //      halign = Gtk.Align.START
        //  };

        //  var about_header_label = new Granite.HeaderLabel (_("About"));
        //  var about_label = new Gtk.Label (core.info.description) {
        //      wrap = true,
        //      wrap_mode = Pango.WrapMode.WORD,
        //      max_width_chars = 100
        //  };

        //  var row = 0;
        //  content_area.attach (info_header_label, 0, row++, 2);
        //  if (core.info.display_version != null) {
        //      content_area.attach (version_label, 0, row, 1);
        //      content_area.attach (version_value_label, 1, row++, 1);
        //  }
        //  content_area.attach (location_label, 0, row, 1);
        //  content_area.attach (location_link_button, 1, row++, 1);
        //  content_area.attach (extensions_label, 0, row, 1);
        //  content_area.attach (extensions_value_label, 1, row++, 1);
        //  if (core.info.description != null) {
        //      content_area.attach (about_header_label, 0, row++, 2);
        //      content_area.attach (about_label, 0, row++, 2);
        //  }
    }

}
