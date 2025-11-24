# Canvas Demo

This interactive demo shows the Haxe Polymorph library in action, compiled to JavaScript and rendering to HTML5 Canvas.

## Features

- ✅ **Live Interpolation** - Watch shapes morph smoothly
- ✅ **Interactive Controls** - Drag slider or watch auto-animation
- ✅ **Multiple Examples** - Star, square, pentagon, and shapes with holes
- ✅ **Visual Feedback** - Real-time canvas rendering

## Building

### Prerequisites
- [Haxe 4.0+](https://haxe.org/download/) installed

### Build the Demo

```bash
# From the haxe directory
haxe build-demo.hxml
```

This will compile `src/CanvasDemo.hx` to `demo/canvasdemo.js`.

## Running

### Option 1: Simple HTTP Server (Python)

```bash
# From the demo directory
cd demo
python3 -m http.server 8000
```

Then open: http://localhost:8000

### Option 2: Simple HTTP Server (Node.js)

```bash
# Install http-server globally
npm install -g http-server

# From the demo directory
cd demo
http-server -p 8000
```

Then open: http://localhost:8000

### Option 3: Direct File Open

Some browsers allow opening `index.html` directly, but a local server is recommended for best results.

## What's Happening

The demo:

1. **Compiles** - Haxe compiles `CanvasDemo.hx` to optimized JavaScript
2. **Interpolates** - Creates smooth transitions between SVG paths
3. **Renders** - Uses HTML5 Canvas Path2D API to draw the morphed shapes
4. **Animates** - Automatically cycles through interpolation values

## Examples Included

### 1. Star to Circle
Morphs a 5-pointed star into a circle using arcs.

### 2. Square to Triangle
Shows how a 4-sided shape transitions to a 3-sided shape.

### 3. Rectangle to Circle
Demonstrates morphing rectangular shapes to circular ones.

### 4. Pentagon to Hexagon
Multi-point polygon morphing with different vertex counts.

### 5. Solid to Hole
Shows the library handling paths with subpaths (holes appearing).

## Key Code

### Creating an Interpolator

```haxe
var options:InterpolateOptions = {
    optimize: "fill",      // Handle variable lengths
    addPoints: 10,         // Extra smoothness
    precision: 2,          // Decimal places
    origin: {x: 0.5, y: 0.5, absolute: false}
};

interpolator = Polymorph.interpolate(shapes, options);
```

### Getting Interpolated Path

```haxe
var pathData = interpolator(progress);  // progress: 0.0 to 1.0
```

### Drawing to Canvas

```haxe
var path2d = new js.html.Path2D(pathData);
ctx.fill(path2d);
ctx.stroke(path2d);
```

## Browser Compatibility

Works in all modern browsers that support:
- HTML5 Canvas
- Path2D API
- ES5+ JavaScript

Tested on:
- Chrome 50+
- Firefox 48+
- Safari 10+
- Edge 79+

## File Structure

```
demo/
├── index.html          # Demo page with UI
├── canvasdemo.js       # Compiled Haxe code (generated)
└── README.md           # This file
```

## Customizing

### Add Your Own Shapes

Edit `src/CanvasDemo.hx` and add to the `examples` array:

```haxe
{
    name: "My Shape",
    shapes: [
        "M10,10 L90,10 L90,90 L10,90 Z",  // From
        "M50,10 L90,90 L10,90 Z"           // To
    ],
    scale: 2.0,
    offset: {x: 50, y: 50}
}
```

Then rebuild: `haxe build-demo.hxml`

### Adjust Animation Speed

In `CanvasDemo.hx`, change:

```haxe
progress += 0.005 * direction;  // Slower: 0.001, Faster: 0.01
```

### Change Canvas Size

In `index.html`:

```html
<canvas id="canvas" width="800" height="600"></canvas>
```

And adjust styles accordingly.

## Performance

The demo runs smoothly at 60 FPS because:
- Haxe compiles to optimized JavaScript
- Path2D API is hardware accelerated
- Interpolation is pure mathematics (no DOM manipulation)

## Troubleshooting

### "Canvas not found"
Make sure `index.html` has `<canvas id="canvas">` element.

### Blank canvas
Check browser console for errors. Make sure `canvasdemo.js` compiled successfully.

### Shapes not morphing
Verify the SVG path strings are valid. All paths must start with `M` (move).

### Compilation errors
Ensure Haxe 4.0+ is installed and all source files are in `src/polymorph/`.

## Next Steps

- Try adding your own SVG paths
- Experiment with different interpolation options
- Integrate into your own projects
- Use with animation libraries like GSAP or anime.js

## License

MIT - Same as the main library
