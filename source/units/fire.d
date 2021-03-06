module units.fire;

import std.math;
import std.exception;
import std.stdio;
import std.string;

import allegro5.allegro;
import allegro5.allegro_primitives;

import general;
import units.unit;
import world;

class Fire: Unit
{
	mixin UnitBoilerplate !("data/fire.png");

	immutable static double VISION_LIGHT = 80.0;

	static this ()
	{
		KIND = Unit.Kind.LIGHT;
		RADIUS = 20.0;
		SPEED = 0.0;
		immutable double COLOR_R = 0.8;
		immutable double COLOR_G = 0.5;
		immutable double COLOR_B = 0.3;
		MAIN_COLOR = al_map_rgba_f (COLOR_R, COLOR_G, COLOR_B, 1.0);
		immutable double COLOR_MULT = 0.3;
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
		assert (true);
	}
}
