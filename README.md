This repository contains my experiment with making a pair of lenses 100% with
3D printing. The idea is that if we can make glasses with radically simplified
manufacturing, you could help improve access to eyewear and glasses around the
world, and also potentially provide rapid turnaround for glasses at low volume.

This is super hacky and in-progress. No guarantees, just wanted to post online
in case its helpful to someone else.

Also, I suspect there are bugs as when I printed this, it was slightly off. Will
update when I have progress.

Oh also you need to set FN to a high value for accurate printing, but doing so
crashes the UI. So I keep FN low while prototyping, and then for final rendering
I jack it up really high and then render headless so that the OpenSCAD UI
doesn't freeze. There's a way to work around this now with newer features via
like background() and render(), but that's a TODO for now.
