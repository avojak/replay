/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Views.Settings.ControllerSettingsPage : Granite.SettingsPage {

    private static Gtk.CssProvider provider;

    private Gtk.Stack button_stack;
    //  private Gtk.Revealer revealer;
    private Gtk.InfoBar not_configured_info_bar;
    private Gtk.InfoBar config_info_bar;
    private Gtk.Spinner spinner;
    private Gtk.Button reset_button;
    private Gtk.Button cancel_button;

    public ControllerSettingsPage.for_keyboard (string name) {
        Object (
            //  activatable: false,
            //  description: core.info.system_name,
            //  header: null,
            //  icon_name: "input-keyboard",
            //  title: name
            //  status: core.info.display_version,
            //  core: core
        );
    }

    public ControllerSettingsPage.for_gamepad (string device_name) {
        Object (
            //  activatable: false,
            //  description: core.info.system_name,
            //  header: null,
            //  icon_name: "input-gaming",
            //  title: device_name
            //  status: core.info.display_version,
            //  core: core
        );
    }

    static construct {
        provider = new Gtk.CssProvider ();
        provider.load_from_resource ("com/github/avojak/replay/ControllerConfigInfoBar.css");
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
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

        //  show_all ();

        //  var info_bar = new Gtk.Grid () {
        //      hexpand = true
        //  };
        //  //  info_bar.get_style_context ().add_class (Gtk.STYLE_CLASS_INFO);
        //  info_bar.attach (new Gtk.Label ("Press the next button…"), 0, 0);

        //  revealer = new Gtk.Revealer () {
        //      child = info_bar
        //  };
        //  revealer.get_style_context ().add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        //  revealer.get_style_context ().add_class ("controller-config-revealer");

        not_configured_info_bar = new Gtk.InfoBar () {
            show_close_button = false,
            message_type = Gtk.MessageType.WARNING,
            revealed = true
        };
        not_configured_info_bar.get_content_area ().add (new Gtk.Label ("Device has not yet been configured"));
        not_configured_info_bar.add_button ("Configure", Gtk.ResponseType.ACCEPT);

        config_info_bar = new Gtk.InfoBar () {
            show_close_button = false,
            message_type = Gtk.MessageType.QUESTION,
            revealed = false
        };
        config_info_bar.get_style_context ().add_class ("controller-config-infobar");
        spinner = new Gtk.Spinner ();
        config_info_bar.get_content_area ().add (spinner);
        config_info_bar.get_content_area ().add (new Gtk.Label ("Press the next button…"));
        config_info_bar.add_button ("Skip", Gtk.ResponseType.REJECT);

        var content_area = new Gtk.Grid () {
            expand = true,
            margin = 10
        };

        // TODO: Placeholder - add a visualization of an SDL controller
        content_area.attach (new Granite.Widgets.AlertView ("Not Configured", "Device has not yet been configured", "dialog-warning"), 0, 0);

        // Configure the action buttons

        reset_button = new Gtk.Button.with_label (_("Reset")) {
            sensitive = false
        };
        reset_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
        cancel_button = new Gtk.Button.with_label (_("Cancel"));
        cancel_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);

        button_stack = new Gtk.Stack ();
        button_stack.add (reset_button);
        button_stack.add (cancel_button);

        var action_area = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
            margin = 10,
            halign = Gtk.Align.END
        };
        //  action_area.pack_start (reset_button);
        action_area.pack_end (button_stack);

        var base_grid = new Gtk.Grid ();
        base_grid.attach (not_configured_info_bar, 0, 0);
        base_grid.attach (config_info_bar, 0, 1);
        base_grid.attach (content_area, 0, 2);
        base_grid.attach (action_area, 0, 3);

        child = base_grid;

        cancel_button.clicked.connect (on_cancel_button_clicked);
        reset_button.clicked.connect (on_reset_button_clicked);
        config_info_bar.response.connect ((response_id) => {
            if (response_id == Gtk.ResponseType.REJECT) {
                on_skip_button_clicked ();
            }
        });
        not_configured_info_bar.response.connect ((response_id) => {
            if (response_id == Gtk.ResponseType.ACCEPT) {
                on_configure_button_clicked ();
            }
        });

        show_all ();
    }

    private void on_configure_button_clicked () {
        button_stack.set_visible_child (cancel_button);
        spinner.start ();
        not_configured_info_bar.set_revealed (false);
        config_info_bar.set_revealed (true);

        configuring ();
    }

    private void on_cancel_button_clicked () {
        button_stack.set_visible_child (reset_button);
        config_info_bar.set_revealed (false);
        not_configured_info_bar.set_revealed (true);
        spinner.stop ();

        configuration_reset ();
    }

    private void on_reset_button_clicked () {
        reset_button.sensitive = false;
        not_configured_info_bar.set_revealed (true);

        configuration_reset ();
    }

    private void on_skip_button_clicked () {
        // TODO
        on_configuration_complete ();
    }

    private void on_configuration_complete () {
        reset_button.sensitive = true;
        button_stack.set_visible_child (reset_button);
        config_info_bar.set_revealed (false);
        not_configured_info_bar.set_revealed (false);
        spinner.stop ();

        device_configured ();
    }

    public signal void device_configured ();
    public signal void configuring ();
    public signal void configuration_reset ();

}
