module units.unit;

import std.conv;
import std.exception;
import std.math;
import std.random;
import std.stdio;
import std.string;

import allegro5.allegro;
import allegro5.allegro_primitives;

import general;
import units.fire;
import units.hero;
import units.town;
import units.wolf;
import world;

abstract class Unit
{
	enum Kind: int {HERO = 1, LIGHT = 2};

	World world;
	int number = NA;
	double x;
	double y;
	double direction;

	static void load_picture ();
	double tint_radius () @property;
	double radius () @property;
	double speed () @property;
	int kind () @property;
	ALLEGRO_COLOR main_color () @property;
	ALLEGRO_COLOR tint_color () @property;
	void pre_draw (const double draw_x, const double draw_y);
	void draw (const double draw_x, const double draw_y);
	void act ();
	void resolve_collision (Unit other, bool is_active);

	void collide (Unit other)
	{
		double dist = dist_to (other);
		if (dist < radius + other.radius)
		{
			double alpha = angle_to (other);
			x = other.x - (radius + other.radius + LITTLE) *
			    cos (alpha);
			y = other.y - (radius + other.radius + LITTLE) *
			    sin (alpha);
			x += uniform (-0.7, +0.7, world.random) * LITTLE;
			y += uniform (-0.7, +0.7, world.random) * LITTLE;
			this.resolve_collision (other, true);
			other.resolve_collision (this, false);
		}
	}

	double angle_to (Unit other)
	{
		return atan2 (other.y - y, other.x - x);
	}

	double dist_to (Unit other)
	{
		return hypot (other.y - y, other.x - x);
	}
	
	void move_to (Unit other, double mult)
	{
		double alpha = angle_to (other);
		x += speed * mult * cos (alpha);
		y += speed * mult * sin (alpha);
		direction = alpha;
	}
}

mixin template UnitBoilerplate (string file_name)
{
	static double RADIUS;
	static double SPEED;
	static int KIND;
	static ALLEGRO_COLOR MAIN_COLOR;
	static ALLEGRO_COLOR TINT_COLOR;
	static ALLEGRO_BITMAP * [2] picture;

	static ~this ()
	{
		foreach (ref cur; picture)
		{
			if (cur !is null)
			{
				al_destroy_bitmap (cur);
			}
		}
	}

	static void load_picture ()
	{
		if (picture[0] !is null)
		{
			return;
		}
		picture[0] = al_load_bitmap (file_name.toStringz ());
		if (picture[0] is null)
		{
			return;
		}
		int w = al_get_bitmap_width (picture[0]);
		int h = al_get_bitmap_height (picture[0]);
		enforce (w == RADIUS * 2 && h == RADIUS * 2);
		picture[1] = al_create_bitmap (w, h);
		al_set_target_bitmap (picture[1]);
		al_draw_tinted_bitmap (picture[0],
		    al_map_rgba_f (0.5, 0.5, 0.5, 1.0), 0, 0, 0);
		al_set_target_bitmap (al_get_backbuffer (display));
	}

	override double radius () @property
	{
		return RADIUS;
	}
	
	override double speed () @property
	{
		return SPEED;
	}

	override int kind () @property
	{
		return KIND;
	}

	override ALLEGRO_COLOR main_color () @property
	{
		return MAIN_COLOR;
	}

	override ALLEGRO_COLOR tint_color () @property
	{
		return TINT_COLOR;
	}

	override void pre_draw (const double draw_x, const double draw_y)
	{
		if (tint_radius > 0)
		{
			al_draw_filled_circle (draw_x + x,
			    draw_y + y, tint_radius, tint_color);
		}
	}

	override void draw (const double draw_x, const double draw_y)
	{
		if (number == NA)
		{
			al_draw_filled_circle (draw_x + x, draw_y + y,
			    radius + 3, color[Color.IMMOBILE_UNIT]);
		}

		if (picture[0] !is null)
		{
			al_draw_bitmap (picture[0], draw_x + x - radius,
			    draw_y + y - radius, 0);
		}
		else
		{
			al_draw_filled_circle (draw_x + x,
			    draw_y + y, radius, main_color);
		}
	}
}

static class UnitBuilder
{
	static Unit build (const char [] data)
	{
		auto t = data.split ();
		double x;
		double y;
		double direction;
		if (t.length == 1)
		{
			x = 0;
			y = 0;
			direction = 0;
		}
		else if (t.length == 4)
		{
			x = to !(double) (t[1]);
			y = to !(double) (t[2]);
			direction = to !(double) (t[3]);
		}
		else
		{
			enforce (false);
		}
		if (t[0] == "Fire")
		{
			Fire.load_picture ();
			return new Fire (x, y, direction);
		}
		else if (t[0] == "Hero")
		{
			Hero.load_picture ();
			return new Hero (x, y, direction);
		}
		else if (t[0] == "Town")
		{
			Town.load_picture ();
			return new Town (x, y, direction);
		}
		else if (t[0] == "Wolf")
		{
			Wolf.load_picture ();
			return new Wolf (x, y, direction);
		}
		else
		{
			assert (false);
		}
	}
}
