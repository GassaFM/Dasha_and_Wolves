module main;

pragma (lib, "dallegro5");
pragma (lib, "allegro");
pragma (lib, "allegro_font");
pragma (lib, "allegro_image");
pragma (lib, "allegro_primitives");
pragma (lib, "allegro_ttf");

import std.c.stdlib;
import std.conv;
import std.exception;
import std.stdio;
import std.string;

import allegro5.allegro;
import allegro5.allegro_font;
import allegro5.allegro_image;
import allegro5.allegro_primitives;
import allegro5.allegro_ttf;

import general;
import level;
import units.hero;
import units.unit;
import units.wolf;

immutable string FONT_FILE_NAME = "data/Inconsolata.otf";

void do_nothing ()
{
// do nothing
}

void init (string [] args)
{
	enforce (al_init ());
	enforce (al_init_primitives_addon ());
	enforce (al_install_keyboard ());
	enforce (al_install_mouse ());
	al_init_font_addon ();
	enforce (al_init_ttf_addon ());
	enforce (al_init_image_addon ());

	global_timer = al_create_timer (1.0 / FPS);
	enforce (global_timer);
	al_start_timer (global_timer);

	al_set_new_display_option
	    (ALLEGRO_DISPLAY_OPTIONS.ALLEGRO_AUX_BUFFERS,
	    2, ALLEGRO_SUGGEST);
	al_set_new_display_option
	    (ALLEGRO_DISPLAY_OPTIONS.ALLEGRO_SINGLE_BUFFER,
	    0, ALLEGRO_SUGGEST);
	display = al_create_display (MAX_X, MAX_Y);
	enforce (display);

	event_queue = al_create_event_queue ();
	enforce (event_queue);

	al_register_event_source (event_queue,
	                          al_get_keyboard_event_source ());
	al_register_event_source (event_queue,
	                          al_get_mouse_event_source ());
	al_register_event_source (event_queue,
	                          al_get_display_event_source (display));
	al_register_event_source (event_queue,
	                          al_get_timer_event_source (global_timer));

	global_font_18 = al_load_ttf_font (FONT_FILE_NAME.toStringz (), 18, 0);
	enforce (global_font_18);
	global_font_24 = al_load_ttf_font (FONT_FILE_NAME.toStringz (), 24, 0);
	enforce (global_font_24);
	global_font_36 = al_load_ttf_font (FONT_FILE_NAME.toStringz (), 36, 0);
	enforce (global_font_36);
}

void happy_end ()
{
	al_destroy_display (display);
	al_destroy_event_queue (event_queue);
	al_destroy_font (global_font_18);
	al_destroy_font (global_font_24);
	al_destroy_font (global_font_36);

	al_shutdown_primitives_addon ();
	al_shutdown_font_addon ();
	al_shutdown_ttf_addon ();
	al_shutdown_image_addon ();

	exit (EXIT_SUCCESS);
}

immutable int LSX = 250;
immutable int LSY = 100;
immutable int LDX =   0;
immutable int LDY =  40;
immutable int LLX = 190;
immutable int LLY =  33;
immutable int EDX = 210;
immutable int EDY =   0;
immutable int ELX =  90;
immutable int ELY =  33;

Unit [] menu_units;
Level [] levels;
int levels_completed;
// EASTER EGG: click on the units at the title screen at least 7 times
int unit_clicks;

