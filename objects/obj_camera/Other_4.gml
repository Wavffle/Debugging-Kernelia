view_enabled = true;
view_visible[0] = true;
camera_set_view_size(VIEW, BASE_W, BASE_H);
camera_set_view_target(VIEW, noone);
snap_to_target();

view_set_wport(0, APP_W);
view_set_hport(0, APP_H);
view_set_xport(0, 0);
view_set_yport(0, 0);