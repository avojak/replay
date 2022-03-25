//  /*
//   * Copyright (c) 2022 Andrew Vojak (https://avojak.com)
//   *
//   * This program is free software; you can redistribute it and/or
//   * modify it under the terms of the GNU General Public
//   * License as published by the Free Software Foundation; either
//   * version 2 of the License, or (at your option) any later version.
//   *
//   * This program is distributed in the hope that it will be useful,
//   * but WITHOUT ANY WARRANTY; without even the implied warranty of
//   * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//   * General Public License for more details.
//   *
//   * You should have received a copy of the GNU General Public
//   * License along with this program; if not, write to the
//   * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
//   * Boston, MA 02110-1301 USA
//   *
//   * Authored by: Andrew Vojak <andrew.vojak@gmail.com>
//   */

//  public class Replay.Views.LibraryView : Gtk.Grid {

//      public class FilterFunc : GLib.Object {

//          public string placeholder_title { get; set; }
//          public string placeholder_description { get; set; }
//          public string placeholder_icon_name { get; set; }
//          public Filter filter { get; set; }

//          //  public FilterFunc () {
//          //      Object ();
//          //  }

//          public delegate bool Filter (Replay.Widgets.LibraryItem library_item);

//      }

//      public const string NAME = "Library";

//      private static Gtk.CssProvider provider;

//      //  public Hdy.HeaderBar header_bar { get; construct; }

//      public Gee.List<Replay.Models.Game> games = new Gee.ArrayList<Replay.Models.Game> ();

//      private Gtk.Stack stack;
//      private Granite.Widgets.AlertView alert_view;
//      private Gtk.FlowBox flow_box;

//      public LibraryView (/*string placeholder_title, string placeholder_description, string placeholder_icon_name*/) {
//          Object (
//              expand: true
//              //  placeholder_title: placeholder_title,
//              //  placeholder_description: placeholder_description,
//              //  placeholder_icon_name: placeholder_icon_name
//          );
//      }

//      static construct {
//          provider = new Gtk.CssProvider ();
//          provider.load_from_resource ("com/github/avojak/replay/AlertView.css");
//      }

//      construct {
//          stack = new Gtk.Stack ();

//          alert_view = new Granite.Widgets.AlertView ("", "", "");
//          alert_view.get_style_context ().add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

//          flow_box = new Gtk.FlowBox () {
//              activate_on_single_click = false,
//              selection_mode = Gtk.SelectionMode.SINGLE,
//              homogeneous = true,
//              expand = true,
//              margin = 12,
//              valign = Gtk.Align.START
//          };
//          flow_box.child_activated.connect ((child) => {
//              var library_item = child as Replay.Widgets.LibraryItem;
//              game_selected (library_item.game);
//          });

//          var scrolled_window = new Gtk.ScrolledWindow (null, null);
//          scrolled_window.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
//          scrolled_window.add (flow_box);

//          stack.add_named (scrolled_window, "scrolled_window");
//          stack.add_named (alert_view, "alert_view");

//          attach (stack, 0, 0);

//          show_all ();

//          //  stack.set_visible_child_name ("alert_view");
//          stack.set_visible_child_name ("scrolled_window");
//      }

//      public bool add_game (Replay.Models.Game game) {
//          if (games.contains (game)) {
//              return false;
//          }
//          var game_item = new Replay.Widgets.LibraryItem.for_game (game);
//          game_item.set_played (game.is_played);
//          flow_box.add (game_item);
//          games.add (game);
//          //  refilter ();
//          return true;
//      }

//      public void remove_game (Replay.Models.Game game) {
//          // TODO: May have to store the LibraryItem models in a map that we can use for lookup
//          if (games.size == 0) {
//              //  stack.set_visible_child_name ("alert_view");
//          }
//      }

//      public void set_filter_func (FilterFunc? filter_func) {
//          if (filter_func == null) {
//              flow_box.set_filter_func (null);
//          } else {
//              //  alert_view.title = filter_func.placeholder_title;
//              //  alert_view.description = filter_func.placeholder_description;
//              //  alert_view.icon_name = filter_func.placeholder_icon_name;
//              flow_box.set_filter_func ((child) => {
//                  var library_item = child as Replay.Widgets.LibraryItem;
//                  //  debug (library_item.title);
//                  return filter_func.filter (library_item);
//              });
//          }
//      }

//      //  public void refilter () {
//      //      flow_box.invalidate_filter ();
//      //      Idle.add (() => {
//      //          var num_visible_children = get_visible_children ();
//      //          debug (num_visible_children.to_string ());
//      //          if (num_visible_children > 0) {
//      //              stack.set_visible_child_name ("scrolled_window");
//      //          } else {
//      //              stack.set_visible_child_name ("alert_view");
//      //          }
//      //          return false;
//      //      });
//      //  }

//      public int get_visible_children () {
//          int num_visible = 0;
//          foreach (var child in flow_box.get_children ()) {
//              if (child.get_mapped ()) {
//                  num_visible++;
//              }
//          }
//          return num_visible;
//      }

//      public GLib.List <Replay.Widgets.LibraryItem> get_items () {
//          return (GLib.List <Replay.Widgets.LibraryItem>) flow_box.get_children ();
//      }

//      public signal void game_selected (Replay.Models.Game game);

//  }
