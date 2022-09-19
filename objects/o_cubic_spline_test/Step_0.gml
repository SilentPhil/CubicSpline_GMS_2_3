if (mouse_check_button_pressed(mb_left)) {
    array_push(points, new Point(mouse_x, mouse_y));
    recalc_spline();
}