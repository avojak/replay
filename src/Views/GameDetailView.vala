/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Views.GameDetailView : Gtk.Grid {

    public unowned Replay.Widgets.LibraryItem library_item { get; construct; }

    private Gtk.Image favorite_image;
    private Gtk.Label time_played_label;
    private Gtk.Label last_played_label;
    private Gtk.ScrolledWindow scrolled_window;

    public GameDetailView.for_library_item (Replay.Widgets.LibraryItem library_item) {
        Object (
            expand: true,
            margin: 30,
            column_spacing: 16,
            library_item: library_item
        );
    }

    construct {
        var header_grid = new Gtk.Grid () {
            margin_bottom = 10,
            column_spacing = 10,
            row_spacing = 20,
            hexpand = true,
            vexpand = false
        };

        var header_image = get_image ();

        var header_title_label = new Gtk.Label (library_item.game.display_name) {
            tooltip_text = library_item.game.display_name,
            valign = Gtk.Align.END,
            halign = Gtk.Align.START,
            hexpand = true,
            vexpand = true,
            wrap = false,
            ellipsize = Pango.EllipsizeMode.END
        };
        header_title_label.get_style_context ().add_class (Granite.STYLE_CLASS_H1_LABEL);

        var platform_label = new Gtk.Label (library_item.game.libretro_details == null ? "" : library_item.game.libretro_details.platform_name) {
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

        var more_button = new Gtk.MenuButton () {
            image = new Gtk.Image.from_icon_name ("view-more", Gtk.IconSize.SMALL_TOOLBAR),
            tooltip_text = _("Choose system…")
        };
        more_button.popup = create_run_with_menu ();

        var play_button_grid = new Gtk.Grid () {
            valign = Gtk.Align.START,
            halign = Gtk.Align.START,
            vexpand = true
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
                library_item.game.is_favorite = false;
                favorite_image.icon_name = "non-starred";
                favorite_image.tooltip_text = _("Add to favorites");
            } else {
                library_item.game.is_favorite = true;
                favorite_image.icon_name = "starred";
                favorite_image.tooltip_text = _("Remove from favorites");
            }
        });


        header_grid.attach (header_image, 0, 0, 1, 2);
        header_grid.attach (header_title_label, 1, 0, 1, 1);
        header_grid.attach (favorite_event_box, 2, 0, 1, 1);
        header_grid.attach (play_button_grid, 1, 1, 1, 1);

        var media = new Gtk.Grid () {
            hexpand = true
        };
        media.attach (new Granite.HeaderLabel ("Media") {
            hexpand = false
        }, 0, 0);
        var media_grid = new Replay.Widgets.MediaGrid ();
        string? box_art_file_path = Replay.Core.Client.get_default ().game_art_repository.get_box_art_file_path (library_item.game);
        string? screenshot_art_file_path = Replay.Core.Client.get_default ().game_art_repository.get_screenshot_art_file_path (library_item.game);
        string? titlescreen_art_file_path = Replay.Core.Client.get_default ().game_art_repository.get_titlescreen_art_file_path (library_item.game);
        if (box_art_file_path != null) {
            media_grid.add_media (GLib.File.new_for_path (box_art_file_path));
        }
        if (titlescreen_art_file_path != null) {
            media_grid.add_media (GLib.File.new_for_path (titlescreen_art_file_path));
        }
        if (screenshot_art_file_path != null) {
            media_grid.add_media (GLib.File.new_for_path (screenshot_art_file_path));
        }
        media.attach (media_grid, 0, 1, 2, 1);

        string? franchise = library_item.game.libretro_details == null ? null : library_item.game.libretro_details.franchise_name;
        var franchise_games = new Gtk.Grid () {
            hexpand = true,
            column_homogeneous = false
        };
        var franchise_games_label = new Granite.HeaderLabel (franchise == null ? "" : _("Other Games in the %s Franchise").printf (franchise)) {
            hexpand = false
        };
        var franchise_games_grid = new Replay.Widgets.GameGrid ();
        franchise_games.attach (franchise_games_label, 0, 0);
        franchise_games.attach (franchise_games_grid, 0, 1, 2, 1);
        franchise_games.set_visible (false);

        string? genre = library_item.game.libretro_details == null ? null : library_item.game.libretro_details.genre_name;
        var genre_games = new Gtk.Grid () {
            hexpand = true,
            column_homogeneous = false
        };
        var genre_games_label = new Granite.HeaderLabel (genre == null ? "" : _("Other %s Games").printf (genre)) {
            hexpand = false
        };
        var genre_games_grid = new Replay.Widgets.GameGrid ();
        genre_games.attach (genre_games_label, 0, 0);
        genre_games.attach (genre_games_grid, 0, 1, 2, 1);
        genre_games.set_visible (false);

        var detail_grid = new Gtk.Grid () {
            hexpand = false,
            vexpand = true,
            margin = 12,
            row_spacing = 10
        };

        if (library_item.game.libretro_details != null) {
            if (library_item.game.libretro_details.platform_name != null) {
                string? display_name = Replay.Models.LibretroSystemMapping.get_default ().get_display_name (library_item.game.libretro_details.platform_name);
                detail_grid.attach (new Gtk.Image.from_icon_name ("input-gaming-symbolic", Gtk.IconSize.BUTTON) {
                    margin_end = 6
                }, 0, 0);
                detail_grid.attach (new Gtk.Label ("<b>System:</b> %s".printf (display_name == null ? library_item.game.libretro_details.platform_name : display_name)) {
                    halign = Gtk.Align.START,
                    use_markup = true
                }, 1, 0);
            }

            if (library_item.game.libretro_details.genre_name != null) {
                detail_grid.attach (new Gtk.Image.from_icon_name ("applications-games-symbolic", Gtk.IconSize.BUTTON) {
                    margin_end = 6
                }, 0, 1);
                detail_grid.attach (new Gtk.Label ("<b>Genre:</b> %s".printf (library_item.game.libretro_details.genre_name)) {
                    halign = Gtk.Align.START,
                    use_markup = true
                }, 1, 1);
            }

            if (library_item.game.libretro_details.developer_name != null) {
                detail_grid.attach (new Gtk.Image.from_icon_name ("system-users-symbolic", Gtk.IconSize.BUTTON) {
                    margin_end = 6
                }, 0, 2);
                detail_grid.attach (new Gtk.Label ("<b>Developer:</b> %s".printf (library_item.game.libretro_details.developer_name)) {
                    halign = Gtk.Align.START,
                    use_markup = true
                }, 1, 2);
            }

            if (library_item.game.libretro_details.release_year != null) {
                detail_grid.attach (new Gtk.Image.from_icon_name ("x-office-calendar-symbolic", Gtk.IconSize.BUTTON) {
                    margin_end = 6
                }, 0, 3);
                //  debug ("%d", library_item.game.libretro_details.release_year);
                //  debug ("%d", library_item.game.libretro_details.release_month);
                //  var release_date = new GLib.DateTime.local (library_item.game.libretro_details.release_year, library_item.game.libretro_details.release_month == null ? 0 : library_item.game.libretro_details.release_month, 1, 1, 1, 0);
                //  debug (release_date.to_string ());
                //  var value = library_item.game.libretro_details.release_month == null ? library_item.game.libretro_details.release_year.to_string () : release_date.format (Granite.DateTime.get_default_date_format (false, false, true));
                detail_grid.attach (new Gtk.Label ("<b>Release Year:</b> %s".printf (library_item.game.libretro_details.release_year.to_string ())) {
                    halign = Gtk.Align.START,
                    use_markup = true
                }, 1, 3);
            }

            if (library_item.game.libretro_details.region_name != null) {
                detail_grid.attach (new Gtk.Image.from_icon_name ("location-active-symbolic", Gtk.IconSize.BUTTON) {
                    margin_end = 6
                }, 0, 4);
                detail_grid.attach (new Gtk.Label ("<b>Region:</b> %s".printf (library_item.game.libretro_details.region_name)) {
                    halign = Gtk.Align.START,
                    use_markup = true
                }, 1, 4);
            }

            // TODO: This is a placeholder
            detail_grid.attach (new Gtk.Image.from_icon_name ("preferences-system-parental-controls-symbolic", Gtk.IconSize.BUTTON) {
                margin_end = 6
            }, 0, 5);
            detail_grid.attach (new Gtk.Label ("<b>Rating:</b> %s".printf ("E - Everyone")) {
                halign = Gtk.Align.START,
                use_markup = true
            }, 1, 5);

            detail_grid.attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 0, 6, 2, 1);
        }

        detail_grid.attach (new Gtk.Image.from_icon_name ("x-office-calendar-symbolic", Gtk.IconSize.BUTTON) {
            margin_end = 6
        }, 0, 7);
        last_played_label = new Gtk.Label (null) {
            halign = Gtk.Align.START,
            use_markup = true
        };
        detail_grid.attach (last_played_label, 1, 7);

        detail_grid.attach (new Gtk.Image.from_icon_name ("tools-timer-symbolic", Gtk.IconSize.BUTTON) {
            margin_end = 6
        }, 0, 8);
        time_played_label = new Gtk.Label (null) {
            halign = Gtk.Align.START,
            use_markup = true
        };
        detail_grid.attach (time_played_label, 1, 8);

        // TODO: Show a way to get to game save file (if one exists)

        //  var game_summary = new Gtk.Label ("Bowser has once again taken over the Mushroom Kingdom, and it's up to Mario to put an end to his sinister reign. Battle Bowser's vile henchmen through 32 different levels - all taken directly from the 1985 classic! Then move on to collect special Red Coins and Yoshi Eggs in the Challenge Mode. Or face off against a friend and race through 8 competition courses in the all-new VS Mode! This time there's a lot more to do than just save a Princess, so get ready for a brick-smashin', pipe-warpin', turtle-stompin' good time!") {
        var synopsis_grid = new Gtk.Grid () {
            hexpand = true
        };
        string? placeholder_text = "Once upon a time, the peaceful Mushroom Kingdom was invaded by the Koopa, a tribe of turtles famous for their dark magic. These terrible terrapins transformed the peace loving Mushroom People into stones, bricks, and ironically, mushrooms, then set their own evil king on the throne. In the wake of the ghastly coup d'etat, the beautiful Mushroom Kingdom fell into ruin and despair.\n\nIt is said that only the daughter of the Mushroom King, Princess Toadstool, can break the evil spell and return the inhabitants of Mushroom kingdom to their normal selves.\n\nBut the King of the Koopas, knowing of this prophecy, kidnapped the lovely Princess and hid her away in one of his castles.\n\nWord of the terrible plight of the Mushroom People quickly spread throughout the land, eventually reaching the ears of a humble plumber. The simple, yet valiant Mario vowed to rescue the Princess and free her subjects from King Koopa's tyrannous reign. But can Mario really overcome the many obstacles facing him and become a true hero?";
        var synopsis_label = new Gtk.Label (placeholder_text) {
            margin = 12,
            hexpand = true,
            vexpand = false,
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD
        };
        if (placeholder_text != null) {
            synopsis_grid.attach (new Granite.HeaderLabel (_("Synopsis")), 0, 0);
            synopsis_grid.attach (synopsis_label, 0, 1);
        }

        //  body_grid.attach (detail_grid, 1, 0, 1, 3);

        var scroll_area = new Gtk.Grid () {
            expand = true
        };
        scroll_area.attach (synopsis_grid, 0, 0);
        scroll_area.attach (media, 0, 1);
        scroll_area.attach (franchise_games, 0, 2);
        scroll_area.attach (genre_games, 0, 3);

        scrolled_window = new Gtk.ScrolledWindow (null, null) {
            expand = true
        };
        scrolled_window.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
        scrolled_window.add (scroll_area);

        attach (header_grid, 0, 0, 2, 1);
        attach (detail_grid, 0, 1);
        attach (scrolled_window, 1, 1);
        show_all ();

        // Populate the franchise and genre game grids
        franchise_games.set_visible (false);
        genre_games.set_visible (false);
        foreach (var game in Replay.Core.Client.get_default ().game_library.get_games ()) {
            if (library_item.game == game || game.libretro_details == null) {
                continue;
            }
            string? other_franchise = game.libretro_details.franchise_name;
            if ((franchise != null) && (other_franchise != null) && (franchise == other_franchise)) {
                franchise_games.set_visible (true);
                franchise_games_grid.add_game (game);
                // Don't duplicate a game in both the franchise and the genre section, but prefer franchise over genre
                continue;
            }
            string? other_genre = game.libretro_details.genre_name;
            if ((genre != null) && (other_genre != null) && (genre == other_genre)) {
                genre_games.set_visible (true);
                genre_games_grid.add_game (game);
            }
        }

        // Don't show an empty media section if there isn't any to show
        if (box_art_file_path == null && screenshot_art_file_path == null && titlescreen_art_file_path == null) {
            media.set_visible (false);
        }

        // Connect to signals for the franchise games grid
        franchise_games_grid.item_selected.connect ((library_item) => {
            item_selected (library_item);
        });
        franchise_games_grid.item_run.connect ((library_item, core_name) => {
            play_button_clicked (library_item, core_name);
        });

        // Connect to signals for the genre games grid
        genre_games_grid.item_selected.connect ((library_item) => {
            item_selected (library_item);
        });
        genre_games_grid.item_run.connect ((library_item, core_name) => {
            play_button_clicked (library_item, core_name);
        });

        // Update information when attributes of the game model change
        library_item.game.notify["is-favorite"].connect (update_favorite);
        update_favorite ();
        library_item.game.notify["last-played"].connect (update_last_played);
        update_last_played ();
        library_item.game.notify["time-played"].connect (update_time_played);
        update_time_played ();

        // "Good enough" approach to update the Last Played time periodically while using the app
        this.map.connect (update_last_played);
    }

    //  private string build_genre_year_publisher_text () {
    //      var genre_year_publisher_data = new Gee.ArrayList<string> ();
    //      if (library_item.game.libretro_details.genre_name != null) {
    //          genre_year_publisher_data.add (library_item.game.libretro_details.genre_name);
    //      }
    //      if (library_item.game.libretro_details.release_year != null) {
    //          genre_year_publisher_data.add (library_item.game.libretro_details.release_year.to_string ());
    //      }
    //      if (library_item.game.libretro_details.developer_name != null) {
    //          genre_year_publisher_data.add (library_item.game.libretro_details.developer_name);
    //      }
    //      if (genre_year_publisher_data.size > 0) {
    //          return string.joinv (" • ", genre_year_publisher_data.to_array ());
    //      } else {
    //          return "";
    //      }
    //  }

    public void reset_scroll () {
        Idle.add (() => {
            scrolled_window.get_vadjustment ().set_value (0);
            return false;
        });
    }

    private void update_favorite () {
        favorite_image.icon_name = library_item.game.is_favorite ? "starred" : "non-starred";
        favorite_image.tooltip_text = library_item.game.is_favorite ? _("Remove from favorites") : _("Add to favorites");
    }

    private void update_last_played () {
        last_played_label.set_markup ("<b>Last Played:</b> %s".printf (library_item.game.last_played == null ? _("Never") : Granite.DateTime.get_relative_datetime (library_item.game.last_played)));
    }

    private void update_time_played () {
        time_played_label.set_markup ("<b>Play Time:</b> %s".printf (library_item.game.time_played == 0 ? _("None") : format_time_played (library_item.game.time_played)));
    }

    private string format_time_played (int time_played_seconds) {
        int hours = time_played_seconds / (60 * 60);
        if (hours > 0) {
            return _("%i hours").printf (hours);
        }
        int minutes = time_played_seconds / 60;
        if (minutes > 0) {
            return _("%i minutes").printf (minutes);
        }
        return _("%i seconds").printf (time_played_seconds);
    }

    private Gtk.Image get_image () {
        try {
            string? box_art_file_path = Replay.Core.Client.get_default ().game_art_repository.get_box_art_file_path (library_item.game);
            if (box_art_file_path == null) {
                return get_default_image ();
            } else {
                return new Gtk.Image.from_pixbuf (new Gdk.Pixbuf.from_file_at_size (box_art_file_path, 100, 100)) {
                    margin = 12
                };
            }
        } catch (GLib.Error e) {
            warning (e.message);
            return get_default_image ();
        }
    }

    private Gtk.Image get_default_image () {
        return new Gtk.Image () {
            gicon = new ThemedIcon ("application-default-icon"),
            pixel_size = 128,
            margin = 8
        };
    }

    private Gtk.Menu create_run_with_menu () {
        var menu = new Gtk.Menu ();
        foreach (var core in Replay.Core.Client.get_default ().core_repository.get_cores_for_rom (GLib.File.new_for_path (library_item.game.rom_path))) {
            var core_name = core.info.core_name;
            var item = new Gtk.MenuItem.with_label (_("Play with %s").printf (core_name));
            item.activate.connect (() => {
                play_button_clicked (library_item, core_name);
            });
            menu.add (item);
        }
        menu.show_all ();
        return menu;
    }

    public signal void play_button_clicked (Replay.Widgets.LibraryItem? library_item, string? core_name = null);
    public signal void item_selected (Replay.Widgets.LibraryItem library_item);

}
