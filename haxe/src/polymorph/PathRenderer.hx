package polymorph;

import polymorph.Types;
import polymorph.Constants;
import polymorph.MathUtils.*;

/**
 * Renders internal poly-bezier format back to SVG path string
 */
class PathRenderer {
    /**
     * Formats a number based on precision
     */
    private static function formatNumber(n:Float, precision:Int):String {
        if (precision == 0) {
            return Std.string(round(n));
        }
        var multiplier = Math.pow(10, precision);
        return Std.string(Math.round(n * multiplier) / multiplier);
    }

    /**
     * Renders poly-bezier data to SVG path string
     */
    public static function render(pathData:Array<FloatArray>, precision:Int = 0):String {
        var result:Array<String> = [];

        for (i in 0...pathData.length) {
            var n = pathData[i];
            result.push(Constants.MOVE_CURSOR);
            result.push(formatNumber(n[0], precision));
            result.push(formatNumber(n[1], precision));
            result.push(Constants.DRAW_CURVE_CUBIC_BEZIER);

            var lastResult:String = null;
            var f = 2;
            while (f < n.length) {
                var p0 = formatNumber(n[f], precision);
                var p1 = formatNumber(n[f + 1], precision);
                var p2 = formatNumber(n[f + 2], precision);
                var p3 = formatNumber(n[f + 3], precision);
                var dx = formatNumber(n[f + 4], precision);
                var dy = formatNumber(n[f + 5], precision);

                // check if this is a degenerate point (all control points equal destination)
                var isPoint = p0 == dx && p2 == dx && p1 == dy && p3 == dy;

                // prevent duplicate points from rendering
                var currentResult = p0 + p1 + p2 + p3 + dx + dy;
                if (!isPoint || lastResult != currentResult) {
                    result.push(p0);
                    result.push(p1);
                    result.push(p2);
                    result.push(p3);
                    result.push(dx);
                    result.push(dy);
                    lastResult = currentResult;
                }

                f += 6;
            }
        }

        return result.join(Constants.SPACE);
    }
}
