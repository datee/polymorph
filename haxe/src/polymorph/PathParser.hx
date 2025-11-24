package polymorph;

import polymorph.Types;
import polymorph.Constants;
import polymorph.MathUtils.*;
import polymorph.ArcToCurve;

/**
 * Parses SVG path data strings into internal poly-bezier format
 */
class PathParser {
    // describes the number of arguments each command has
    private static var argLengths:Map<String, Int> = [
        "M" => 2, "H" => 1, "V" => 1, "L" => 2, "Z" => 0,
        "C" => 6, "S" => 4, "Q" => 4, "T" => 2, "A" => 7
    ];

    /**
     * Adds a curve to the segment
     */
    private static function addCurve(
        ctx:ParseContext,
        x1:Null<Float>, y1:Null<Float>,
        x2:Null<Float>, y2:Null<Float>,
        dx:Null<Float>, dy:Null<Float>
    ):Void {
        var x = ctx.x;
        var y = ctx.y;

        ctx.x = coalesce(dx, x);
        ctx.y = coalesce(dy, y);

        ctx.current.push(coalesce(x1, x));
        ctx.current.push(y1 = coalesce(y1, y));
        ctx.current.push(x2 = coalesce(x2, x));
        ctx.current.push(y2 = coalesce(y2, y));
        ctx.current.push(ctx.x);
        ctx.current.push(ctx.y);

        ctx.lc = ctx.c;
    }

    /**
     * Converts relative coordinates to absolute based on cursor position
     */
    private static function convertToAbsolute(ctx:ParseContext):Void {
        var c = ctx.c;
        var t = ctx.t;
        var x = ctx.x;
        var y = ctx.y;

        if (c == Constants.DRAW_LINE_VERTICAL) {
            t[0] += y;
        } else if (c == Constants.DRAW_LINE_HORIZONTAL) {
            t[0] += x;
        } else if (c == Constants.DRAW_ARC) {
            t[5] += x;
            t[6] += y;
        } else {
            var j = 0;
            while (j < t.length) {
                t[j] += x;
                t[j + 1] += y;
                j += 2;
            }
        }
    }

    /**
     * Parses path string into segments
     */
    private static function parseSegments(d:String):Array<Array<Dynamic>> {
        // replace all terms with space + term to remove garbage
        // replace command letters with an additional space
        // remove spaces around, split on double-space
        var regex1 = ~/[\^\s]*([mhvlzcsqta]|\-?\d*\.?\d+)[,\$\s]*/gi;
        var regex2 = ~/([mhvlzcsqta])/gi;

        var cleaned = regex1.map(d, function(r) {
            return " " + r.matched(1);
        });
        cleaned = regex2.map(cleaned, function(r) {
            return " " + r.matched(1);
        });
        cleaned = StringTools.trim(cleaned);

        var segments = cleaned.split("  ");
        return segments.map(parseSegment);
    }

    /**
     * Parses a single segment
     */
    private static function parseSegment(s:String):Array<Dynamic> {
        var parts = s.split(Constants.SPACE);
        var result:Array<Dynamic> = [];
        for (i in 0...parts.length) {
            if (i == 0) {
                result.push(parts[i]); // command letter
            } else {
                result.push(Std.parseFloat(parts[i])); // number
            }
        }
        return result;
    }

