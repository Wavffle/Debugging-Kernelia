if (!instance_exists(obj_player)) exit;

var _tar_x = obj_player.x - VIEW_W / 2;
var _tar_y = obj_player.y - VIEW_H / 2;

_tar_x = lerp(VIEW_X, _tar_x, .2);
_tar_y = lerp(VIEW_Y, _tar_y, .2);

_tar_x = clamp(_tar_x, 0, room_width-VIEW_W)
_tar_y = clamp(_tar_y, 0, room_height-VIEW_H)

camera_set_view_pos(VIEW, _tar_x, _tar_y);