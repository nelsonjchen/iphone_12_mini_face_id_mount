// -----------------------------------------------------------------------------
// Parameters
// -----------------------------------------------------------------------------

// Mirror Dimensions
// Mirror Dimensions
mirror_width = 75.2;
mirror_thickness = 1; // Slightly thicker for slot ease

mirror_tolerance = 0.25;
mirror_length_tolerance = 0.5;

mirror_slot_thickness = mirror_thickness + mirror_tolerance;
mirror_slot_length = mirror_width + mirror_length_tolerance;

// Fit Dimensions
phone_fit_tolerance = 0.25;
guide_offset = 21.5; // Distance to the top of the phone guide

// Mount Geometry
mount_width = 80;
mount_thickness = 20;
mirror_slot_width = mirror_width + mirror_tolerance;
mount_angle = 45;

// Cutout Dimensions
face_id_cut_w = 30;
face_id_cut_h = 30;
face_id_cut_d = 60;

// -----------------------------------------------------------------------------
// Modules
// -----------------------------------------------------------------------------

module iphone_ref() {
  // Natural top of phone is at X = -14
  // We want top of phone to be at X = -guide_offset
  // Shift = (-guide_offset) - (-14) = 14 - guide_offset
  shift_x = 14 - guide_offset;

  translate([shift_x, 0, 0])
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
      difference() {
        rotate([0, -mount_angle, 0])
          translate([0, 0, 0])
            cube([5, mount_width, 15], center=true);
        rotate([0, -mount_angle, 0])
          translate([0, 0, 0])
            cube([5, mount_width - 8, 15], center=true);
      }
    }
  }
}

module top_guide() {
  // Adds a guide/stop for the top of the phone
  // Arms extend from the mount base to the stopper (Negative X direction)

  arm_w = 6;
  base_Left_X = -mount_thickness / 2; // -10

  // guide_offset is distance from center. We want to go to -guide_offset.
  // Only draw if sticking out further than the base (offset > 10)
  if (guide_offset > abs(base_Left_X)) {
    color("cornflowerblue")
      union() {
        // Arms connecting base to guide
        // Spans from -10 to -guide_offset
        for (ym = [-1, 1]) {
          translate([(base_Left_X - guide_offset) / 2, ym * (mount_width / 2 - arm_w / 2), -5])
            cube([guide_offset - abs(base_Left_X) + 0.1, arm_w, 14], center=true);
        }

        // The stopper bar itself at the end
        // Placed to ensure the inner face is at -guide_offset
        translate([-guide_offset - 1.5, 0, -5])
          cube([3, mount_width, 14], center=true);
      }
  }
}

module mirror_cutout() {
  // Calculate offsets to place the bottom corner at [0,0,0]
  // Rotated -45 deg: z_min is at local x=-w/2, z=-h/2
  z_offset = (mirror_slot_length + mirror_slot_thickness) * sin(mount_angle) / 2;
  x_offset = (mirror_slot_length - mirror_slot_thickness) * sin(mount_angle) / 2;

  translate([-x_offset, 0, z_offset])
    rotate([0, -mount_angle, 0])
      cube([mirror_slot_thickness, mirror_slot_width, mirror_slot_length], center=true);
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

  safe_y = 40; // Pivot at the outer edge (40mm = 80mm width)
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
  union() {
    difference() {
      mount_base();
      profile_cutter();
    }
    top_guide();
  }

  mirror_cutout();
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
            text("iPhone 12 mini", size=5, valign="center", halign="center");
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
  z_offset_vis = (mirror_width + mirror_thickness) * sin(mount_angle) / 2;
  // Note: This visual placement logic might need tweaking if the slot logic changes perfectly,
  // but relying on the same math as the cutout usually works.
  // The original generic offset was:
  // translate([-(70 - 1) * sin(45) / 2, 0, (70 + 1) * sin(45) / 2])

  // Adapted to variables:
  translate([-(mirror_width - mirror_thickness) * sin(mount_angle) / 2, 0, (mirror_width + mirror_thickness) * sin(mount_angle) / 2])
    rotate([0, -mount_angle, 0])
      cube([mirror_thickness, mirror_width, mirror_width], center=true);
}
