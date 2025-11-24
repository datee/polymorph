package polymorph;

import polymorph.Types;
import polymorph.Path;
import polymorph.PathNormalizer;
import polymorph.PathRenderer;
import polymorph.Constants;
import polymorph.MathUtils.*;

/**
 * Main class for path interpolation
 */
class Polymorph {
    /**
     * Mixes two point arrays based on offset (0 to 1)
     */
    private static function mixPoints(a:FloatArray, b:FloatArray, o:Float):FloatArray {
        var alen = a.length;
        var results:FloatArray = [];
        for (i in 0...alen) {
            results.push(a[i] + (b[i] - a[i]) * o);
        }
        return results;
    }

    /**
     * Creates an interpolator function for two paths
     */
    private static function getPathInterpolator(left:Path, right:Path, options:InterpolateOptions):(Float) -> Dynamic {
        var matrix = PathNormalizer.normalizePaths(left.getData(), right.getData(), options);
        var n = matrix.left.length;

        return function(offset:Float):Dynamic {
            if (abs(offset - 0) < Constants.EPSILON) {
                return left.getStringData();
            }
            if (abs(offset - 1) < Constants.EPSILON) {
                return right.getStringData();
            }

            var results:Array<FloatArray> = [];
            for (h in 0...n) {
                results.push(mixPoints(matrix.left[h], matrix.right[h], offset));
            }
            return results;
        };
    }

    /**
     * Creates an interpolator function for multiple paths
     * @param paths Array of SVG path strings
     * @param options Interpolation options
     * @return Function that takes an offset (0 to 1) and returns an SVG path string
     */
    public static function interpolate(paths:Array<String>, ?options:InterpolateOptions):(Float) -> String {
        if (paths == null || paths.length < 2) {
            throw "Invalid arguments: at least 2 paths required";
        }

        // set default options
        if (options == null) {
            options = {};
        }
        if (options.addPoints == null) {
            options.addPoints = 0;
        }
        if (options.optimize == null) {
            options.optimize = Constants.FILL;
        }
        if (options.origin == null) {
            options.origin = {x: 0.0, y: 0.0, absolute: false};
        }
        if (options.precision == null) {
            options.precision = 0;
        }

        // convert strings to Path objects
        var pathObjects = paths.map(function(pathString) {
            return new Path(pathString);
        });

        var hlen = pathObjects.length - 1;
        var items:Array<(Float) -> Dynamic> = [];

        for (h in 0...hlen) {
            items.push(getPathInterpolator(pathObjects[h], pathObjects[h + 1], options));
        }

        var precision = options.precision;

        return function(offset:Float):String {
            var d = hlen * offset;
            var flr = Std.int(min(floor(d), hlen - 1));
            var result = items[flr]((d - flr) / (flr + 1));

            if (Std.isOfType(result, String)) {
                return cast result;
            } else {
                return PathRenderer.render(cast result, precision);
            }
        };
    }

    /**
     * Simple interpolation between two paths
     * @param fromPath Starting path string
     * @param toPath Ending path string
     * @param options Interpolation options
     * @return Function that takes an offset (0 to 1) and returns an SVG path string
     */
    public static function interpolateTwo(fromPath:String, toPath:String, ?options:InterpolateOptions):(Float) -> String {
        return interpolate([fromPath, toPath], options);
    }
}
