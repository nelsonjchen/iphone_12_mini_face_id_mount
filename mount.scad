// Simplified Mount View

// 1. The "Mount" (Just a cube for now)
color("skyblue")
  cube([20, 70, 20], center=true);

// 2. The iPhone 12 Mini Reference
// Orange, transparent
// Rotated -90 on X based on previous preview.scad hints to make it lay flat
%color("orange", 0.5)
  rotate([0, 90, 0])
    import("reference/iphone-12-mini.stl");
