/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public abstract class Replay.Views.Settings.InputDeviceSettingsPage<T> : Granite.SettingsPage {

    private static Gtk.CssProvider provider;

    private Gtk.Stack button_stack;
    protected Replay.Views.GamepadView gamepad_view;
    private Granite.Widgets.AlertView not_configured_alert;
    private Gtk.InfoBar not_configured_info_bar;
    private Gtk.Label config_info_prompt;
    private Gtk.InfoBar config_info_bar;
    private Gtk.InfoBar testing_info_bar;
    private Gtk.Spinner spinner;
    private Gtk.Button configure_button;
    private Gtk.Button reset_button;
    private Gtk.Button cancel_button;

    private Replay.Services.DeviceMapper<T> device_mapper;
    private Replay.Services.DeviceTester device_tester;

    static construct {
        provider = new Gtk.CssProvider ();
        provider.load_from_resource ("com/github/avojak/replay/ControllerConfigInfoBar.css");
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
    }

    construct {
        not_configured_info_bar = new Gtk.InfoBar () {
            show_close_button = false,
            message_type = Gtk.MessageType.WARNING,
            revealed = false
        };
        not_configured_info_bar.get_content_area ().add (new Gtk.Label (_("Device not configured! Buttons may not behave as expected until configured.\nPress buttons on the device to test the configuration.")));

        config_info_bar = new Gtk.InfoBar () {
            show_close_button = false,
            message_type = Gtk.MessageType.QUESTION,
            revealed = false
        };
        config_info_bar.get_style_context ().add_class ("controller-config-infobar");
        spinner = new Gtk.Spinner ();
        config_info_bar.get_content_area ().add (spinner);
        config_info_prompt = new Gtk.Label ("");
        config_info_bar.get_content_area ().add (config_info_prompt);
        config_info_bar.add_button ("Skip", Gtk.ResponseType.REJECT);

        testing_info_bar = new Gtk.InfoBar () {
            show_close_button = false,
            message_type = Gtk.MessageType.INFO,
            revealed = false
        };
        testing_info_bar.get_content_area ().add (new Gtk.Label (_("Device configured! Press buttons on the gamepad to test the configuration.")));
        //  testing_info_bar.add_button ("Reconfigure", Gtk.ResponseType.REJECT).get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);

        //  not_configured_alert = new Granite.Widgets.AlertView ("Not Configured", "This device has not yet been configured. Buttons may not behave as expected until the device is configured.", "dialog-warning");
        //  not_configured_alert.show_action (_("Configure"));
        //  not_configured_alert.action_activated.connect (on_configure_button_clicked);

        gamepad_view = new Replay.Views.GamepadView ();

        //  config_stack = new Gtk.Stack ();
        //  config_stack.add (not_configured_alert);
        //  config_stack.add (gamepad_view);

        var content_area = new Gtk.Grid () {
            expand = true,
            margin = 10
        };
        content_area.attach (gamepad_view, 0, 0);

        // Configure the action buttons

        configure_button = new Gtk.Button.with_label (_("Configure"));
        configure_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
        reset_button = new Gtk.Button.with_label (_("Reset"));
        reset_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
        cancel_button = new Gtk.Button.with_label (_("Cancel"));
        cancel_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);

        button_stack = new Gtk.Stack ();
        button_stack.add (configure_button);
        button_stack.add (reset_button);
        button_stack.add (cancel_button);

        var action_area = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
            margin = 10,
            halign = Gtk.Align.START
        };
        action_area.pack_start (button_stack);

        var base_grid = new Gtk.Grid ();
        base_grid.attach (not_configured_info_bar, 0, 0);
        base_grid.attach (testing_info_bar, 0, 1);
        base_grid.attach (config_info_bar, 0, 2);
        base_grid.attach (content_area, 0, 3);
        base_grid.attach (action_area, 0, 4);

        child = base_grid;

        configure_button.clicked.connect (on_configure_button_clicked);
        cancel_button.clicked.connect (on_cancel_button_clicked);
        reset_button.clicked.connect (on_reset_button_clicked);
        config_info_bar.response.connect ((response_id) => {
            if (response_id == Gtk.ResponseType.REJECT) {
                on_skip_button_clicked ();
            }
        });

        show_all ();

        device_mapper = create_device_mapper ();
        device_tester = create_device_tester ();

        if (has_user_mapping ()) {
            enter_testing_mode ();
        } else {
            enter_not_configured_mode ();
        }
    }

    public abstract Replay.Services.DeviceMapper<T> create_device_mapper ();
    public abstract Replay.Services.DeviceTester create_device_tester ();
    public abstract bool has_user_mapping ();
    public abstract void save_user_mapping (T result);
    public abstract void remove_user_mapping ();

    private void enter_not_configured_mode () {
        hide_config_info_bar ();
        hide_testing_info_bar ();

        show_not_configured_info_bar ();
        show_configure_button ();

        start_tester ();
    }

    private void enter_configuring_mode () {
        hide_testing_info_bar ();
        hide_not_configured_info_bar ();

        show_config_info_bar ();
        show_cancel_button ();

        start_mapper ();
    }

    private void enter_testing_mode () {
        hide_config_info_bar ();
        hide_not_configured_info_bar ();

        show_testing_info_bar ();
        show_reset_button ();

        start_tester ();
    }

    private void start_mapper () {
        stop_tester ();

        device_mapper.prompt.connect (on_mapper_prompt_updated);
        device_mapper.finished.connect (on_mapper_finished);
        device_mapper.start ();
    }

    private void stop_mapper () {
        device_mapper.stop ();
        device_mapper.prompt.disconnect (on_mapper_prompt_updated);
        device_mapper.finished.disconnect (on_mapper_finished);
    }

    private void start_tester () {
        stop_mapper ();

        device_tester.start ();
    }

    private void stop_tester () {
        device_tester.stop ();
    }

    private void on_mapper_prompt_updated (string prompt) {
        config_info_prompt.set_text (prompt);
    }

    private void on_mapper_finished (T result) {
        save_user_mapping (result);

        enter_testing_mode ();

        device_configured ();
    }

    private void show_config_info_bar () {
        spinner.start ();
        config_info_bar.set_revealed (true);
    }

    private void hide_config_info_bar () {
        config_info_bar.set_revealed (false);
        spinner.stop ();
    }

    private void show_testing_info_bar () {
        testing_info_bar.set_revealed (true);
    }

    private void hide_testing_info_bar () {
        testing_info_bar.set_revealed (false);
    }

    private void show_not_configured_info_bar () {
        not_configured_info_bar.set_revealed (true);
    }

    private void hide_not_configured_info_bar () {
        not_configured_info_bar.set_revealed (false);
    }

    private void show_cancel_button () {
        button_stack.set_visible_child (cancel_button);
    }

    private void show_reset_button () {
        button_stack.set_visible_child (reset_button);
    }

    private void show_configure_button () {
        button_stack.set_visible_child (configure_button);
    }

    private void on_configure_button_clicked () {
        enter_configuring_mode ();

        configuring ();
    }

    private void on_cancel_button_clicked () {
        enter_not_configured_mode ();

        configuration_reset ();
    }

    private void on_reset_button_clicked () {
        var warning_dialog = new Replay.Widgets.Dialogs.InputDeviceResetWarningDialog (get_toplevel () as Gtk.Window);
        int response = warning_dialog.run ();
        warning_dialog.destroy ();

        if (response == Gtk.ResponseType.OK) {
            enter_not_configured_mode ();

            remove_user_mapping ();

            configuration_reset ();
        }
    }

    private void on_skip_button_clicked () {
        device_mapper.skip ();
    }

    public signal void device_configured ();
    public signal void configuring ();
    public signal void configuration_reset ();

}
