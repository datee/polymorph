# Quick Start Guide - Polymorph Haxe

## Installation

### Prerequisites
- Haxe 4.0+ installed ([Download](https://haxe.org/download/))

### Setup
```bash
# Copy the polymorph folder to your project
cp -r haxe/src/polymorph /path/to/your/project/src/

# Or add to your classpath in build.hxml
-cp path/to/polymorph-haxe/src
```

## 5-Minute Tutorial

### 1. Basic Interpolation

```haxe
import polymorph.Polymorph;

class Main {
    static function main() {
        // Two SVG paths
        var star = "M25,2 L31,21 L50,21 L35,32 L41,50 L25,39 L9,50 L15,32 L0,21 L19,21 Z";
        var circle = "M25,5 A20,20 0 0,1 25,45 A20,20 0 0,1 25,5 Z";

        // Create interpolator
        var morph = Polymorph.interpolateTwo(star, circle);

        // Get path at 50% interpolation
        trace(morph(0.5));
    }
}
```

### 2. Animation Loop

```haxe
// In a game loop or animation framework
var morph = Polymorph.interpolateTwo(startPath, endPath);

function update(t:Float) {  // t from 0 to 1
    var currentPath = morph(t);
    // Use currentPath to update SVG, draw to canvas, etc.
}
```

### 3. With Options

```haxe
import polymorph.Types;

var options:InterpolateOptions = {
    optimize: "fill",
    addPoints: 10,
    precision: 2
};

var morph = Polymorph.interpolateTwo(path1, path2, options);
```

## Common Patterns

### Pattern 1: Simple Morph
```haxe
var morph = Polymorph.interpolateTwo(fromPath, toPath);
var halfway = morph(0.5);
```

### Pattern 2: Multiple Shapes
```haxe
var shapes = [triangle, square, pentagon, hexagon];
var morph = Polymorph.interpolate(shapes);

// Smoothly transitions through all shapes
for (i in 0...100) {
    trace(morph(i / 100));
}
```

### Pattern 3: Reverse Animation
```haxe
var morph = Polymorph.interpolateTwo(startPath, endPath);

// Forward
var forward = morph(progress);

// Backward
var backward = morph(1 - progress);
```

### Pattern 4: Ping-Pong
```haxe
var morph = Polymorph.interpolateTwo(startPath, endPath);

function getPingPong(t:Float):String {
    return t < 0.5
        ? morph(t * 2)          // 0→0.5 maps to 0→1
        : morph(2 - t * 2);     // 0.5→1 maps to 1→0
}
```

## Compilation

### Run with Interpreter
```bash
haxe -cp src -main Example --interp
```

### Compile to JavaScript
```bash
haxe -cp src -main Example -js output.js
```

### Compile to C++
```bash
haxe -cp src -main Example -cpp output
./output/Example
```

### Compile to Python
```bash
haxe -cp src -main Example -python output.py
python output.py
```

## Common Issues

### Issue: Paths don't morph smoothly
**Solution**: Add more points
```haxe
var options:InterpolateOptions = {
    addPoints: 20  // Increase this
};
```

### Issue: Different number of holes
**Solution**: Use optimize "fill" (default)
```haxe
var options:InterpolateOptions = {
    optimize: "fill"  // This is default, handles holes
};
```

### Issue: Output paths too large
**Solution**: Reduce precision
```haxe
var options:InterpolateOptions = {
    precision: 0  // Use integers only
};
```

### Issue: Shapes rotate during morph
**Solution**: Adjust origin point
```haxe
var options:InterpolateOptions = {
    origin: {
        x: 0.5,  // Center horizontally
        y: 0.5,  // Center vertically
        absolute: false
    }
};
```

## Tips & Tricks

### Tip 1: Cache Interpolators
```haxe
// Don't create every frame
var morph = Polymorph.interpolateTwo(a, b);

// Reuse it
for (i in 0...1000) {
    var path = morph(i / 1000);
}
```

### Tip 2: Normalize Input Paths
For best results, ensure paths:
- Start with M (move) command
- End with Z (close) for closed shapes
- Use consistent scale

### Tip 3: Test Edge Cases
```haxe
morph(0.0);   // Should equal start path
morph(1.0);   // Should equal end path
morph(0.5);   // Should be valid intermediate
```

### Tip 4: Performance
```haxe
// Faster (for production)
var options:InterpolateOptions = {
    optimize: "fill",
    addPoints: 0,      // Minimum needed
    precision: 0       // Integer coordinates
};

// Higher quality (for export)
var options:InterpolateOptions = {
    optimize: "fill",
    addPoints: 50,     // Smooth curves
    precision: 3       // More precision
};
```

## SVG Path Primer

### Basic Commands
- `M x y` - Move to point
- `L x y` - Line to point
- `H x` - Horizontal line
- `V y` - Vertical line
- `C x1 y1 x2 y2 x y` - Cubic bezier
- `Q x1 y1 x y` - Quadratic bezier
- `A rx ry angle large sweep x y` - Arc
- `Z` - Close path

### Example Shapes

**Square**
```haxe
"M0,0 L100,0 L100,100 L0,100 Z"
```

**Circle** (using arcs)
```haxe
"M50,0 A50,50 0 0,1 50,100 A50,50 0 0,1 50,0 Z"
```

**Triangle**
```haxe
"M50,0 L100,100 L0,100 Z"
```

**Star**
```haxe
"M50,0 L61,35 L98,35 L68,57 L79,91 L50,70 L21,91 L32,57 L2,35 L39,35 Z"
```

**Square with Hole**
```haxe
"M0,0 L100,0 L100,100 L0,100 Z M25,25 L75,25 L75,75 L25,75 Z"
```

## Next Steps

1. ✅ Copy library to your project
2. ✅ Run the Example.hx to see it in action
3. ✅ Try morphing your own SVG paths
4. ✅ Integrate with your animation framework
5. ✅ Read full README.md for detailed API docs

## Need Help?

- Check the full [README.md](README.md)
- Review [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)
- See [Example.hx](src/Example.hx) for more examples
- Original docs: https://notoriousb1t.github.io/polymorph-docs

## License

MIT - Free for personal and commercial use
