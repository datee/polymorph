package polymorph;

/**
 * A matrix holding two sets of path data for interpolation
 */
typedef Matrix = {
    var left:Array<FloatArray>;
    var right:Array<FloatArray>;
}

/**
 * Float array type - using Array<Float> in Haxe
 */
typedef FloatArray = Array<Float>;

/**
 * Origin point for path normalization
 */
typedef Origin = {
    /**
     * The x position
     */
    var x:Float;

    /**
     * The y position
     */
    var y:Float;

    /**
     * If true, x and y are absolute coordinates in the SVG.
     * If false, x and y are a number between 0 and 1 representing 0% to 100% of the matched subpath
     */
    var ?absolute:Bool;
}

/**
 * Options for path interpolation
 */
typedef InterpolateOptions = {
    /**
     * Origin of the shape
     */
    var ?origin:Origin;

    /**
     * Determines the strategy to optimize two paths for each other.
     *
     * - none: use when both shapes have an equal number of subpaths and points
     * - fill: (default) creates subpaths and adds points to align both paths
     */
    var ?optimize:String; // 'none' or 'fill'

    /**
     * Number of points to add when using optimize: fill. The default is 0.
     */
    var ?addPoints:Int;

    /**
     * Number of decimal places to use when rendering 'd' strings.
     * For most animations, 0 is recommended. If very small shapes are being used, this can be increased to
     * improve smoothness at the cost of rendering speed.
     * The default is 0 (no decimal places) and also the recommended value.
     */
    var ?precision:Int;
}

/**
 * Parse context for tracking parser state
 */
typedef ParseContext = {
    /**
     * Cursor X position
     */
    var x:Float;

    /**
     * Cursor Y position
     */
    var y:Float;

    /**
     * Last Control X
     */
    var ?cx:Float;

    /**
     * Last Control Y
     */
    var ?cy:Float;

    /**
     * Last command that was seen
     */
    var ?lc:String;

    /**
     * Current command being parsed
     */
    var ?c:String;

    /**
     * Terms being parsed
     */
    var ?t:Array<Float>;

    /**
     * All segments
     */
    var segments:Array<FloatArray>;

    /**
     * Current poly-bezier (the one being built)
     */
    var ?current:FloatArray;
}
