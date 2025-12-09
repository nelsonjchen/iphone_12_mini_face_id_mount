# iPhone 12 mini TrueDepth Periscopic Face ID 3D Scanning Mount

A 3D-printed mount to turn an iPhone 12 mini into a dedicated forward-facing Face ID scanner, designed for use with the [Heges 3D Scanner](https://hege.sh/) app.

The iPhone 12 mini is an ideal candidate for this because it can often be found cheaply on the used market. Even units with battery damage, non-OEM screens, or cosmetic wear (like being "chewed on by a dog") are perfect, as long as the Face ID sensor is functional.

## Features

-   **Parametric Design**: Built with OpenSCAD, allowing for easy adjustments.
-   **45° Mirror Angle**: Optimized for scanning objects on a turntable or desk.
-   **Secure Fit**: Specifically designed for the iPhone 12 Mini form factor.
-   **Face ID Clearance**: Includes a dedicated cutout to ensure the TrueDepth camera system has a clear view.

## Visuals

| ISO View | Top View |
| :---: | :---: |
| ![ISO View](preview_iso.png) | ![Top View](preview_top.png) |

| Side View | Front View |
| :---: | :---: |
| ![Side View](preview_side.png) | ![Front View](preview_front.png) |

## Prerequisites

To build and modify this project, you will need:

-   [OpenSCAD](https://openscad.org/) (installed and in your PATH, or adjustable in the Makefile)
-   `make` (standard on macOS/Linux)

## Build Instructions

This project uses a `Makefile` to automate the generation of STL files and preview images.

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd iphone_12_mini_face_id_mount
    ```

2.  **Build everything (STL and PNGs):**
    ```bash
    make
    ```

3.  **Build only the STL for printing:**
    ```bash
    make stl
    ```
    The output file will be `mount.stl`.

4.  **Clean up generated files:**
    ```bash
    make clean
    ```

## File Structure

-   `mount.scad`: The core parametric design file.
-   `Makefile`: Build automation script.
-   `reference/`: Contains the reference STL for the iPhone 12 Mini.
-   `preview_*.png`: Generated preview images of the model.

## Inspirations

-   [Original Concept on Thingiverse](https://www.thingiverse.com/thing:3254381)