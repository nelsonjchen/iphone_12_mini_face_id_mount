// Simplified Mount View

// 1. The "Mount" (Just a cube for now)
// 1. The "Mount" (Just a cube for now)
color("skyblue") {
  translate([0, 0, -5])
  cube([20, 70, 15], center=true)

  ;

  // Mirror Mount Cube
  // -45 degree angle to reflect +Z (face id) to +X (outward)
  // Spanning the whole mount (Y=70)
  translate([0, 0, 5]) // Center in Y, moved up in Z
    rotate([0, -45, 0])
      cube([2, 70, 20], center=true);
}

// 2. The iPhone 12 Mini Reference
// Orange, transparent
// Rotated -90 on X based on previous preview.scad hints to make it lay flat
%color("orange", 0.5)
  rotate([0, 90, 0])
    import("reference/iphone-12-mini.stl");
