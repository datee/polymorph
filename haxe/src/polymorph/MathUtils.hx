package polymorph;

/**
 * Math utility functions
 */
class MathUtils {
    public static inline function abs(v:Float):Float {
        return Math.abs(v);
    }

    public static inline function min(a:Float, b:Float):Float {
        return Math.min(a, b);
    }

    public static inline function max(a:Float, b:Float):Float {
        return Math.max(a, b);
    }

    public static inline function floor(v:Float):Int {
        return Math.floor(v);
    }

    public static inline function round(v:Float):Float {
        return Math.round(v);
    }

    public static inline function sqrt(v:Float):Float {
        return Math.sqrt(v);
    }

    public static inline function pow(base:Float, exp:Float):Float {
        return Math.pow(base, exp);
    }

    public static inline function cos(v:Float):Float {
        return Math.cos(v);
    }

    public static inline function sin(v:Float):Float {
        return Math.sin(v);
    }

    public static inline function tan(v:Float):Float {
        return Math.tan(v);
    }

    public static inline function asin(v:Float):Float {
        return Math.asin(v);
    }

    public static inline function distance(x1:Float, y1:Float, x2:Float, y2:Float):Float {
        return sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
    }

    public static inline function coalesce(current:Null<Float>, fallback:Float):Float {
        return current != null ? current : fallback;
    }
}
