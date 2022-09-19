// Based on https://github.com/CrushedPixel/CubicSplineDemo

function Cubic(_p0/*:number*/, _d2/*:number*/, _e/*:number*/, _f/*:number*/) constructor {
    d = _p0;
    c = _d2;
    b = _e;
    a = _f;

	static eval = function(_u/*:number*/)/*->number*/ {
		//equals a*x^3 + b*x^2 + c*x + d
		return (((a * _u) + b) * _u + c) * _u + d;
	}
}

function CubicSpline() constructor {
    __points        = [];    /// @is {Point[]}
    __x_cubics      = [];    /// @is {Cubic[]}
    __y_cubics      = [];    /// @is {Cubic[]}
    
    enum POS_FIELD {
		X,
		Y
	}
	    
    static add_point = function(_point/*:Point*/)/*->void*/ {
        array_push(__points, _point);
    }
    
    static set_points = function(_points/*:Point[]*/)/*->void*/ {
    	__points = _points;
    }
    
    static update_spline = function()/*->void*/ {
		__x_cubics = __calc_natural_cubic(__extract_values(POS_FIELD.X));
		__y_cubics = __calc_natural_cubic(__extract_values(POS_FIELD.Y));
	}
	
    static __extract_values = function(_field/*:int<POS_FIELD>*/)/*->number[]*/ {
        var ints/*:number[]*/ = [];
        for (var i = 0, size_i = array_length(__points); i < size_i; i++) {
            switch (_field) {
                case POS_FIELD.X:
                    array_push(ints, __points[i].x);
                break;
                
                case POS_FIELD.Y:
                    array_push(ints, __points[i].y);
                break;
            }
        }
        
        return ints;
    }
    
	static __calc_natural_cubic = function(_values/*:number[]*/)/*->Cubic[]*/ {
		var num 	= array_length(_values) - 1;

        var gamma	= array_create(num + 1);
        var delta	= array_create(num + 1);
        var D		= array_create(num + 1);
        
		/*
              We solve the equation
	          [2 1       ] [D[0]]   [3(x[1] - x[0])  ]
	          |1 4 1     | |D[1]|   |3(x[2] - x[0])  |
	          |  1 4 1   | | .  | = |      .         |
	          |    ..... | | .  |   |      .         |
	          |     1 4 1| | .  |   |3(x[n] - x[n-2])|
	          [       1 2] [D[n]]   [3(x[n] - x[n-1])]
	          by using row operations to convert the matrix to upper triangular
	          and then back substitution.  The D[i] are the derivatives at the knots.
		 */
		 
		gamma[0] = 1.0 / 2.0;
		for(var i = 1; i < num; i++) {
			gamma[i] = 1.0 / (4.0 - gamma[i - 1]);
		}
		gamma[num] = 1.0 / (2.0 - gamma[num - 1]);

		var p0 = _values[0];
		var p1 = _values[1];

		delta[0] = 3.0 * (p1 - p0) * gamma[0];
		for (var i = 1; i < num; i++) {
			p0 = _values[i - 1];
			p1 = _values[i + 1];
			delta[i] = (3.0 * (p1 - p0) - delta[i - 1]) * gamma[i];
		}

		p0 = _values[num - 1];
		p1 = _values[num];

		delta[num] = (3.0 * (p1 - p0) - delta[num - 1]) * gamma[num];

		D[num] = delta[num];
		for(var i = num - 1; i >= 0; i--) {
			D[i] = delta[i] - gamma[i] * D[i + 1];
		}

		//now compute the coefficients of the cubics
		var _cubics = [];

		for (var i = 0; i < num; i++) {
			p0 = _values[i];
			p1 = _values[i + 1];
			array_push(_cubics, new Cubic(
				p0,
				D[i],
				3 * (p1 - p0) - 2 * D[i] - D[i + 1],
				2 * (p0 - p1) + D[i] + D[i + 1]
				));
		}
		return _cubics;
	}
	
	#region getters
	/// @arg {number} position - float from 0.0 to 1.0
    static get_point = function(_position/*:number*/)/*->Point*/ {
        var f_position  = _position * array_length(__x_cubics);
        var cubic_num   = floor(min(array_length(__x_cubics) - 1, f_position));
        var cubic_pos   = (f_position - cubic_num);

        return new Point(__x_cubics[cubic_num].eval(cubic_pos), __y_cubics[cubic_num].eval(cubic_pos));
    }
    #endregion
}


function Point(_x/*:number*/, _y/*:number*/) constructor {
    x = _x;
    y = _y;
}