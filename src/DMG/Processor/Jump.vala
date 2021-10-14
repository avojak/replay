//  /*
//   * Copyright (c) 2021 Andrew Vojak (https://avojak.com)
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

//  public class Replay.DMG.Processor.Jump : Replay.DMG.Processor.Operation {    

//      public Jump (string description, Replay.DMG.Processor.Operation.Lambda exec, int length, int ticks) {
//          Object (
//              description: description,
//              ticks: ticks,
//              length: length
//          );
//          this.exec = exec;
//      }

//      public new int execute (Replay.DMG.Processor.CPU cpu) {
//          int result = exec (cpu);
//          handle_flags (cpu);
//          cpu.set_pc (cpu.get_pc () + length);
//          return result;
//      }

//  }
