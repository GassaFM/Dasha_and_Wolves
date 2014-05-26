module level;

import std.conv;
import std.stdio;
import std.string;

import allegro5.allegro;
import allegro5.allegro_font;
import allegro5.allegro_primitives;

import general;
import units.unit;
import world;

class Level
{
	World world;
	Unit [] inventory;
	Unit cursor;
	string file_name;
	string name;
	string hint;
	int score;

	World load_world (ref File f, ref char [] buf)
	{
		World res;
		f.readln (buf);
		auto t = buf.split ();
		int n = to !(int) (t[0]);
		res = new World (to !(double) (t[1]), to !(double) (t[2]));
		foreach (i; 0..n)
		{
			f.readln (buf);
			res.units ~= UnitBuilder.build (buf);
		}
		return res;
	}

	Unit [] load_inventory (ref File f, ref char [] buf)
	{
		Unit [] res;
		f.readln (buf);
		auto t = buf.split ();
		int k = to !(int) (t[0]);
		foreach (i; 0..k)
		{
			f.readln (buf);
			res ~= UnitBuilder.build (buf);
		}
		foreach (i, unit; res)
		{
			unit.number = i;
		}
		return res;
	}

	void load_level ()
	{
		auto f = File ("data/" ~ file_name, "rt");
		char [] buf;
		f.readln (buf);
		name = to !(string) (buf).strip ();
		f.readln (buf);
		hint = to !(string) (buf).strip ();
		world = load_world (f, buf);
		inventory = load_inventory (f, buf);
		cursor = null;
	}

	this (const char [] new_file_name, const int new_score)
	{
		file_name = to !(string) (new_file_name);
		score = new_score;
		load_level ();
	}

	int play ()
	{
		int res = world.play ();
		if (res == NA)
		{
			debug {stderr.writeln ("Lost");}
			load_level ();
		}
		else
		{
			debug {stderr.writeln ("Won in ", res);}
			if (score == NA || score > res)
			{
				score = res;
			}
		}
		return res;
	}

	immutable static int ISX =  75;
	immutable static int ISY = 575;
	immutable static int IDX =  50;
	immutable static int IDY =   0;
	immutable static int ILX =  40;
	immutable static int ILY =  40;

	void draw ()
	{
		world.draw ();

		al_draw_text (global_font_24,
		    color[Color.ACTIVE_TEXT],
		    50, 25 - 24 * 0.5,
		    ALLEGRO_ALIGN_LEFT, name.toStringz ());

		al_draw_text (global_font_18,
		    color[Color.INACTIVE_TEXT],
		    200, 25 - 18 * 0.5,
		    ALLEGRO_ALIGN_LEFT, hint.toStringz ());

		foreach (i, unit; inventory)
		{
			double cx = ISX + i * IDX;
			double cy = ISY + i * IDY;
			al_draw_filled_circle (cx, cy,
			    IDX * 0.5 - 1.5, color[Color.INVENTORY_SLOT]);
			if (unit !is null)
			{
				unit.draw (cx, cy);
			}
		}

		if (cursor !is null)
		{
			ALLEGRO_MOUSE_STATE st;
			al_get_mouse_state (&st);
			cursor.draw (st.x, st.y);
		}
	}

	void pick_cursor (double px, double py)
	{
		foreach (i, ref unit; inventory)
		{
			if (unit is null)
			{
				continue;
			}
			double cx = ISX + i * IDX;
			double cy = ISY + i * IDY;
			if ((cx - unit.radius <= px) &&
			    (px <= cx + unit.radius) &&
			    (cy - unit.radius <= py) &&
			    (py <= cy + unit.radius))
			{
				cursor = unit;
				unit = null;
				return;
			}
		}

		px -= world.draw_x;
		py -= world.draw_y;

		foreach (i, ref unit; world.units)
		{
			if (unit is null)
			{
				continue;
			}
			double cx = ISX + i * IDX;
			double cy = ISY + i * IDY;
			if ((unit.number != NA) &&
			    (unit.x - unit.radius <= px) &&
			    (px <= unit.x + unit.radius) &&
			    (unit.y - unit.radius <= py) &&
			    (py <= unit.y + unit.radius))
			{
				cursor = unit;
				unit.x = 0;
				unit.y = 0;
				world.units = world.units[0..i] ~
				    world.units[i + 1..$];
				return;
			}
		}
	}

	void place_cursor (double px, double py)
	{
		px -= world.draw_x;
		py -= world.draw_y;
		if ((px - cursor.radius <= 0) ||
		    (world.width <= px + cursor.radius) ||
		    (py - cursor.radius <= 0) ||
		    (world.height <= py + cursor.radius))
		{
			inventory[cursor.number] = cursor;
			cursor = null;
			return;
		}
		cursor.x = px;
		cursor.y = py;
		foreach (other; world.units)
		{
			if (other !is null)
			{
				double dist = cursor.dist_to (other);
				if (dist < cursor.radius + other.radius)
				{
					cursor.x = 0;
					cursor.y = 0;
					inventory [cursor.number] = cursor;
					cursor = null;
					return;
				}
			}
		}
		world.units ~= cursor;
		cursor = null;
	}

	void solve ()
	{
		load_level ();
		draw ();
		al_flip_display ();

		bool is_finished = false;
		while (!is_finished)
		{
			ALLEGRO_EVENT current_event;

			void process_keyboard ()
			{
				switch (current_event.keyboard.keycode)
				{
					case ALLEGRO_KEY_ESCAPE:
						is_finished = true;
						break;

					case ALLEGRO_KEY_ENTER:
						cursor = null;
						int res = play ();
						if (res != NA)
						{
							is_finished = true;
						}
						else
						{
							load_level ();
							draw ();
							al_flip_display ();
						}
						break;

					default:
						assert (true);
						break;	
				}
			}

			void process_mouse_down ()
			{
				double px = current_event.mouse.x;
				double py = current_event.mouse.y;
				if (cursor is null)
				{
					pick_cursor (px, py);
				}
			}	

			void process_mouse_up ()
			{
				double px = current_event.mouse.x;
				double py = current_event.mouse.y;
				if (cursor !is null)
				{
					place_cursor (px, py);
				}
			}	

			al_wait_for_event (event_queue, &current_event);

			switch (current_event.type)
			{
				case ALLEGRO_EVENT_TIMER:
					draw ();
					al_flip_display ();
					break;

				case ALLEGRO_EVENT_DISPLAY_CLOSE:
					is_finished = true;
					to_end = true;
					break;

				case ALLEGRO_EVENT_DISPLAY_SWITCH_IN:
					assert (true);
					break;

				case ALLEGRO_EVENT_KEY_DOWN:
					process_keyboard ();
					break;
	
				case ALLEGRO_EVENT_MOUSE_BUTTON_DOWN:
					process_mouse_down ();
					break;

				case ALLEGRO_EVENT_MOUSE_BUTTON_UP:
					process_mouse_up ();
					break;

				default:
					assert (true);
					break;
			}
		}
	}
}
