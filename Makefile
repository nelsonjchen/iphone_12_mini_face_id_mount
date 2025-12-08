OPENSCAD = /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD

all: stl previews

stl: mount.stl

previews: preview_iso.png preview_top.png preview_side.png preview_front.png

mount.stl: mount.scad
	$(OPENSCAD) -o mount.stl mount.scad

preview_iso.png: mount.scad
	$(OPENSCAD) -o preview_iso.png --autocenter --viewall --imgsize=800,600 --view axes \
		--camera=0,0,0,55,0,25 mount.scad

preview_top.png: mount.scad
	$(OPENSCAD) -o preview_top.png --autocenter --viewall --imgsize=800,600 --view axes \
		--camera=0,0,200,0,0,0 mount.scad

preview_side.png: mount.scad
	$(OPENSCAD) -o preview_side.png --autocenter --viewall --imgsize=800,600 --view axes \
		--camera=0,200,0,0,0,0 mount.scad

preview_front.png: mount.scad
	$(OPENSCAD) -o preview_front.png --autocenter --viewall --imgsize=800,600 --view axes \
		--camera=200,0,0,0,0,0 mount.scad

clean:
	rm -f mount.stl preview_*.png
