package polymorph;

import polymorph.Types;
import polymorph.PathParser;
import polymorph.PathRenderer;

/**
 * Represents a parsed SVG path
 */
class Path {
    private var data:Array<FloatArray>;
    private var stringData:Null<String>;

    /**
     * Creates a Path from an SVG path data string or pre-parsed data
     */
    public function new(pathData:Dynamic) {
        if (Std.isOfType(pathData, String)) {
            var pathString:String = cast pathData;
            this.data = PathParser.parse(pathString);
            this.stringData = pathString;
        } else if (Std.isOfType(pathData, Array)) {
            this.data = cast pathData;
            this.stringData = null;
        } else {
            throw "Path data must be a String or Array<FloatArray>";
        }
    }

    /**
     * Returns the internal poly-bezier data
     */
    public function getData():Array<FloatArray> {
        return data;
    }

    /**
     * Returns the SVG path string representation
     */
    public function getStringData():String {
        if (stringData == null) {
            stringData = render();
        }
        return stringData;
    }

    /**
     * Renders the path to an SVG path string
     */
    public function render(precision:Int = 0):String {
        return PathRenderer.render(data, precision);
    }
}
