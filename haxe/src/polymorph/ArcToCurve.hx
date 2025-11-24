package polymorph;

import polymorph.MathUtils.*;
import polymorph.Constants;

/**
 * Converts SVG arc commands to cubic bezier curves
 */
class ArcToCurve {
    private static inline var _120:Float = Constants.PI * 120 / 180;
    private static inline var PI2:Float = Constants.PI * 2;

    public static function convert(
        x1:Float, y1:Float,
        rx:Float, ry:Float,
        angle:Float,
        large:Int, sweep:Int,
        dx:Float, dy:Float,
        ?f1:Float, ?f2:Float,
        ?cx:Float, ?cy:Float
    ):Array<Float> {
        if (rx <= 0 || ry <= 0) {
            return [x1, y1, dx, dy, dx, dy];
        }

        var rad = Constants.PI / 180 * angle;
        var cosrad = cos(rad);
        var sinrad = sin(rad);
        var recursive = f1 != null;

        if (!recursive) {
            var x1old = x1;
            var dxold = dx;
            x1 = x1old * cosrad - y1 * -sinrad;
            y1 = x1old * -sinrad + y1 * cosrad;
            dx = dxold * cosrad - dy * -sinrad;
            dy = dxold * -sinrad + dy * cosrad;

            var x = (x1 - dx) / 2;
            var y = (y1 - dy) / 2;

            var h = x * x / (rx * rx) + y * y / (ry * ry);
            if (h > 1) {
                h = sqrt(h);
                rx = h * rx;
                ry = h * ry;
            }

            var k = (large == sweep ? -1 : 1) *
                sqrt(abs((rx * rx * ry * ry - rx * rx * y * y - ry * ry * x * x) /
                         (rx * rx * y * y + ry * ry * x * x)));

            cx = k * rx * y / ry + (x1 + dx) / 2;
            cy = k * -ry * x / rx + (y1 + dy) / 2;

            f1 = asin((y1 - cy) / ry);
            f2 = asin((dy - cy) / ry);

            if (x1 < cx) {
                f1 = Constants.PI - f1;
            }
            if (dx < cx) {
                f2 = Constants.PI - f2;
            }
            if (f1 < 0) {
                f1 += PI2;
            }
            if (f2 < 0) {
                f2 += PI2;
            }
            if (sweep != 0 && f1 > f2) {
                f1 -= PI2;
            }
            if (sweep == 0 && f2 > f1) {
                f2 -= PI2;
            }
        }

        var res:Array<Float>;
        if (abs(f2 - f1) > _120) {
            var f2old = f2;
            var x2old = dx;
            var y2old = dy;

            f2 = f1 + _120 * (sweep != 0 && f2 > f1 ? 1 : -1);
            dx = cx + rx * cos(f2);
            dy = cy + ry * sin(f2);
            res = convert(dx, dy, rx, ry, angle, 0, sweep, x2old, y2old, f2, f2old, cx, cy);
        } else {
            res = [];
        }

        var t = 4 / 3 * tan((f2 - f1) / 4);

        // insert this curve into the beginning of the array
        var toInsert = [
            2 * x1 - (x1 + t * rx * sin(f1)),
            2 * y1 - (y1 - t * ry * cos(f1)),
            dx + t * rx * sin(f2),
            dy - t * ry * cos(f2),
            dx,
            dy
        ];

        for (i in 0...toInsert.length) {
            res.insert(i, toInsert[i]);
        }

        if (!recursive) {
            // if this is a top-level arc, rotate into position
            var i = 0;
            while (i < res.length) {
                var xt = res[i];
                var yt = res[i + 1];
                res[i] = xt * cosrad - yt * sinrad;
                res[i + 1] = xt * sinrad + yt * cosrad;
                i += 2;
            }
        }

        return res;
    }
}
