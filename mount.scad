// Simplified Mount View

// 1. The "Mount" (Just a cube for now)
module iphone_ref() {
  rotate([0, 90, 0])
    import("reference/iphone-12-mini.stl");
}

// 1. The "Mount" (Just a cube for now)
difference() {
  color("skyblue") {
    union() {
      translate([0, 0, -5])
        cube([20, 70, 15], center=true);

      // Mirror Mount Cube
      // -45 degree angle to reflect +Z (face id) to +X (outward)
      // Spanning the whole mount (Y=70)
      translate([0, 0, 5]) // Center in Y, moved up in Z
        rotate([0, -45, 0])
          cube([2, 70, 20], center=true);
    }
  }

  // Profile Cutout
  // Projects the phone's X-axis profile and extrudes it to create a cutter
  translate([0, 0, 0])
    rotate([0, -90, 0]) // Rotate back to X axis alignment
      linear_extrude(height=60, center=true)
        projection(cut=false)
          rotate([0, 90, 0]) // Rotate to Z for projection (captures X profile)
            iphone_ref();
}

// 2. The iPhone 12 Mini Reference
// Orange, transparent
// Rotated -90 on X based on previous preview.scad hints to make it lay flat
%color("orange", 0.5)
  iphone_ref();

// 3. The Mirror (Visual only)
// 2x2 inches = 50.8mm
// Placed on top of the mirror mount
%color("silver")
  translate([0, 0, 5])
    rotate([0, -45, 0])
      translate([-1.5, 0, 28]) // Offset to bottom (-1.5) for 1mm mirror, slide up (28)
        cube([1, 50.8, 50.8], center=true);
