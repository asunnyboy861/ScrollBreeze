# App Icon

## Generation Prompt
```
ScrollBreeze iOS app icon, a glowing breathing ring with teal to indigo radial gradient,
soft inner glow, large dominant subject filling the entire square frame, edge-to-edge composition,
no padding, no margin, no empty space, no transparent edges,
solid deep space navy blue background #0D1226, flat design with subtle gradient depth, simple bold shapes,
professional, clean, no text, no words, no letters, square format, 1024x1024
```

## Generated Image
- File: `ScrollBreeze/Assets.xcassets/AppIcon.appiconset/icon_1024.png`
- Raw: `icon_raw.png` (project root)
- Style: Glowing breath ring, teal→indigo radial gradient on deep-space navy (#0D1226) — matches the in-app hero visual
- API: Agnes Image 2.1 Flash (primary)
- Attempts: 1 generation (API OK; download retried once after SSL EOF)

## Post-Processing
- Padding trimmed, subject scaled to ~90% frame, centered on opaque #0D1226 canvas
- Alpha channel removed (RGB mode) — verified `hasAlpha: no`
- Size: 1024x1024

## Asset Catalog
- AppIcon.appiconset configured: ✅
- Single-size 1024x1024 (Xcode auto-derives all sizes): ✅
