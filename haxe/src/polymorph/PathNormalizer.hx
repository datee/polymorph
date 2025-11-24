package polymorph;

import polymorph.Types;
import polymorph.Constants;
import polymorph.MathUtils.*;

/**
 * Normalizes paths for interpolation by handling variable length paths and holes
 */
class PathNormalizer {
    /**
     * Calculates the perimeter of a path segment
     */
    public static function perimeterPoints(pts:FloatArray):Float {
        var n = pts.length;
        var x2 = pts[n - 2];
        var y2 = pts[n - 1];
        var p:Float = 0;

        var i = 0;
        while (i < n) {
            p += distance(pts[i], pts[i + 1], x2, y2);
            x2 = pts[i];
            y2 = pts[i + 1];
            i += 6;
        }

        return floor(p);
    }

    /**
     * Sorts segments by perimeter (largest first)
     */
    public static function getSortedSegments(pathSegments:Array<FloatArray>):Array<FloatArray> {
        var sorted = pathSegments.map(function(points) {
            return {
                points: points,
                perimeter: perimeterPoints(points)
            };
        });

        sorted.sort(function(a, b) {
            if (a.perimeter > b.perimeter) return -1;
            if (a.perimeter < b.perimeter) return 1;
            return 0;
        });

        return sorted.map(function(item) return item.points);
    }

    /**
     * Computes the bounding box and absolute origin point
     */
    public static function computeAbsoluteOrigin(relativeX:Float, relativeY:Float, points:FloatArray):{x:Float, y:Float} {
        var xmin = points[0];
        var ymin = points[1];
        var ymax = ymin;
        var xmax = xmin;

        var i = 2;
        while (i < points.length) {
            var x = points[i + 4];
            var y = points[i + 5];
            xmin = min(xmin, x);
            xmax = max(xmax, x);
            ymin = min(ymin, y);
            ymax = max(ymax, y);
            i += 6;
        }

        return {
            x: xmin + (xmax - xmin) * relativeX,
            y: ymin + (ymax - ymin) * relativeY
        };
    }

    /**
     * Rotates points in an array by the specified count
     */
    private static function rotatePoints(ns:FloatArray, count:Int):Void {
        var len = ns.length;
        var rightLen = len - count;
        var buffer:Array<Float> = [];

        // copy to buffer
        for (i in 0...count) {
            buffer.push(ns[i]);
        }

        // shift remaining elements
        for (i in count...len) {
            ns[i - count] = ns[i];
        }

        // copy buffer back
        for (i in 0...count) {
            ns[rightLen + i] = buffer[i];
        }
    }

    /**
     * Normalizes points by rotating to start from the same relative position
     */
    public static function normalizePoints(absolute:Bool, originX:Float, originY:Float, ns:FloatArray):Void {
        var len = ns.length;
        if (ns[len - 2] != ns[0] || ns[len - 1] != ns[1]) {
            // skip if this is not a closed shape
            return;
        }

        if (!absolute) {
            var relativeOrigin = computeAbsoluteOrigin(originX, originY, ns);
            originX = relativeOrigin.x;
            originY = relativeOrigin.y;
        }

        // create buffer to hold rotating data
        var buffer = ns.slice(2);
        len = buffer.length;

        // find the index of the shortest distance from the origin
        var index:Int = 0;
        var minAmount:Null<Float> = null;
        var i = 0;
        while (i < len) {
            var next = distance(originX, originY, buffer[i], buffer[i + 1]);

            if (minAmount == null || next < minAmount) {
                minAmount = next;
                index = i;
            }
            i += 6;
        }

        // rotate the points so that index is drawn first
        rotatePoints(buffer, index);

        // copy starting position from ending rotated position
        ns[0] = buffer[len - 2];
        ns[1] = buffer[len - 1];

        // copy rotated/aligned back onto original
        for (i in 0...buffer.length) {
            ns[i + 2] = buffer[i];
        }
    }

