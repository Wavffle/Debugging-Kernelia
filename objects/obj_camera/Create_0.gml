var _max_h_scale = DISP_H / BASE_H
var _max_w_scale = DISP_W / BASE_W

if (frac(_max_h_scale) == 0) {
	_max_h_scale--;	
}

window_scale = floor(min(_max_h_scale, _max_w_scale));
window_set_size(BASE_W * window_scale, BASE_H * window_scale);
window_center();

surface_resize(APP_SURF, BASE_W * window_scale, BASE_H * window_scale);
display_set_gui_size(BASE_W, BASE_H)

room_goto(rm_start)

snap_to_target = function(){
	if (!instance_exists(obj_player)) return;
	
	var _tar_x = obj_player.x - VIEW_W / 2;
	var _tar_y = obj_player.y - VIEW_H / 2;
	_tar_x = clamp(_tar_x, 0, room_width - VIEW_W);
	_tar_y = clamp(_tar_y, 0, room_height - VIEW_H);
	
	camera_set_view_pos(VIEW, _tar_x, _tar_y);
}