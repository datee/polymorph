package polymorph;

/**
 * Constants used throughout the library
 */
class Constants {
    public static inline var SPACE:String = " ";
    public static inline var FILL:String = "fill";
    public static inline var NONE:String = "none";

    // SVG Path Commands
    public static inline var DRAW_LINE_VERTICAL:String = "V";
    public static inline var DRAW_LINE_HORIZONTAL:String = "H";
    public static inline var DRAW_LINE:String = "L";
    public static inline var CLOSE_PATH:String = "Z";
    public static inline var MOVE_CURSOR:String = "M";
    public static inline var DRAW_CURVE_CUBIC_BEZIER:String = "C";
    public static inline var DRAW_CURVE_SMOOTH:String = "S";
    public static inline var DRAW_CURVE_QUADRATIC:String = "Q";
    public static inline var DRAW_CURVE_QUADRATIC_CONTINUATION:String = "T";
    public static inline var DRAW_ARC:String = "A";

    // Math constants
    public static inline var PI:Float = Math.PI;
    public static inline var QUADRATIC_RATIO:Float = 2.0 / 3.0;
    public static inline var EPSILON:Float = 2.220446049250313e-16; // Math.pow(2, -52)
}