void draw_menu ()
{
	al_clear_to_color (color[Color.BACKGROUND]);

	al_draw_text (global_font_36, color[Color.ACTIVE_TEXT],
	    MAX_X * 0.5, 40 - 36 * 0.5,
	    ALLEGRO_ALIGN_CENTRE, "Dasha and Wolves".toStringz ());
	menu_units[0].draw (0, 0);
	menu_units[1].draw (0, 0);
	al_draw_text (global_font_24, color[Color.INACTIVE_TEXT],
	    LSX + LLX * 0.5, 80 - 24 * 0.5,
	    ALLEGRO_ALIGN_CENTRE, "Level".toStringz ());
	al_draw_text (global_font_24, color[Color.INACTIVE_TEXT],
	    LSX + EDX + ELX * 0.5, 80 - 24 * 0.5,
	    ALLEGRO_ALIGN_CENTRE, "Best Time".toStringz ());

	foreach (i, level; levels)
	{
		int cx = LSX + i * LDX;
		int cy = LSY + i * LDY;
		if (i <= levels_completed)
		{
			al_draw_filled_rectangle (cx, cy, cx + LLX, cy + LLY,
			    color[Color.ACTIVE_BUTTON]);
			al_draw_text (global_font_24, color[Color.ACTIVE_TEXT],
			    cx + LLX * 0.5, cy + (LLY - 24) * 0.5,
			    ALLEGRO_ALIGN_CENTRE, level.name.toStringz ());
		}
		else
		{
			al_draw_filled_rectangle (cx, cy, cx + LLX, cy + LLY,
			    color[Color.INACTIVE_BUTTON]);
			al_draw_text (global_font_24,
			    color[Color.INACTIVE_TEXT],
			    cx + LLX * 0.5, cy + (LLY - 24) * 0.5,
			    ALLEGRO_ALIGN_CENTRE, level.name.toStringz ());
		}
		if (level.score != NA)
		{
			al_draw_filled_rectangle (cx + EDX, cy + EDY,
			    cx + EDX + ELX, cy + EDY + ELY,
			    color[Color.ACTIVE_BUTTON]);
			al_draw_textf (global_font_24, color[Color.SCORE_TEXT],
			    cx + EDX + ELX * 0.5, cy + EDY + (ELY - 24) * 0.5,
			    ALLEGRO_ALIGN_CENTRE, "%.2f".toStringz (),
			    level.score * 1.0 / FPS);
		}
	}
}

void main_menu ()
{
	draw_menu ();
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

				default:
					assert (true);
					break;	
			}
		}

		void process_mouse ()
		{
			int px = current_event.mouse.x;
			int py = current_event.mouse.y;
			foreach (i, level; levels)
			{
				int cx = LSX + i * LDX;
				int cy = LSY + i * LDY;
				if (cx <= px && px <= cx + LLX &&
				    cy <= py && py <= cy + LLY &&
				    i <= levels_completed)
				{
					level.solve ();
					if (level.score != NA &&
					    levels_completed == i)
					{
						levels_completed++;
					}
					save_score ();
					return;
				}
			}

			foreach (i, ref unit; menu_units)
			{
				if (unit is null)
				{
					continue;
				}
				if ((unit.x - unit.radius <= px) &&
				    (px <= unit.x + unit.radius) &&
				    (unit.y - unit.radius <= py) &&
				    (py <= unit.y + unit.radius))
				{
					unit_clicks++;
					if (unit_clicks >= 7)
					{
						levels_completed =
						    levels.length;
					}
				}
			}
		}	

		al_wait_for_event (event_queue, &current_event);

		switch (current_event.type)
		{
			case ALLEGRO_EVENT_TIMER:
				draw_menu ();
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

			case ALLEGRO_EVENT_MOUSE_BUTTON_UP:
				process_mouse ();
				break;

			default:
				assert (true);
				break;
		}
	}
}

void prepare_levels ()
{
	levels = new Level [0];
	auto f = File ("data/list.txt", "rt");
	levels_completed = 0;
	int i = 0;
	foreach (s; f.byLine ())
	{
		auto t = s.split ();
		auto cur = new Level (t[0], to !(int) (t[1]));
		levels ~= cur;
		if (levels_completed == i && cur.score != NA)
		{
			levels_completed++;
		}
		i++;
	}

	menu_units = new Unit [0];
	menu_units ~= UnitBuilder.build ("Hero 200 35 0");
	menu_units ~= UnitBuilder.build ("Wolf 600 35 0");
	menu_units[0].number = 0;
	menu_units[1].number = 1;
	unit_clicks = 0;
}

void save_score ()
{
	auto f = File ("data/list.txt", "wt");
	foreach (level; levels)
	{
		f.writeln (level.file_name, ' ', level.score);
	}
}

int main (string [] args)
{
	return al_run_allegro (
	{
		init (args);
		init_colors ();
		prepare_levels ();
		main_menu ();
		happy_end ();
		return 0;
	});
}
