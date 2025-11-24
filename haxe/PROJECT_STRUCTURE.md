# Polymorph Haxe - Project Structure

## Directory Structure

```
haxe/
├── README.md                  # Main documentation
├── PROJECT_STRUCTURE.md       # This file
├── build.hxml                 # Haxe build configuration
├── src/
│   ├── Example.hx            # Example usage
│   └── polymorph/            # Main library package
│       ├── Types.hx          # Type definitions
│       ├── Constants.hx      # Constants (commands, math)
│       ├── MathUtils.hx      # Math utility functions
│       ├── ArcToCurve.hx     # Arc to cubic bezier conversion
│       ├── PathParser.hx     # SVG path string parser
│       ├── PathRenderer.hx   # Render to SVG path string
│       ├── PathNormalizer.hx # Path normalization for interpolation
│       ├── Path.hx           # Path class
│       └── Polymorph.hx      # Main API
```

## Module Overview

### Core Modules

**Polymorph.hx** - Main API
- `interpolate(paths, options)` - Interpolate between multiple paths
- `interpolateTwo(from, to, options)` - Convenience for two paths

**Path.hx** - Path representation
- Wraps parsed path data
- Provides rendering capabilities

### Parsing & Rendering

**PathParser.hx** - SVG Path Parser
- Parses SVG path data strings
- Converts all commands to cubic beziers
- Handles absolute and relative commands
- Supports: M, L, H, V, C, S, Q, T, A, Z

**PathRenderer.hx** - SVG Path Renderer
- Converts internal format back to SVG strings
- Handles precision formatting
- Optimizes duplicate points

**ArcToCurve.hx** - Arc Conversion
- Converts SVG arc commands to cubic beziers
- Recursive splitting for large arcs
- Handles rotation and elliptical arcs

### Normalization

**PathNormalizer.hx** - Path Normalization
- Sorts segments by perimeter
- Fills segments (handles holes)
- Fills points (matches lengths)
- Normalizes point rotation
- Computes bounding boxes and origins

### Utilities

**Types.hx** - Type Definitions
- FloatArray, Matrix, Origin
- InterpolateOptions, ParseContext

**Constants.hx** - Constants
- SVG command constants
- Math constants (PI, EPSILON)
- String constants

**MathUtils.hx** - Math Functions
- Basic math (abs, min, max, floor, round)
- Trigonometry (sin, cos, tan, asin)
- Distance calculation
- Coalesce helper

## Data Flow

```
SVG String → PathParser → FloatArray[]
                              ↓
                        PathNormalizer
                         (left & right)
                              ↓
                        Mix Points (interpolate)
                              ↓
                        PathRenderer → SVG String
```

## Internal Data Format

Paths are stored as poly-bezier data:

```haxe
// Array of segments (subpaths)
Array<FloatArray>

// Each segment:
[mx, my, cp1x, cp1y, cp2x, cp2y, dx, dy, ...]
// mx, my: move to (start of subpath)
// Then repeating sets of 6 numbers for each cubic bezier:
//   cp1x, cp1y: first control point
//   cp2x, cp2y: second control point
//   dx, dy: destination point
```

All SVG commands are converted to cubic beziers (Move + Curve):
- Lines become flat beziers (control points = endpoints)
- Quadratic curves converted using 2/3 ratio
- Arcs converted to multiple cubic beziers
- All coordinates made absolute

## Compilation Targets

This vanilla Haxe code compiles to all Haxe targets:

### Tested Targets
- `--interp` - Haxe interpreter (good for testing)
- `-js output.js` - JavaScript (browser or Node.js)
- `-cpp output` - C++ (native performance)

### Should Work (not tested)
- `-cs output` - C#
- `-java output` - Java
- `-python output.py` - Python
- `-php output` - PHP
- `-lua output.lua` - Lua
- And all other Haxe targets

## Key Algorithms

### 1. Path Parsing
- Regex-based tokenization
- Command argument validation
- Relative to absolute conversion
- All commands → cubic beziers

### 2. Path Normalization
- Sort by perimeter (larger first)
- Match segment counts (fill with point at origin)
- Match point counts (duplicate last point)
- Rotate to align starting points

### 3. Interpolation
- Linear interpolation: `a + (b - a) * t`
- Applied to each coordinate
- Maintains bezier structure

### 4. Optimization Strategies

**optimize: "fill"** (default)
- Adds points/segments as needed
- Works with any paths
- Slightly slower but more flexible

**optimize: "none"**
- Requires equal lengths
- Faster (no normalization)
- Limited use cases

## Dependencies

**None!** Pure vanilla Haxe standard library only.

## Performance Considerations

1. **Precision**: Use `precision: 0` for best performance
2. **addPoints**: Only add when needed for quality
3. **optimize**: Use "none" if paths already match
4. **Caching**: Cache interpolator functions when reusing

## Future Enhancements (Not Included)

This port focuses on core interpolation. Possible additions:

- Easing functions integration
- Animation helpers
- Path simplification/optimization
- Path validation
- More origin modes (centroid, etc.)
- Performance optimizations (typed arrays where available)

## Testing

To test the library:

1. Install Haxe: https://haxe.org/download/
2. Run: `haxe build.hxml`
3. Check output for interpolated paths

Example output shows paths at different interpolation offsets.

## Integration

To use in your project:

```haxe
// In your .hxml:
-cp path/to/polymorph/src

// In your code:
import polymorph.Polymorph;
var interpolator = Polymorph.interpolateTwo(path1, path2);
var result = interpolator(0.5);
```

## Porting Notes

This port maintains the original algorithm and structure while:
- Using Haxe idioms (Map instead of object literals for fixed maps)
- Using Haxe standard library (Math, String, Array)
- Removing browser/DOM dependencies
- Removing Float32Array (using Array<Float>)
- Adapting TypeScript patterns to Haxe
- Maintaining MIT license compatibility

The core mathematics and algorithms are unchanged from the original.
