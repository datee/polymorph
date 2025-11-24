import polymorph.Polymorph;
import polymorph.Types;

class Example {
    public static function main() {
        // Example 1: Simple shape morphing
        var star = "M25,2 L31,21 L50,21 L35,32 L41,50 L25,39 L9,50 L15,32 L0,21 L19,21 Z";
        var circle = "M25,5 A20,20 0 0,1 25,45 A20,20 0 0,1 25,5 Z";

        trace("=== Example 1: Star to Circle ===");
        var interpolator = Polymorph.interpolateTwo(star, circle);

        // Get paths at different points in the animation
        trace("At 0%: " + interpolator(0.0));
        trace("At 25%: " + interpolator(0.25));
        trace("At 50%: " + interpolator(0.5));
        trace("At 75%: " + interpolator(0.75));
        trace("At 100%: " + interpolator(1.0));

        // Example 2: Morphing with custom options
        var square = "M0,0 L100,0 L100,100 L0,100 Z";
        var triangle = "M50,0 L100,100 L0,100 Z";

        trace("\n=== Example 2: Square to Triangle (with options) ===");
        var options:InterpolateOptions = {
            optimize: "fill",
            addPoints: 10,
            precision: 2,
            origin: {x: 0.5, y: 0.5, absolute: false}
        };

        var interpolator2 = Polymorph.interpolateTwo(square, triangle, options);
        trace("At 0%: " + interpolator2(0.0));
        trace("At 50%: " + interpolator2(0.5));
        trace("At 100%: " + interpolator2(1.0));

        // Example 3: Multi-path morphing (morphing through multiple shapes)
        trace("\n=== Example 3: Multi-shape morphing ===");
        var shapes = [
            "M25,5 L45,45 L5,45 Z", // Triangle
            "M5,5 L45,5 L45,45 L5,45 Z", // Square
            "M25,5 A20,20 0 0,1 25,45 A20,20 0 0,1 25,5 Z" // Circle
        ];

        var multiInterpolator = Polymorph.interpolate(shapes);
        trace("At 0% (Triangle): " + multiInterpolator(0.0));
        trace("At 33% (to Square): " + multiInterpolator(0.33));
        trace("At 66% (to Circle): " + multiInterpolator(0.66));
        trace("At 100% (Circle): " + multiInterpolator(1.0));

        // Example 4: Handling paths with holes
        trace("\n=== Example 4: Paths with holes ===");
        var solidSquare = "M0,0 L100,0 L100,100 L0,100 Z";
        var squareWithHole = "M0,0 L100,0 L100,100 L0,100 Z M25,25 L75,25 L75,75 L25,75 Z";

        var holeInterpolator = Polymorph.interpolateTwo(solidSquare, squareWithHole);
        trace("At 0% (solid): " + holeInterpolator(0.0));
        trace("At 50% (hole forming): " + holeInterpolator(0.5));
        trace("At 100% (with hole): " + holeInterpolator(1.0));

        trace("\n=== All examples complete! ===");
    }
}
