#!/usr/bin/env python3
"""Generate vibrant 256-color palette for flam3 in <color index="N" rgb="R G B"/> format"""
import sys
import random

def interpolate_colors(colors, steps=256):
    """Interpolate between a list of RGB tuples to create smooth gradient"""
    if len(colors) < 2:
        return colors * steps
    
    result = []
    segments = len(colors) - 1
    per_segment = steps // segments
    
    for i in range(segments):
        c1 = colors[i]
        c2 = colors[i + 1]
        
        seg_steps = per_segment if i < segments - 1 else steps - len(result)
        
        for j in range(seg_steps):
            t = j / seg_steps
            r = int(c1[0] + (c2[0] - c1[0]) * t)
            g = int(c1[1] + (c2[1] - c1[1]) * t)
            b = int(c1[2] + (c2[2] - c1[2]) * t)
            result.append((r, g, b))
    
    return result

def hex_to_rgb(h):
    """Convert hex string to RGB tuple"""
    h = h.lstrip('#')
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))

# Predefined vibrant color schemes (key colors to interpolate between)
SCHEMES = {
    'rainbow': ['ff0000', 'ff8800', 'ffff00', '00ff00', '00ffff', '0000ff', 'ff00ff', 'ff0000'],
    'cyberpunk': ['00ffff', '00aaff', '5500ff', 'aa00ff', 'ff00aa', 'ff0055', 'ff5500', 'ffaa00', 'ffff00'],
    'plasma': ['0d0887', '5c01a6', '9c179e', 'cc4778', 'ed7953', 'fdb42f', 'f0f921'],
    'neonfire': ['000066', '0000ff', '6600ff', 'cc00ff', 'ff0066', 'ff3300', 'ff9900', 'ffff00'],
    'aurora': ['00ff88', '00ffcc', '00ffff', '00aaff', '0066ff', '6600ff', 'cc00ff', 'ff66cc'],
    'lava': ['1a0000', '660000', 'aa0000', 'ff0000', 'ff4400', 'ff8800', 'ffcc00', 'ffff00', 'ffffff'],
    'ocean': ['000033', '000066', '003399', '0066cc', '0099ff', '00ccff', '00ffff', '66ffff', 'ccffff'],
    'toxic': ['000000', '003300', '006600', '00aa00', '00ff00', '66ff00', 'ccff00', 'ffff00', 'ffffff'],
    'candy': ['ff0066', 'ff00cc', 'cc00ff', '6600ff', '0066ff', '00ccff', '00ffcc', '00ff66', 'ffff00'],
    'sunset': ['1a0033', '4d0066', '800066', 'cc3366', 'ff6633', 'ff9933', 'ffcc33', 'ffff66'],
    'electric': ['000000', '0000ff', '0088ff', '00ffff', '00ff88', '00ff00', '88ff00', 'ffff00', 'ffffff'],
    'vaporwave': ['ff71ce', '01cdfe', '05ffa1', 'b967ff', 'fffb96', 'ff71ce'],
}

def generate_palette(scheme_name=None):
    """Generate a 256-color palette"""
    if scheme_name and scheme_name in SCHEMES:
        pass
    else:
        # Random scheme
        scheme_name = random.choice(list(SCHEMES.keys()))
    
    key_colors = [hex_to_rgb(c) for c in SCHEMES[scheme_name]]
    
    # Interpolate to 256 colors
    palette = interpolate_colors(key_colors, 256)
    
    return scheme_name, palette

def format_for_flam3(palette):
    """Format palette as flam3 <color index="N" rgb="R G B"/> tags"""
    lines = []
    for i, (r, g, b) in enumerate(palette):
        lines.append(f'   <color index="{i}" rgb="{r} {g} {b}"/>')
    return '\n'.join(lines)

if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1] == '--list':
        print('\n'.join(SCHEMES.keys()))
        sys.exit(0)
    
    scheme = sys.argv[1] if len(sys.argv) > 1 and sys.argv[1] != 'random' else None
    
    name, palette = generate_palette(scheme)
    print(f"# Scheme: {name}", file=sys.stderr)
    print(format_for_flam3(palette))
