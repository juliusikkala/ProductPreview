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

## Deploy

```bash
npm run build
```

## Known issues

Some aliasing can be seen in the edges of the image area. One potential cause
for this is that the mask image does not fully match the antialiased material
buffers. This could be somewhat reduced by rendering all images using a box
filter instead of Blackman-Harris with a radius of 1.5, as the mask images
contain 2x2 aliased pixels per one screen pixel.
