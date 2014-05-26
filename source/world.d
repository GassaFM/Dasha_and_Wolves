module world;

import allegro5.allegro;
import allegro5.allegro_primitives;

import std.conv;
import std.random;
import std.stdio;

import general;
import units.unit;

class World
{
	immutable static double draw_x = 50;
	immutable static double draw_y = 50;

	Unit [] units;
	Random random;
	double width;
	double height;
	int ticks;
	bool is_won;
	bool is_lost;
	bool is_finished;

	this (double new_width, double new_height)
	{
		width = new_width;
		height = new_height;
	}

	void register_units ()
	{
		foreach (i, unit; units)
		{
			if (unit !is null)
			{
				unit.world = this;
				unit.number = i;
			}
		}
	}

	void step ()
	{
		foreach (unit; units)
		{
			if (unit !is null)
			{
				unit.act ();
				foreach (unit2; units)
				{
					if (unit2 !is null &&
					    unit2 !is unit)
					{
						unit.collide (unit2);
					}
				}
			}
		}
	}

	void draw ()
	{
		al_clear_to_color (color[Color.BACKGROUND]);

		al_draw_filled_rectangle (draw_x, draw_y,
		    draw_x + width, draw_y + height, color[Color.WORLD]);

		al_set_clipping_rectangle (to !(int) (draw_x),
		    to !(int) (draw_y), to !(int) (width), to !(int) (height));
		foreach (unit; units)
		{
			if (unit !is null)
			{
				unit.pre_draw (draw_x, draw_y);
			}
		}
		al_set_clipping_rectangle (0, 0, MAX_X, MAX_Y);

		foreach (unit; units)
		{
			if (unit !is null)
			{
				unit.draw (draw_x, draw_y);
			}
		}
	}

	void main_loop ()
	{
		ticks = 0;
		draw ();
		al_flip_display ();

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

					default:
						assert (true);
						break;	
				}
			}

			void process_mouse ()
			{
			}	

			al_wait_for_event (event_queue, &current_event);

			switch (current_event.type)
			{
				case ALLEGRO_EVENT_TIMER:
					step ();
					ticks++;
					draw ();
					al_flip_display ();
					break;

				case ALLEGRO_EVENT_DISPLAY_CLOSE:
					to_end = true;
					is_finished = true;
					break;

				case ALLEGRO_EVENT_DISPLAY_SWITCH_IN:
					draw ();
					break;

				case ALLEGRO_EVENT_KEY_DOWN:
					process_keyboard ();
					break;

				case ALLEGRO_EVENT_MOUSE_BUTTON_DOWN:
					process_mouse ();
					break;

				default:
					assert (true);
					break;
			}
		}
	}

	int play ()
	{
		random = Random (12345);
		register_units ();
		is_won = false;
		is_lost = false;
		is_finished = false;
		main_loop ();
		if (is_won)
		{
			return ticks;
		}
		else
		{
			return NA;
		}
	}
}
