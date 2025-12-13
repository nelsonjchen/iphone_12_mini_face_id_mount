// =============================================================================
// iPhone 12 Mini Face ID 3D Scanning Mount
// =============================================================================

// -----------------------------------------------------------------------------
// 1. Configuration & Parameters
// -----------------------------------------------------------------------------

// -- Mirror Dimensions --
mirror_width = 75.2;
mirror_thickness = 1.0;
mirror_tolerance = 0.15;
mirror_length_tolerance = 0.5;

// -- Calculated Mirror Slot --
mirror_slot_thickness = mirror_thickness + mirror_tolerance;
mirror_slot_length = mirror_width + mirror_length_tolerance;
mirror_slot_width = mirror_width + mirror_tolerance;

// -- Storage Slot Configuration --
mirror_storage_depth = 12; // How deep the storage slot goes
mirror_storage_x_offset = -6; // X position of the vertical storage slot

// -- Mount Base Dimensions --
base_height = 15; // Thickness of the base block
base_top_z = 2.5; // Top surface of the base relative to origin
base_center_z = base_top_z - (base_height / 2);
base_shift_x = -5; // Shift base back for better support of phone
base_plate_thickness = 0.2; // Thickness of the hull plates (virtual)

// -- Mount Dimensions --
mount_corner_radius = 3;
mount_wall_thickness = 2.4;
mirror_housing_width = mirror_width + (2 * mount_wall_thickness);
mount_width = mirror_housing_width;
mount_taper_reduction = 8; // Total width reduction at bottom of base
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
// 2. Helper Modules (Visuals & References)
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

    // Storage Mirror Reference (Ghosted - Storage)
    color("White", 0.15)
      translate([mirror_storage_x_offset, 0, base_top_z + (mirror_width / 2) - mirror_storage_depth])
        cube([mirror_thickness, mirror_width, mirror_width], center=true);
  }
}
// End of visual_references

// -----------------------------------------------------------------------------
// 3. Geometry Modules (Positive Shapes)
// -----------------------------------------------------------------------------

module taper_mask() {
  // Creates a volume that follows the base taper and extends upwards
  // Used to clip the mirror supports so they don't stick out
  mask_len = 50; // Long enough to cover the whole X range

  hull() {
    // Bottom Plate (Narrow)
    translate([base_shift_x, 0, base_top_z - base_height + (base_plate_thickness / 2)])
      rounded_cube([mask_len, mount_width - mount_taper_reduction, base_plate_thickness], r=mount_corner_radius, center=true);

    // Top Plate (Wide)
    translate([base_shift_x, 0, base_top_z - (base_plate_thickness / 2)])
      rounded_cube([mask_len, mount_width, base_plate_thickness], r=mount_corner_radius, center=true);

    // Sky Plate (Wide - extends up)
    translate([base_shift_x, 0, 50])
      rounded_cube([mask_len, mount_width, base_plate_thickness], r=mount_corner_radius, center=true);
  }
}

module mount_base() {
  color("skyblue") {
    union() {
      // Main Base Block
      // Extended back (-X) to support the shifted pillars
      // Tapered hull construction
      hull() {
        // Top plate (full width)
        translate([base_shift_x, 0, base_top_z - (base_plate_thickness / 2)])
          rounded_cube([mount_thickness, mount_width, base_plate_thickness], r=mount_corner_radius, center=true);

        // Bottom plate (tapered width)
        translate([base_shift_x, 0, base_top_z - base_height + (base_plate_thickness / 2)])
          rounded_cube([mount_thickness, mount_width - mount_taper_reduction, base_plate_thickness], r=mount_corner_radius, center=true);
      }

      // Angled Mirror Support (Top side)
      intersection() {
        taper_mask();
        rotate([0, -mount_angle, 0])
          translate([-2, 0, 5])
            cube([6, mirror_housing_width, 7], center=true);
      }

      // Angled Mirror Support (Bottom side - with cutout for lens clearance if needed)
      intersection() {
        taper_mask();
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
}

module top_guide() {
  // Adds a guide/stop for the top of the phone

  spine_width = 10;
  // Calculate left edge of base from its definition in mount_base
  base_min_x = base_shift_x - (mount_thickness / 2);

  // Height Logic
  // Align bottom with base bottom
  base_bottom_z = base_top_z - base_height;
  g_top_z = 1; // Keep top flush with phone surface (Z=0)

  g_height = g_top_z - base_bottom_z;
  g_center_z = g_top_z - (g_height / 2);

  // Only draw if guide extends beyond base
  if (guide_offset > abs(base_min_x)) {
    color("cornflowerblue")
      union() {
        // 1. Central Spine (Flared)
        hull() {
          // Base connection (Wide)
          translate([(base_min_x) / 2, 0, g_center_z])
            rounded_cube([0.1, 1, g_height], r=1, center=true);

          // Guide connection (Standard Width)
          translate([( -guide_offset) / 2, 0, g_center_z])
            rounded_cube([0.1, 1, g_height], r=1, center=true);

          // Main body filler (optional, but ensures hull covers length)
          // Actually, just hulling the two ends (Base X and Guide X) works perfectly 
          // to create a linear taper.

          // Let's be precise:
          // At Base (left side)
          translate([base_min_x + 0.1, 0, g_center_z])
            rounded_cube([0.1, 1, g_height], r=1, center=true);

          // At Guide (right side - connection point)
          translate([-guide_offset + 1, 0, g_center_z])
            rounded_cube([0.1, 1, g_height], r=1, center=true);
        }

        // 2. Vertical Stop
        // Blocks the phone face
        translate([-guide_offset, 0, g_center_z])
          rounded_cube([3, spine_width, g_height], r=0.5, center=true);
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

module mirror_storage_slot() {
  // Vertical slot for storing the mirror
  // Extends from the bottom of the defined depth upwards to infinity (or 50mm)
  // to ensure the top is open/uncapped.
  slot_bottom_z = base_top_z - mirror_storage_depth;
  height = 50;

  translate([mirror_storage_x_offset, 0, slot_bottom_z + (height / 2)])
    cube([mirror_slot_thickness, mirror_slot_width, height], center=true);
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
  patch_offset_from_guide = 10;

  translate([-guide_offset + patch_offset_from_guide, 0, 0])
    cube([18, patch_w, 18], center=true);
}

module bottom_label() {
  // Engraved text on bottom
  // Calculate bottom Z position: Top (2.5) - Height (base_height)
  // Text depth: 0.6mm, so we position it slightly above the bottom surface to engrave
  label_z = base_top_z - base_height - 0.01;

  translate([base_shift_x, 0, label_z]) // Centered on base X
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
    mirror_storage_slot();
    face_id_cutter();
    bottom_label();
  }
}

// -----------------------------------------------------------------------------
// 6. Render
// -----------------------------------------------------------------------------

make_mount();
visual_references();