    /**
     * Fills segments - adds dummy segments to the smaller array
     */
    public static function fillSegments(larger:Array<FloatArray>, smaller:Array<FloatArray>, origin:Origin):Void {
        var largeLen = larger.length;
        var smallLen = smaller.length;

        if (largeLen < smallLen) {
            // swap so larger is actually larger
            fillSegments(smaller, larger, origin);
            return;
        }

        var originX = origin.x;
        var originY = origin.y;
        var absolute = origin.absolute == true;

        // add missing segments
        for (i in smallLen...largeLen) {
            var l = larger[i];
            var ox = originX;
            var oy = originY;

            if (!absolute) {
                var absoluteOrigin = computeAbsoluteOrigin(originX, originY, l);
                ox = absoluteOrigin.x;
                oy = absoluteOrigin.y;
            }

            var d:FloatArray = [];
            var k = 0;
            while (k < l.length) {
                d.push(ox);
                d.push(oy);
                k += 2;
            }

            smaller.push(d);
        }
    }

    /**
     * Fills a single subpath with extra points
     */
    private static function fillSubpath(ns:FloatArray, totalLength:Int):FloatArray {
        var totalNeeded = totalLength - ns.length;
        var ratio = Math.ceil(totalLength / ns.length);
        var result:FloatArray = [];

        // ensure result has correct size
        for (i in 0...totalLength) {
            result.push(0);
        }

        result[0] = ns[0];
        result[1] = ns[1];

        var k = 1;
        var j = 1;
        while (j < totalLength - 1) {
            result[++j] = ns[++k];
            result[++j] = ns[++k];
            result[++j] = ns[++k];
            result[++j] = ns[++k];
            var dx = result[++j] = ns[++k];
            var dy = result[++j] = ns[++k];

            if (totalNeeded > 0) {
                for (f in 0...ratio) {
                    if (totalNeeded > 0) {
                        result[j + 1] = result[j + 3] = result[j + 5] = dx;
                        result[j + 2] = result[j + 4] = result[j + 6] = dy;
                        j += 6;
                        totalNeeded -= 6;
                    }
                }
            }
        }

        return result;
    }

    /**
     * Fills points - adds extra points to match the longest path
     */
    public static function fillPoints(matrix:Matrix, addPoints:Int):Void {
        for (i in 0...matrix.left.length) {
            var left = matrix.left[i];
            var right = matrix.right[i];

            // find the target length
            var totalLength = Std.int(max(left.length + addPoints, right.length + addPoints));

            matrix.left[i] = fillSubpath(left, totalLength);
            matrix.right[i] = fillSubpath(right, totalLength);
        }
    }

    /**
     * Normalizes two paths for interpolation
     */
    public static function normalizePaths(left:Array<FloatArray>, right:Array<FloatArray>, options:InterpolateOptions):Matrix {
        var optimize = options.optimize != null ? options.optimize : Constants.FILL;
        var origin = options.origin != null ? options.origin : {x: 0.0, y: 0.0, absolute: false};
        var addPoints = options.addPoints != null ? options.addPoints : 0;

        // sort segments by perimeter if using fill optimization
        if (optimize == Constants.FILL) {
            left = getSortedSegments(left);
            right = getSortedSegments(right);
        }

        // ensure equal number of segments
        if (left.length != right.length) {
            if (optimize == Constants.FILL) {
                fillSegments(left, right, origin);
            } else {
                throw "optimize:none requires equal lengths";
            }
        }

        var matrix:Matrix = {
            left: left,
            right: right
        };

        // normalize and fill points if using fill optimization
        if (optimize == Constants.FILL) {
            var x = origin.x;
            var y = origin.y;
            var absolute = origin.absolute == true;

            // shift so both paths are being drawn from relatively the same place
            for (i in 0...left.length) {
                normalizePoints(absolute, x, y, matrix.left[i]);
                normalizePoints(absolute, x, y, matrix.right[i]);
            }

            fillPoints(matrix, addPoints * 6);
        }

        return matrix;
    }
}
