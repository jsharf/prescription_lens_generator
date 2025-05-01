$fn = 0;
$fs = 0.5;
$fa = 0.5;

// The outline shape of the lens. 
module lens_punchout(xyscale=1, thickness=100) {
    translate([100, 0, 0])
    rotate([90, 0, 0])
    rotate([0, 270, 0])
    lens_shape(xyscale, thickness);
}

module lens_shape(xyscale=1, thickness=100) {
    scale([xyscale, xyscale, thickness])
    translate([0, 0, -0.6])
    import("lens_cutout_noridge.stl", convexity=3);
}

// OD Sphere
SPHERE_DEXTROUS = 0.0;
// OD Cyl
CYLINDER_DEXTROUS = -1.25;
// OS Axis
AXIS_DEXTROUS = 95;

// OS Sphere
SPHERE_SINISTER = 0.0;
// OS Cyl
CYLINDER_SINISTER = -2.25;
// OS Axis
AXIS_SINISTER = 95;

// Scale the lens to fit the lens punchout.
LENS_SCALE = 1;

// Estimated index for PLA
REFRACTION_INDEX = 1.46;

// An approximation for boundaries significantly larger than the lens shape.
INFINITY = 1e3;

module torus(spherical, cylindrical, axis = 0) {
    rotate([-axis, 0, 0])
    if (spherical == 0) {
        // Then it's just a cylinder...
        S = - cylindrical;
        R = (((REFRACTION_INDEX - 1) / S));
        echo(CylR=R);
        intersection() {
            translate([0, 0, -0.5])
            cylinder(h = 1, r=R);
            // Cut off the "cap" of the cylinder.
            translate([INFINITY/2, 0, 0])
            cube([INFINITY, INFINITY, INFINITY], center=true);
        }
    } else {
        s = spherical;
        S = s - cylindrical;
        echo(s=s, S=S);
        r = abs((REFRACTION_INDEX - 1) / s);
        R = abs(((REFRACTION_INDEX - 1) / S) - r);
        echo(r=r, R=R);
        translate([-R, 0, 0])
        intersection() {
            rotate_extrude(angle=360) {
                intersection() {
                    translate([R, 0, 0])
                    circle(r = r);
                    translate([INFINITY/2, 0, 0])
                    square([INFINITY, INFINITY], center=true);
                }
            }
            // Cut off the "cap" of the torus.
            translate([INFINITY/2 + R, 0, 0])
            cube([INFINITY, INFINITY, INFINITY], center=true);
        }
    }
}

// Make a back-toric lens. The front side is spherical and the ocular side is toric.
module backtoric_lens(sph, cyl, axis, lens_radius = 110, thickness=2) {
   sphere_power = (REFRACTION_INDEX - 1) / lens_radius;
   echo(sph=sph, cyl=cyl, axis=axis);
   // Re-write the prescription in plus-cylinder form.
   // n_sph = (cyl < 0) ? sph + cyl : sph;
   // n_cyl = (cyl < 0) ? - cyl : cyl;
   // n_axis = (cyl < 0) ? ((axis + 90) % 180) : axis;
   // echo("Rewrote prescription as: ", sph=n_sph, cyl=n_cyl, axis=n_axis);
   echo(sphere_power=sphere_power);
   difference() {
       translate([thickness, 0, 0])
       sphere(lens_radius);
       torus(sphere_power + sph, cyl, axis);
   }
}

module shaped_backtoric_lens(sph, cyl, axis, thickness=2) {
    intersection() {
        backtoric_lens(sph=sph, cyl=cyl, axis=axis, thickness=thickness);
        lens_punchout();
    }
}

// This code is just for the lens edge and has nothing to do with the prescription.
module curved_surface(thickness=1.2, curvature=140) {
    translate([0, 50, 0])
    translate([0, 0, -thickness/2])
    translate([0, 0, curvature])
    rotate([90, 0, 0])
    difference() {
        cylinder(100, curvature + thickness, curvature + thickness);
        translate([0, 0, -1])
        cylinder(102, curvature, curvature);
    }
}

module lens_curved(thickness=1.2, punchout_scale=1, curvature=140) {
    intersection() {
        lens_shape(punchout_scale);
        curved_surface(thickness, curvature);
    }
}

module groove(curvature=110) {
    difference() {
        hull() {
            shaped_backtoric_lens(sph=0, cyl=-1.25, axis=-95);
            translate([110, 0, 0])
            rotate([90, 0, 0])
            rotate([0, 270, 0])
            lens_curved(0.1, 1.02, curvature);

        }
        translate([-5, 0, 0])
        shaped_backtoric_lens(sph=0, cyl=-1.25, axis=-95, thickness=10);
    }
}

// Dextrous
shaped_backtoric_lens(sph=0, cyl=-1.25, axis=-95);
groove(120);
// Sinister
translate([0, 0, -50])
mirror([0, 1, 0])
shaped_backtoric_lens(sph=0, cyl=-2.25, axis=-95);





