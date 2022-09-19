draw_text(10, 10, "Cubic spline");

if (array_length(points) > 2) {
    var inc_value = 0.05 / array_length(points);
    
    for (var f = 0; f <= 1; f += inc_value) {
        var point = spline.get_point(f);
        
        draw_circle(point.x, point.y, 3, false);
    }
}

for (var i = 0, size_i = array_length(points); i < size_i; i++) {
    draw_circle_color(points[i].x, points[i].y, 4, c_red, c_red, false);
}