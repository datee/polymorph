import polymorph.Polymorph;
import polymorph.Types;
import js.Browser;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;

/**
 * Canvas demo showing path interpolation with visual rendering
 */
class CanvasDemo {
    private static var canvas:CanvasElement;
    private static var ctx:CanvasRenderingContext2D;
    private static var progress:Float = 0;
    private static var direction:Int = 1;
    private static var interpolator:(Float) -> String;
    private static var currentExample:Int = 0;

    // Demo shapes
    private static var examples:Array<{name:String, shapes:Array<String>, scale:Float, offset:{x:Float, y:Float}}> = [
        {
            name: "Star to Circle",
            shapes: [
                "M50,10 L61,40 L95,40 L68,60 L79,95 L50,75 L21,95 L32,60 L5,40 L39,40 Z",
                "M50,10 A40,40 0 0,1 50,90 A40,40 0 0,1 50,10 Z"
            ],
            scale: 2.0,
            offset: {x: 50, y: 50}
        },
        {
            name: "Square to Triangle",
            shapes: [
                "M10,10 L90,10 L90,90 L10,90 Z",
                "M50,10 L90,90 L10,90 Z"
            ],
            scale: 2.0,
            offset: {x: 50, y: 50}
        },
        {
            name: "Rectangle to Circle",
            shapes: [
                "M20,30 L80,30 L80,70 L20,70 Z",
                "M50,30 A20,20 0 0,1 50,70 A20,20 0 0,1 50,30 Z"
            ],
            scale: 2.5,
            offset: {x: 25, y: 25}
        },
        {
            name: "Pentagon to Hexagon",
            shapes: [
                "M50,5 L95,35 L78,85 L22,85 L5,35 Z",
                "M50,5 L90,25 L90,75 L50,95 L10,75 L10,25 Z"
            ],
            scale: 2.0,
            offset: {x: 50, y: 50}
        },
        {
            name: "Solid to Hole",
            shapes: [
                "M10,10 L90,10 L90,90 L10,90 Z",
                "M10,10 L90,10 L90,90 L10,90 Z M30,30 L70,30 L70,70 L30,70 Z"
            ],
            scale: 2.0,
            offset: {x: 50, y: 50}
        }
    ];

    public static function main():Void {
        Browser.window.onload = function(_) {
            init();
        };
    }

    private static function init():Void {
        canvas = cast Browser.document.getElementById("canvas");
        if (canvas == null) {
            trace("Canvas not found!");
            return;
        }

        ctx = canvas.getContext2d();

        // Setup UI
        var nextBtn = Browser.document.getElementById("nextExample");
        if (nextBtn != null) {
            nextBtn.onclick = function(_) {
                currentExample = (currentExample + 1) % examples.length;
                setupExample();
            };
        }

        var prevBtn = Browser.document.getElementById("prevExample");
        if (prevBtn != null) {
            prevBtn.onclick = function(_) {
                currentExample = (currentExample - 1 + examples.length) % examples.length;
                setupExample();
            };
        }

        var slider = Browser.document.getElementById("progress");
        if (slider != null) {
            slider.oninput = function(_) {
                var input:js.html.InputElement = cast slider;
                progress = Std.parseFloat(input.value) / 100;
                render();
            };
        }

        setupExample();
        animate();
    }

    private static function setupExample():Void {
        var example = examples[currentExample];

        // Update title
        var titleEl = Browser.document.getElementById("exampleName");
        if (titleEl != null) {
            titleEl.textContent = example.name;
        }

        // Create interpolator with options
        var options:InterpolateOptions = {
            optimize: "fill",
            addPoints: 10,
            precision: 2,
            origin: {x: 0.5, y: 0.5, absolute: false}
        };

        interpolator = Polymorph.interpolate(example.shapes, options);
        progress = 0;
        direction = 1;
        render();
    }

    private static function animate():Void {
        // Auto-animate
        progress += 0.005 * direction;

        if (progress >= 1.0) {
            progress = 1.0;
            direction = -1;
        } else if (progress <= 0.0) {
            progress = 0.0;
            direction = 1;
        }

        // Update slider
        var slider:js.html.InputElement = cast Browser.document.getElementById("progress");
        if (slider != null) {
            slider.value = Std.string(Math.round(progress * 100));
        }

        render();
        Browser.window.requestAnimationFrame(animate);
    }

    private static function render():Void {
        var example = examples[currentExample];

        // Clear canvas
        ctx.fillStyle = "#f0f0f0";
        ctx.fillRect(0, 0, canvas.width, canvas.height);

        // Get interpolated path
        var pathData = interpolator(progress);

        // Draw the path
        ctx.save();
        ctx.translate(example.offset.x, example.offset.y);
        ctx.scale(example.scale, example.scale);

        // Parse and draw SVG path
        drawSVGPath(pathData);

        ctx.restore();

        // Draw progress indicator
        drawProgressIndicator();
    }

    private static function drawSVGPath(pathData:String):Void {
        // Create a Path2D from SVG string (browser native)
        var path2d = new js.html.Path2D(pathData);

        // Fill
        ctx.fillStyle = "#4CAF50";
        ctx.fill(path2d);

        // Stroke
        ctx.strokeStyle = "#2E7D32";
        ctx.lineWidth = 1;
        ctx.stroke(path2d);
    }

    private static function drawProgressIndicator():Void {
        var barWidth = canvas.width - 40;
        var barHeight = 10;
        var barX = 20;
        var barY = canvas.height - 30;

        // Background
        ctx.fillStyle = "#ddd";
        ctx.fillRect(barX, barY, barWidth, barHeight);

        // Progress
        ctx.fillStyle = "#4CAF50";
        ctx.fillRect(barX, barY, barWidth * progress, barHeight);

        // Border
        ctx.strokeStyle = "#999";
        ctx.lineWidth = 1;
        ctx.strokeRect(barX, barY, barWidth, barHeight);

        // Text
        ctx.fillStyle = "#333";
        ctx.font = "12px monospace";
        ctx.textAlign = "center";
        ctx.fillText('${Math.round(progress * 100)}%', canvas.width / 2, barY - 5);
    }
}