    /**
     * Parses SVG path data string into poly-bezier format
     * Returns array of segments, each segment is [mx, my, ...bezier points]
     */
    public static function parse(d:String):Array<FloatArray> {
        var ctx:ParseContext = {
            x: 0,
            y: 0,
            segments: []
        };

        var segments = parseSegments(d);

        for (i in 0...segments.length) {
            var terms = segments[i];
            var commandLetter:String = cast terms[0];
            var command = commandLetter.toUpperCase();
            var isRelative = command != Constants.CLOSE_PATH && command != commandLetter;

            ctx.c = command;

            var maxLength = argLengths.get(command);
            if (maxLength == null) {
                throw 'Unsupported command: $command';
            }

            var t2:Array<Float> = [for (j in 1...terms.length) cast(terms[j], Float)];
            var k = 0;

            do {
                ctx.t = t2.length == 0 ? [] : t2.slice(k, k + maxLength);

                if (isRelative) {
                    convertToAbsolute(ctx);
                }

                var n = ctx.t;
                var x = ctx.x;
                var y = ctx.y;

                if (command == Constants.MOVE_CURSOR) {
                    ctx.current = [ctx.x = n[0], ctx.y = n[1]];
                    ctx.segments.push(ctx.current);
                } else if (command == Constants.DRAW_LINE_HORIZONTAL) {
                    addCurve(ctx, null, null, null, null, n[0], null);
                } else if (command == Constants.DRAW_LINE_VERTICAL) {
                    addCurve(ctx, null, null, null, null, null, n[0]);
                } else if (command == Constants.DRAW_LINE) {
                    addCurve(ctx, null, null, null, null, n[0], n[1]);
                } else if (command == Constants.CLOSE_PATH) {
                    addCurve(ctx, null, null, null, null, ctx.current[0], ctx.current[1]);
                } else if (command == Constants.DRAW_CURVE_CUBIC_BEZIER) {
                    addCurve(ctx, n[0], n[1], n[2], n[3], n[4], n[5]);
                    ctx.cx = n[2];
                    ctx.cy = n[3];
                } else if (command == Constants.DRAW_CURVE_SMOOTH) {
                    var isInitialCurve = ctx.lc != Constants.DRAW_CURVE_SMOOTH &&
                                        ctx.lc != Constants.DRAW_CURVE_CUBIC_BEZIER;
                    var x1 = isInitialCurve ? null : x * 2 - ctx.cx;
                    var y1 = isInitialCurve ? null : y * 2 - ctx.cy;

                    addCurve(ctx, x1, y1, n[0], n[1], n[2], n[3]);
                    ctx.cx = n[0];
                    ctx.cy = n[1];
                } else if (command == Constants.DRAW_CURVE_QUADRATIC) {
                    var cx1 = n[0];
                    var cy1 = n[1];
                    var dx = n[2];
                    var dy = n[3];

                    addCurve(
                        ctx,
                        x + (cx1 - x) * Constants.QUADRATIC_RATIO,
                        y + (cy1 - y) * Constants.QUADRATIC_RATIO,
                        dx + (cx1 - dx) * Constants.QUADRATIC_RATIO,
                        dy + (cy1 - dy) * Constants.QUADRATIC_RATIO,
                        dx,
                        dy
                    );

                    ctx.cx = cx1;
                    ctx.cy = cy1;
                } else if (command == Constants.DRAW_CURVE_QUADRATIC_CONTINUATION) {
                    var dx = n[0];
                    var dy = n[1];

                    var x1:Float, y1:Float, x2:Float, y2:Float;
                    if (ctx.lc == Constants.DRAW_CURVE_QUADRATIC ||
                        ctx.lc == Constants.DRAW_CURVE_QUADRATIC_CONTINUATION) {
                        x1 = x + (x * 2 - ctx.cx - x) * Constants.QUADRATIC_RATIO;
                        y1 = y + (y * 2 - ctx.cy - y) * Constants.QUADRATIC_RATIO;
                        x2 = dx + (x * 2 - ctx.cx - dx) * Constants.QUADRATIC_RATIO;
                        y2 = dy + (y * 2 - ctx.cy - dy) * Constants.QUADRATIC_RATIO;
                    } else {
                        x1 = x2 = x;
                        y1 = y2 = y;
                    }

                    addCurve(ctx, x1, y1, x2, y2, dx, dy);
                    ctx.cx = x2;
                    ctx.cy = y2;
                } else if (command == Constants.DRAW_ARC) {
                    var beziers = ArcToCurve.convert(
                        x, y, n[0], n[1], n[2],
                        Std.int(n[3]), Std.int(n[4]), n[5], n[6]
                    );

                    var j = 0;
                    while (j < beziers.length) {
                        addCurve(ctx, beziers[j], beziers[j + 1], beziers[j + 2],
                                beziers[j + 3], beziers[j + 4], beziers[j + 5]);
                        j += 6;
                    }
                }

                k += maxLength;
            } while (k < t2.length);
        }

        return ctx.segments;
    }
}
