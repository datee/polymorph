# Polymorph Haxe

A vanilla Haxe port of [Polymorph](https://github.com/notoriousb1t/polymorph) - a library for morphing SVG paths.

This is a pure Haxe implementation with **no framework dependencies** that focuses on the core path-to-path interpolation functionality.

## Features

✅ **Path to Path Interpolation** - Smoothly morph between any two SVG paths
✅ **Variable Length Paths** - Automatically handles paths with different numbers of points
✅ **Holes in Paths** - Properly handles paths with subpaths (holes)
✅ **Multi-Path Morphing** - Morph through multiple shapes in sequence
✅ **Vanilla Haxe** - No external dependencies or frameworks
✅ **No Browser/JS Dependencies** - Pure path mathematics, works anywhere Haxe runs

## 🎨 Live Demo

Check out the **interactive canvas demo** in the `demo/` folder!

```bash
# Build the demo
haxe build-demo.hxml

# Serve it locally
cd demo && python3 -m http.server 8000
# Then open http://localhost:8000
```

The demo shows:
- Real-time path morphing with HTML5 Canvas
- Multiple shape examples (star, polygons, shapes with holes)
- Interactive controls and auto-animation
- Visual proof that the Haxe port works perfectly!

See [demo/README.md](demo/README.md) for full details.

## What This Port Includes

This port focuses on the core interpolation functionality:

- ✅ SVG path parsing (M, L, H, V, C, S, Q, T, A, Z commands)
- ✅ Path normalization (handling variable lengths and holes)
- ✅ Path interpolation algorithm
- ✅ Path rendering back to SVG strings

## What This Port Excludes

Since this is a vanilla Haxe port focused on interpolation only:

- ❌ No browser-specific features (DOM manipulation)
- ❌ No SVG rendering or display
- ❌ No animation framework integration
- ❌ No HTML/CSS features

## Installation

1. Copy the `src/polymorph` folder to your Haxe project
2. Add to your classpath in your `.hxml` file:
   ```
   -cp src
   ```

## Usage

### Basic Example

```haxe
import polymorph.Polymorph;

class Main {
    public static function main() {
        // Define two SVG paths
        var star = "M25,2 L31,21 L50,21 L35,32 L41,50 L25,39 L9,50 L15,32 L0,21 L19,21 Z";
        var circle = "M25,5 A20,20 0 0,1 25,45 A20,20 0 0,1 25,5 Z";

        // Create an interpolator function
        var interpolator = Polymorph.interpolateTwo(star, circle);

        // Get intermediate paths
        var path0 = interpolator(0.0);   // Star (start)
        var path25 = interpolator(0.25); // 25% morphed
        var path50 = interpolator(0.5);  // 50% morphed
        var path75 = interpolator(0.75); // 75% morphed
        var path100 = interpolator(1.0); // Circle (end)

        trace(path50); // SVG path string at 50% interpolation
    }
}
```

### With Options

```haxe
import polymorph.Polymorph;
import polymorph.Types;

var square = "M0,0 L100,0 L100,100 L0,100 Z";
var triangle = "M50,0 L100,100 L0,100 Z";

var options:InterpolateOptions = {
    optimize: "fill",     // or "none"
    addPoints: 10,        // add extra points for smoother interpolation
    precision: 2,         // decimal places in output
    origin: {
        x: 0.5,           // 50% from left
        y: 0.5,           // 50% from top
        absolute: false   // relative positioning
    }
};

var interpolator = Polymorph.interpolateTwo(square, triangle, options);
```

### Multi-Path Morphing

Morph through multiple shapes in sequence:

```haxe
var shapes = [
    "M25,5 L45,45 L5,45 Z",              // Triangle
    "M5,5 L45,5 L45,45 L5,45 Z",         // Square
    "M25,5 A20,20 0 0,1 25,45 A20,20 0 0,1 25,5 Z"  // Circle
];

var interpolator = Polymorph.interpolate(shapes);

// offset 0.0 - 0.33: Triangle to Square
// offset 0.33 - 0.66: Square to Circle
// offset 0.66 - 1.0: Final transition
var path = interpolator(0.5); // Midway through all transitions
```

### Handling Paths with Holes

The library automatically handles paths with subpaths (holes):

```haxe
var solidSquare = "M0,0 L100,0 L100,100 L0,100 Z";
var squareWithHole = "M0,0 L100,0 L100,100 L0,100 Z M25,25 L75,25 L75,75 L25,75 Z";

var interpolator = Polymorph.interpolateTwo(solidSquare, squareWithHole);

// Watch a hole appear in the square
var path = interpolator(0.5); // Hole is half-formed
```

## API Reference

### `Polymorph.interpolate(paths, options)`

Creates an interpolator function for multiple paths.

**Parameters:**
- `paths: Array<String>` - Array of SVG path data strings (minimum 2)
- `options: InterpolateOptions` - Optional configuration

**Returns:** `(Float) -> String` - Function that takes offset (0-1) and returns SVG path string

### `Polymorph.interpolateTwo(fromPath, toPath, options)`

Convenience method for interpolating between two paths.

**Parameters:**
- `fromPath: String` - Starting SVG path
- `toPath: String` - Ending SVG path
- `options: InterpolateOptions` - Optional configuration

**Returns:** `(Float) -> String` - Function that takes offset (0-1) and returns SVG path string

### `InterpolateOptions`

```haxe
typedef InterpolateOptions = {
    ?optimize: String,     // "fill" (default) or "none"
    ?addPoints: Int,       // Extra points to add (default: 0)
    ?precision: Int,       // Decimal places (default: 0)
    ?origin: Origin        // Origin point for normalization
}

typedef Origin = {
    x: Float,              // X position
    y: Float,              // Y position
    ?absolute: Bool        // true = absolute coords, false = relative (default)
}
```

### Options Explained

- **optimize**:
  - `"fill"` (default) - Automatically adds points and subpaths to align paths
  - `"none"` - Requires paths to have equal points (faster but limited)

- **addPoints**: Number of extra points to add for smoother interpolation (default: 0)

- **precision**: Decimal places in output SVG (default: 0 for performance)

- **origin**: Point used for aligning shapes when normalizing
  - `absolute: false` - x/y are 0-1 (percentage of shape)
  - `absolute: true` - x/y are absolute SVG coordinates

## How It Works

1. **Parse**: SVG path strings are parsed into internal poly-bezier format (all commands converted to cubic beziers)

2. **Normalize**: Paths are normalized for interpolation:
   - Sort subpaths by perimeter size
   - Add dummy subpaths to match hole counts
   - Add points to match path lengths
   - Rotate points to start from same relative position

3. **Interpolate**: Linear interpolation between normalized point arrays

4. **Render**: Convert back to SVG path string format

## Compilation Example

Create a `build.hxml` file:

```hxml
-cp src
-main Example
-dce full

# Choose your target:
# --interp           # Run with interpreter
# -js output.js      # Compile to JavaScript
# -cpp output        # Compile to C++
# -cs output         # Compile to C#
# -java output       # Compile to Java
# -python output.py  # Compile to Python
```

Then run:
```bash
haxe build.hxml
```

## Running the Examples

### Command-Line Example

```bash
haxe -cp src -main Example --interp
```

### Canvas Demo (JavaScript)

```bash
# Build the interactive canvas demo
haxe build-demo.hxml

# Serve and view in browser
cd demo && python3 -m http.server 8000
```

The canvas demo compiles to JavaScript and provides a visual, interactive demonstration of the library.

## Platform Support

Since this is vanilla Haxe with no external dependencies, it works on all Haxe targets:
- JavaScript
- C++
- C#
- Java
- Python
- PHP
- Lua
- And more!

## Original Project

This is a port of [Polymorph](https://github.com/notoriousb1t/polymorph) by Christopher Wallis.

Original TypeScript/JavaScript version:
- GitHub: https://github.com/notoriousb1t/polymorph
- Docs: https://notoriousb1t.github.io/polymorph-docs

## License

MIT License (same as original)

## Notes

- This port focuses purely on the mathematical path interpolation
- All SVG path commands (M, L, H, V, C, S, Q, T, A, Z) are supported
- Paths are internally converted to cubic beziers for consistent interpolation
- The library handles both absolute and relative SVG commands
- Works with any number of subpaths (handles holes correctly)
- No floating point arrays optimization (uses regular Haxe Arrays)
