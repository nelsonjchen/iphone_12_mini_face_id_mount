OPENSCAD = /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD

all: stl previews

stl: mount.stl

previews: preview_top.png preview_side.png preview_front.png preview_bottom.png preview_ortho.png

mount.stl: mount.scad
	$(OPENSCAD) -o mount.stl mount.scad

preview_top.png: mount.scad
	$(OPENSCAD) -o preview_top.png --autocenter --viewall --imgsize=800,600 --view axes \
		--camera=0,0,200,0,0,0 mount.scad

preview_side.png: mount.scad
	$(OPENSCAD) -o preview_side.png --autocenter --viewall --imgsize=800,600 --view axes \
		--camera=0,200,0,0,0,0 mount.scad

preview_front.png: mount.scad
	$(OPENSCAD) -o preview_front.png --autocenter --viewall --imgsize=800,600 --view axes \
		--camera=200,0,0,0,0,0 mount.scad

preview_bottom.png: mount.scad
	$(OPENSCAD) -o preview_bottom.png --autocenter --viewall --imgsize=800,600 --view axes \
		--camera=0,0,-200,0,0,0 mount.scad

preview_ortho.png: mount.scad
	$(OPENSCAD) -o preview_ortho.png --autocenter --viewall --imgsize=1024,768 --projection=ortho \
		--camera=0,0,0,63.435,0,45,100 mount.scad

preview_ortho2.png: mount.scad
	$(OPENSCAD) -o preview_ortho2.png --autocenter --viewall --imgsize=1024,768 --projection=ortho \
		--camera=0,0,0,63.435,0,225,100 mount.scad

clean:
	rm -f mount.stl preview_*.png
