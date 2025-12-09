// =============================================================================
// iPhone 12 Mini Face ID 3D Scanning Mount
// =============================================================================

// -----------------------------------------------------------------------------
// 1. Configuration & Parameters
// -----------------------------------------------------------------------------

// -- Mirror Dimensions --
mirror_width = 70.2;
mirror_thickness = 1.0;
mirror_tolerance = 0.15;
mirror_length_tolerance = 0.5;

// Calculated Mirror Slot
mirror_slot_thickness = mirror_thickness + mirror_tolerance;
mirror_slot_length = mirror_width + mirror_length_tolerance;
mirror_slot_width = mirror_width + mirror_tolerance;

// -- Mount Base Dimensions --
base_height = 15; // Thickness of the base block (was 10, increased for stability)
base_top_z = 2.5; // Top surface of the base relative to origin
base_center_z = base_top_z - (base_height / 2);

// -- Mount Dimensions --
mount_corner_radius = 3;
mount_wall_thickness = 2.4;
// mount_width = 80; // Old width
mirror_housing_width = mirror_width + (2 * mount_wall_thickness);
mount_width = mirror_housing_width; // Matched to housing
// Tapers the sides to reduce bulk
// safe_y = max(mount_width, mirror_housing_width) / 2; // Was used for calculation
mount_thickness = 20;
mount_angle = 45;

// -- Phone Fit & Alignment --
phone_fit_tolerance = 0.3;
guide_offset = 22; // Distance to the top of the phone guide
iphone_top_ref_x = -14; // Natural top of phone in reference STL at X = -14

// -- Cutouts --
face_id_cut_w = 30;
face_id_cut_h = 30;
face_id_cut_d = 60;

// -----------------------------------------------------------------------------
// 3. Helper Modules (Visuals & References)
// -----------------------------------------------------------------------------

module rounded_cube(size, r, center = true) {
  // Beveled/Rounded Box (Z-axis edges rounded)
  width = size[0];
  depth = size[1];
  height = size[2];

  tx = center ? -width / 2 : 0;
  ty = center ? -depth / 2 : 0;
  tz = center ? -height / 2 : 0;

  translate([tx, ty, tz]) {
    hull() {
      translate([r, r, 0]) cylinder(r=r, h=height, $fn=32);
      translate([width - r, r, 0]) cylinder(r=r, h=height, $fn=32);
      translate([width - r, depth - r, 0]) cylinder(r=r, h=height, $fn=32);
      translate([r, depth - r, 0]) cylinder(r=r, h=height, $fn=32);
    }
  }
}

module iphone_ref() {
  // Shifts the reference STL so the top of the phone matches guide_offset
  shift_x = -iphone_top_ref_x - guide_offset;

  translate([shift_x, 0, 0])
    rotate([0, 90, 0])
      import("reference/iphone-12-mini.stl");
}

module visual_references() {
  // iPhone 12 Mini Reference (Orange, transparent)
  %color("orange", 0.5)
    iphone_ref();

  // Mirror Reference (Silver, visual only)
  %color("silver") {
    // Calculate visual position (same logic as cutout)
    z_offset_vis = (mirror_width + mirror_thickness) * sin(mount_angle) / 2;
    x_offset_vis = -(mirror_width - mirror_thickness) * sin(mount_angle) / 2;

    translate([x_offset_vis, 0, z_offset_vis])
      rotate([0, -mount_angle, 0])
        cube([mirror_thickness, mirror_width, mirror_width], center=true);
  }
}

// -----------------------------------------------------------------------------
// 3. Geometry Modules (Positive Shapes)
// -----------------------------------------------------------------------------

module mount_base() {
  color("skyblue") {
    union() {
      // Main Base Block
      // Extended back (-X) to support the shifted pillars
      // Tapered hull construction
      hull() {
        // Top plate (full width)
        translate([-5, 0, base_top_z - 0.1])
          rounded_cube([mount_thickness, mount_width, 0.2], r=mount_corner_radius, center=true);

        // Bottom plate (tapered width)
        // Taper 15 degrees over 15mm height => ~4mm per side => 8mm total reduction
        translate([-5, 0, base_top_z - base_height + 0.1])
          rounded_cube([mount_thickness, mount_width - 8, 0.2], r=mount_corner_radius, center=true);
      }

      // Angled Mirror Support (Top side)
      rotate([0, -mount_angle, 0])
        translate([-2, 0, 5])
          cube([6, mirror_housing_width, 7], center=true);

      // Angled Mirror Support (Bottom side - with cutout for lens clearance if needed)
      difference() {
        rotate([0, -mount_angle, 0])
          translate([0, 0, 4])
            cube([5, mirror_housing_width, 9], center=true);
        rotate([0, -mount_angle, 0])
          translate([0, 0, 5])
            cube([5 + 1, mirror_housing_width - 8, 7 + 1], center=true);
      }
    }
  }
}

