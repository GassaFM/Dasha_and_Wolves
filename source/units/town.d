module units.town;

import std.math;
import std.exception;
import std.stdio;
import std.string;

import allegro5.allegro;
import allegro5.allegro_primitives;

import general;
import units.unit;
import world;

class Town: Unit
{
	mixin UnitBoilerplate !("data/town.png");

	immutable static double VISION_LIGHT = 80.0;

	static this ()
	{
		KIND = Unit.Kind.LIGHT;
		RADIUS = 40.0;
		SPEED = 0.0;
		immutable double COLOR_R = 0.6;
		immutable double COLOR_G = 0.6;
		immutable double COLOR_B = 0.7;
		MAIN_COLOR = al_map_rgba_f (COLOR_R, COLOR_G, COLOR_B, 1.0);
		immutable double COLOR_MULT = 0.4;
		TINT_COLOR = al_map_rgba_f (COLOR_R * COLOR_MULT,
		    COLOR_G * COLOR_MULT, COLOR_B * COLOR_MULT, COLOR_MULT);
	}

	override double tint_radius () @property
	{
		return VISION_LIGHT + RADIUS;
	}

	this (double new_x, double new_y, double new_direction)
	{
		x = new_x;
		y = new_y;
		direction = new_direction;
	}

	override void act ()
	{
		assert (true);
	}

	override void resolve_collision (Unit other, bool is_active)
	{
		if (other.kind & Unit.Kind.HERO)
		{
			world.is_won = true;
			world.is_finished = true;
		}
	}
}
