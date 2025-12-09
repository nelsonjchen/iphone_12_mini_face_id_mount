// -----------------------------------------------------------------------------
// Parameters
// -----------------------------------------------------------------------------

// Mirror Dimensions
mirror_w = 70.0;
mirror_th = 1; // Slightly thicker for slot ease
tolerance = 0.5;
slot_w = mirror_th + tolerance;
slot_height = 75;

// Fit Dimensions
phone_fit_tolerance = 0.5;

// Mount Geometry
mount_width = 74;
mount_thickness = 20;
mirror_slot_width = mirror_w + tolerance;
mount_angle = 45;

// Cutout Dimensions
face_id_cut_w = 30;
face_id_cut_h = 30;
face_id_cut_d = 60;

// -----------------------------------------------------------------------------
// Modules
// -----------------------------------------------------------------------------

module iphone_ref() {
  rotate([0, 90, 0])
    import("reference/iphone-12-mini.stl");
}

module mount_base() {
  color("skyblue") {
    union() {
      // Base - Widened for 70mm mirror
      // Extended back (-X) to support the shifted pillars
      translate([0, 0, -5])
        cube([mount_thickness, mount_width, 14], center=true);

      // Angled support for the mirror, pushing up
      rotate([0, -mount_angle, 0])
        translate([-2, 0, 0])
          cube([6, mount_width, 15], center=true);
      // Angled support for the mirror, pushing down
      rotate([0, -mount_angle, 0])
        translate([0, 0, 0])
          cube([4, mount_width, 5], center=true);
    }
  }
}

module mirror_cutout() {
  // Calculate offsets to place the bottom corner at [0,0,0]
  // Rotated -45 deg: z_min is at local x=-w/2, z=-h/2
  z_offset = (slot_height + slot_w) * sin(mount_angle) / 2;
  x_offset = (slot_height - slot_w) * sin(mount_angle) / 2;

  translate([-x_offset, 0, z_offset])
    rotate([0, -mount_angle, 0])
      cube([slot_w, mirror_slot_width, slot_height], center=true);
}

module profile_cutter() {
  // Projects the phone's X-axis profile and extrudes it to create a cutter
  // Added offset for tolerance
  translate([0, 0, 0])
    rotate([0, -90, 0]) // Rotate back to X axis alignment
      linear_extrude(height=60, center=true)
        offset(delta=phone_fit_tolerance)
          projection(cut=false)
            rotate([0, 90, 0]) // Rotate to Z for projection (captures X profile)
              iphone_ref();
}

module face_id_cutter() {
  // Removing more material to ensure clear view
  // 18mm wide (leaving 1mm walls on 20mm mount)
  // Deeper cut to verify clearance
  translate([0, 0, 10]) // Positioned to cut the top wall
    cube([face_id_cut_w, face_id_cut_d, face_id_cut_h], center=true);
}

module side_trimmer() {
  // Tapers the ends of the mount (Y-axis) to reduce bulk without cutting the mirror slot.
  // "Opposite" taper: Wide at the TOP, Narrow at the BOTTOM.
  // This preserves the mirror slot wall at the top.

  safe_y = 37; // Pivot at the outer edge (37mm = 74mm width)
  angle = 15;

  // Pivot Z: effectively the point where the taper "starts" moving inwards as we go down.
  // If we pivot at a high point (e.g. z=40), everything below gets cut.
  // If we pivot at z=0, bottom gets cut, top is safe.
  pivot_z = 0;

  // Positive Y Taper (Top side in 2D view)
  // We want to cut the bottom (negative Z relative to pivot? No, absolute Z).
  // Rotate -15 deg: 
  //   Top (+Z) moves +Y (Away -> Safe)
  //   Bottom (-Z) moves -Y (In -> Cut)
  translate([0, safe_y, pivot_z])
    rotate([-angle, 0, 0])
      translate([0, 50, 0])
        cube([100, 100, 200], center=true);

  // Negative Y Taper (Bottom side in 2D view)
  // Rotate +15 deg:
  //   Top (+Z) moves -Y (Away -> Safe)
  //   Bottom (-Z) moves +Y (In -> Cut)
  translate([0, -safe_y, pivot_z])
    rotate([angle, 0, 0])
      translate([0, -50, 0])
        cube([100, 100, 200], center=true);
}

// -----------------------------------------------------------------------------
// Main Assembly
// -----------------------------------------------------------------------------

difference() {
  mount_base();

  mirror_cutout();
  profile_cutter();
  face_id_cutter();
  side_trimmer();
  bottom_label();
}

module bottom_label() {
  // Engrave text on the bottom face
  // Bottom face is at Z = -12 (center -5, half-height 7)
  // Text runs along the Y axis
  translate([0, 0, -12.01]) // Slight offset to ensure clean cut surface
    rotate([0, 0, 90])
      mirror([1, 0, 0])
        linear_extrude(height=0.6) {
          translate([0, 3.5, 0])
            text("iPhone 12 Mini", size=5, valign="center", halign="center");
          translate([0, -3.5, 0])
            text("Face ID 3D Scan Mount", size=4.5, valign="center", halign="center");
        }
}

// -----------------------------------------------------------------------------
// Visual References (Not part of the physical model)
// -----------------------------------------------------------------------------

// iPhone 12 Mini Reference
// Orange, transparent
// Rotated -90 on X based on previous preview.scad hints to make it lay flat
%color("orange", 0.5)
  iphone_ref();

// Mirror (Visual only)
// Placed IN the slot position to visualize
%color("silver") {
  z_offset_vis = (mirror_w + mirror_th) * sin(mount_angle) / 2;
  // Note: This visual placement logic might need tweaking if the slot logic changes perfectly,
  // but relying on the same math as the cutout usually works.
  // The original generic offset was:
  // translate([-(70 - 1) * sin(45) / 2, 0, (70 + 1) * sin(45) / 2])

  // Adapted to variables:
  translate([-(mirror_w - mirror_th) * sin(mount_angle) / 2, 0, (mirror_w + mirror_th) * sin(mount_angle) / 2])
    rotate([0, -mount_angle, 0])
      cube([mirror_th, mirror_w, mirror_w], center=true);
}
