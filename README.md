# Product Preview PoC

[Live!](https://pp.jji.fi)

A proof-of-concept webapp that generates very realistic product preview images
with user-supplied images printed/shown on the product.

There are likely issues with certain mobile devices (such as Safari on iDevices)
because the demo requires WebGL2 support. Furthermore, there is no mobile layout
for now so landscape mode is a must. Loading times on Firefox can be quite long
due to complications in loading 16bpc PNGs. Chrome/Chromium seems to be a bit
faster.

There are three scenes, showcasing different kinds of materials:
* Puzzle (dielectric material)
* Poster (metallic material, the alpha channel is used for mixing between paper and metal layer)
* TV (emissive material that lights up the room)

## Get started

```bash
npm install
npm run dev
```

## Production build

```bash
npm run build
```

## Known issues

Some aliasing can be seen in the edges of the image area. One potential cause
for this is that the mask image does not fully match the antialiased material
buffers. This could be somewhat reduced by rendering all images using a box
filter instead of Blackman-Harris with a radius of 1.5, as the mask images
contain 2x2 aliased pixels per one screen pixel.

## Asset credits

Puzzle scene:
* [Industrial sideboard](https://www.blendswap.com/blend/24008) (CC0)
* [Jigsaw Puzzle](https://www.blendswap.com/blend/23563) (CC0)
* [Bricks 023](https://cc0textures.com/view?id=Bricks023) (CC0)

Poster scene:
* [Fireplace Room](https://casual-effects.com/data/) (Wig42, CC-BY-3.0)
* [Paper 001](https://cc0textures.com/view?id=Paper001) (CC0)
* [Floor Lamp](https://www.blendswap.com/blend/20724) (CC0)
* [Wood 026](https://cc0textures.com/view?id=Wood026) (CC0)

TV scene:
* [Fireplace Room](https://casual-effects.com/data/) (Wig42, CC-BY-3.0)
* [Husk chair](https://www.blendswap.com/blend/11475) (CC0)
* [Floor Lamp](https://www.blendswap.com/blend/20724) (CC0)

The TV and poster assets were created by me.
