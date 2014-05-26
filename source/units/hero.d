module units.hero;

import std.math;
import std.exception;
import std.stdio;
import std.string;

import allegro5.allegro;
import allegro5.allegro_primitives;

import general;
import units.unit;
import world;

class Hero: Unit
{
	mixin UnitBoilerplate !("data/hero.png");

	static this ()
	{
		KIND = Unit.Kind.HERO;
		RADIUS = 20.0;
		SPEED = 1.0;
		immutable double COLOR_R = 0.2;
		immutable double COLOR_G = 0.2;
		immutable double COLOR_B = 0.7;
		MAIN_COLOR = al_map_rgba_f (COLOR_R, COLOR_G, COLOR_B, 1.0);
		immutable double COLOR_MULT = 0.2;
		TINT_COLOR = al_map_rgba_f (COLOR_R * COLOR_MULT,
		    COLOR_G * COLOR_MULT, COLOR_B * COLOR_MULT, COLOR_MULT);
	}

	bool [Unit] visited;

	override double tint_radius () @property
	{
		return double.nan;
	}
	
	this (double new_x, double new_y, double new_direction)
	{
		x = new_x;
		y = new_y;
		direction = new_direction;
		visited[this] = true;
	}

	int select_target ()
	{
		double cur_dist = MUCH;
		int res = NA;
		foreach (i, unit; world.units)
		{
			if ((unit !is null) &&
			    (unit.kind & Unit.Kind.LIGHT) &&
			    (unit !in visited))
			{
				if (cur_dist > dist_to (unit))
				{
					cur_dist = dist_to (unit);
					res = i;
				}
			}
		}
		return res;
	}

	override void act ()
	{
		int target = select_target ();
		if (target != NA)
		{
			move_to (world.units[target], 1.0);
		}
	}

	override void resolve_collision (Unit other, bool is_active)
	{
		visited[other] = true;
	}
}
