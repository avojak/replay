/*
 * Copyright (c) 2021 Andrew Vojak (https://avojak.com)
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

public class Replay.CHIP8.ExampleTest : Replay.TestCase {

    public ExampleTest () {
        // assign a name for this class
        base("ExampleTest");
        // add test methods
        add_test("test_example", test_example);
    }

    public override void set_up () {
        // setup your test
    }

    public void test_example() {
        // add your expressions
        // assert(expression);
        new Replay.CHIP8.Memory.MMU ();
    }

    public override void tear_down () {
        // tear down your test
    }

}