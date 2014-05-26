module general;

import allegro5.allegro;
import allegro5.allegro_font;

immutable int    MAX_X  =   800;
immutable int    MAX_Y  =   600;
immutable int    NA     =    -1;
immutable double FPS    =    60;
immutable double MUCH   = 1E+10;
immutable double LITTLE = 5E-02;

ALLEGRO_DISPLAY * display;
ALLEGRO_EVENT_QUEUE * event_queue;
ALLEGRO_FONT * global_font_18;
ALLEGRO_FONT * global_font_24;
ALLEGRO_FONT * global_font_36;
ALLEGRO_TIMER * global_timer;

bool to_end;

ALLEGRO_COLOR [] color;

enum Color: int {BACKGROUND, WORLD, ACTIVE_BUTTON, INACTIVE_BUTTON,
    ACTIVE_TEXT, INACTIVE_TEXT, SCORE_TEXT, INVENTORY_SLOT, IMMOBILE_UNIT};

void init_colors ()
{
	color = new ALLEGRO_COLOR [0];
	color ~= al_map_rgb_f (0.1, 0.2, 0.3); // background
	color ~= al_map_rgb_f (0.3, 0.6, 0.2); // world
	color ~= al_map_rgb_f (0.3, 0.3, 0.6); // active button
	color ~= al_map_rgb_f (0.2, 0.2, 0.4); // inactive button
	color ~= al_map_rgb_f (0.9, 0.9, 0.7); // active text
	color ~= al_map_rgb_f (0.7, 0.7, 0.3); // inactive text
	color ~= al_map_rgb_f (0.7, 0.9, 0.7); // score text
	color ~= al_map_rgb_f (0.5, 0.5, 0.5); // inventory slot
	color ~= al_map_rgb_f (0.9, 0.9, 0.9); // immobile unit
}
