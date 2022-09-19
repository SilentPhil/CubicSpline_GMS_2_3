show_debug_overlay(true);

spline = new CubicSpline();     /// @is {CubicSpline}
points = [];                    /// @is {Point[]}

function recalc_spline() {
	if (array_length(points) > 2) {
    	spline.set_points(points);
        spline.refresh();
	}
}