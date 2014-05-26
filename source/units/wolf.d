module units.wolf;

import std.math;
import std.exception;
import std.stdio;
import std.string;

import allegro5.allegro;
import allegro5.allegro_primitives;

import general;
import units.unit;
import world;

class Wolf: Unit
{
	mixin UnitBoilerplate !("data/wolf.png");

	immutable static double VISION_LIGHT = 80.0;
	immutable static double VISION_HERO = 100.0;

	static this ()
	{
		KIND = 0;
		RADIUS = 20.0;
		SPEED = 1.5;
		immutable double COLOR_R = 0.3;
		immutable double COLOR_G = 0.2;
		immutable double COLOR_B = 0.2;
		MAIN_COLOR = al_map_rgba_f (COLOR_R, COLOR_G, COLOR_B, 1.0);
		immutable double COLOR_MULT = 0.2;
		TINT_COLOR = al_map_rgba_f (COLOR_R * COLOR_MULT,
		    COLOR_G * COLOR_MULT, COLOR_B * COLOR_MULT, COLOR_MULT);
	}

	this (double new_x, double new_y, double new_direction)
	{
		x = new_x;
		y = new_y;
		direction = new_direction;
	}

	override double tint_radius () @property
	{
		return VISION_HERO + RADIUS;
	}

	double vision_light () @property
	{
		return VISION_LIGHT;
	}

	double vision_hero () @property
	{
		return VISION_HERO;
	}

	int select_target ()
	{
		double cur_dist = MUCH;
		int res = NA;
		foreach (i, unit; world.units)
		{
			if ((unit !is null) &&
			    (unit.kind & Unit.Kind.LIGHT) &&
			    (dist_to (unit) < vision_light +
			     radius + unit.radius))
			{
				if (cur_dist > dist_to (unit))
				{
					cur_dist = dist_to (unit);
					res = i;
				}
			}
		}
		if (res != NA)
		{
			return res;
		}
		foreach (i, unit; world.units)
		{
			if ((unit !is null) &&
			    (unit.kind & Unit.Kind.HERO) &&
			    (dist_to (unit) < vision_hero +
			     radius + unit.radius))
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
			double mult;
			if (world.units[target].kind & Unit.Kind.HERO)
			{
				mult = 1.0;
			}
			else
			{
				mult = -0.5;
			}
			move_to (world.units[target], mult);
		}
	}

	override void resolve_collision (Unit other, bool is_active)
	{
		if (other.kind & Unit.Kind.HERO)
		{
			world.is_lost = true;
			world.is_finished = true;
		}
	}
}