module top_guide() {
  // Adds a guide/stop for the top of the phone

  spine_width = 10;
  base_Left_X = -15; // Corresponds to mount_base geometry

  // Height Logic
  // Align bottom with base bottom
  base_bottom_z = base_top_z - base_height;
  g_top_z = 1; // Keep top flush with phone surface (Z=0)

  g_height = g_top_z - base_bottom_z;
  g_center_z = g_top_z - (g_height / 2);

  // Only draw if guide extends beyond base
  if (guide_offset > abs(base_Left_X)) {
    color("cornflowerblue")
      union() {
        // 1. Central Spine
        // Extends from base edge to guide_offset
        translate([(base_Left_X - guide_offset) / 2, 0, g_center_z])
          cube([guide_offset - abs(base_Left_X) + 0.1, spine_width, g_height], center=true);

        // 2. Vertical Stop
        // Blocks the phone face
        translate([-guide_offset, 0, g_center_z])
          cube([3, spine_width, g_height], center=true);
      }
  }
}

// -----------------------------------------------------------------------------
// 4. Cutter Modules (Subtractive Shapes)
// -----------------------------------------------------------------------------

module mirror_cutout() {
  // Slot for the mirror
  z_offset = (mirror_slot_length + mirror_slot_thickness) * sin(mount_angle) / 2;
  x_offset = (mirror_slot_length - mirror_slot_thickness) * sin(mount_angle) / 2;

  translate([-x_offset, 0, z_offset])
    rotate([0, -mount_angle, 0])
      cube([mirror_slot_thickness, mirror_slot_width, mirror_slot_length], center=true);
}

module profile_cutter() {
  // Projects the phone's X-axis profile and extrudes it to create a cutter
  // Used to shape the bed of the mount to the phone's curve
  translate([0, 0, 0])
    rotate([0, -90, 0])
      linear_extrude(height=60, center=true)
        offset(delta=phone_fit_tolerance)
          projection(cut=false)
            rotate([0, 90, 0])
              iphone_ref();
}

module iphone_tolerance_cutter() {
  // Creates a slightly larger scale of the phone for clearance comparisons

  // Measured Dimensions of Reference STL
  p_len = 131.5;
  p_wid = 65.2;
  p_thk = 9.4;

  tol = phone_fit_tolerance;

  // Scale factors
  s_len = (p_len + 2 * tol) / p_len;
  s_wid = (p_wid + 2 * tol) / p_wid;
  s_thk = (p_thk + 2 * tol) / p_thk;

  // Center of the STL geometry (Local coords)
  c_x = 4.7;
  c_y = 0;
  c_z = 51.75;

  shift_x = -iphone_top_ref_x - guide_offset;

  translate([shift_x, 0, 0])
    rotate([0, 90, 0])
      translate([c_x, c_y, c_z])
        scale([s_thk, s_wid, s_len])
          translate([-c_x, -c_y, -c_z])
            import("reference/iphone-12-mini.stl");
}

module face_id_cutter() {
  // Clears view for Face ID sensors
  // +1 for z-fighting
  translate([0, 0, 10])
    cube([face_id_cut_w + 1, face_id_cut_d, face_id_cut_h], center=true);
}

module sensor_patch() {
  // Clears material near the notch area
  patch_w = 40;
  translate([-guide_offset + 5, 0, 0])
    cube([8, patch_w, 18], center=true);
}

module bottom_label() {
  // Engraved text on bottom
  // Calculate bottom Z position: Top (2.5) - Height (base_height)
  // Text depth: 0.6mm, so we position it slightly above the bottom surface to engrave
  label_z = base_top_z - base_height - 0.01;

  translate([-5, 0, label_z])
    rotate([0, 0, 90])
      mirror([1, 0, 0])
        linear_extrude(height=0.6) {
          translate([0, 6, 0])
            text("iPhone 12 mini", size=5, valign="center", halign="center");
          translate([0, 0, 0])
            text("Face ID 3D Scan Mount", size=4.5, valign="center", halign="center");
          translate([0, -6, 0])
            text(str("P Tol: ", phone_fit_tolerance, "mm | M Tol: ", mirror_tolerance, "mm"), size=3.5, valign="center", halign="center");
        }
}

// -----------------------------------------------------------------------------
// 5. Main Assembly
// -----------------------------------------------------------------------------

module make_mount() {
  difference() {
    union() {
      // 1. Base shape cut by phone profile
      difference() {
        mount_base();
        profile_cutter();
      }

      // 2. Top guide cut by scaled phone
      difference() {
        top_guide();
        iphone_tolerance_cutter();
        sensor_patch();
      }
    }

    // 3. Global Subtractions
    mirror_cutout();
    face_id_cutter();
    bottom_label();
  }
}

// -----------------------------------------------------------------------------
// 6. Render
// -----------------------------------------------------------------------------

make_mount();
visual_references();
