// Simplified Mount View

// 1. The "Mount" (Just a cube for now)
module iphone_ref() {
  rotate([0, 90, 0])
    import("reference/iphone-12-mini.stl");
}

// 1. The "Mount" (Just a cube for now)
module mirror_tray() {
  mirror_w = 50.0;
  mirror_h = 50.0;
  mirror_d = 1.0;

  wall = 2;
  tolerance = 0.5; // Clearance for sliding

  slot_w = mirror_w + tolerance * 2;
  slot_d = mirror_d + tolerance; // Thickness clearance

  // Widen to match the mount base (70mm)
  outer_w = 70;

  outer_h = mirror_h + wall + 5; // Extra length at bottom for stop
  outer_d = slot_d + wall * 2;

  // Side supports that extend back to the base
  side_block_w = (outer_w - slot_w) / 2;
  side_block_d = 20; // Extend deep to hit base

  difference() {
    union() {
      // Main Frame
      cube([outer_d, outer_w, outer_h], center=true);

      // Side Supports (Walls extending back)
      // Left Side
      translate([-side_block_d / 2 + outer_d / 2, outer_w / 2 - side_block_w / 2, 0])
        cube([side_block_d, side_block_w, outer_h], center=true);

      // Right Side
      translate([-side_block_d / 2 + outer_d / 2, -outer_w / 2 + side_block_w / 2, 0])
        cube([side_block_d, side_block_w, outer_h], center=true);
    }

    // The Slot (open at top +Z local)
    translate([0, 0, wall]) // Shift up so bottom wall acts as stop
      cube([slot_d, slot_w, outer_h], center=true);

    // The Window (cut through X)
    window_size = mirror_w - 4; // 2mm lip
    cube([side_block_d + 10, window_size, window_size], center=true);
  }
}

// 1. The "Mount" (Just a cube for now)
difference() {
  color("skyblue") {
    union() {
      translate([0, 0, -5])
        cube([20, 70, 15], center=true);

      // Mirror Mount Tray
      // -45 degree angle to reflect +Z (face id) to +X (outward)
      translate([0, 0, 5])
        rotate([0, -45, 0])
          translate([-2.5, 0, 28]) // Position matching previous verification
            mirror_tray();
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

  // Face ID Clearance Cut
  // Removing more material to ensure clear view
  // 18mm wide (leaving 1mm walls on 20mm mount)
  // Deeper cut to verify clearance
  translate([0, 0, 10]) // Positioned to cut the top wall
    cube([30, 55, 30], center=true);

  // Bottom Cleaner Cut
  // Slices off anything protruding below the base (Base bottom is at Z = -5 - 7.5 = -12.5)
  translate([0, 0, -50 - 12.5])
    cube([100, 100, 100], center=true);
}

// 2. The iPhone 12 Mini Reference
// Orange, transparent
// Rotated -90 on X based on previous preview.scad hints to make it lay flat
%color("orange", 0.5)
  iphone_ref();

// 3. The Mirror (Visual only)
// 50x50mm
// Placed INSIDE the tray slot
%color("silver")
  translate([0, 0, 5])
    rotate([0, -45, 0])
      translate([-2.5, 0, 28 + 2]) // +2 offset to account for tray wall
        cube([1, 50.0, 50.0], center=true);
