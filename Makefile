OPENSCAD = /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD

all: stl previews

stl: mount.stl

previews: preview_usage_ortho.png preview_usage_side.png preview_storage_ortho.png preview_storage_side.png

clean:
	rm -f mount.stl preview_*.png

# -- Usage Previews (Phone + Usage Mirror) --
preview_usage_ortho.png: mount.scad
	$(OPENSCAD) -o preview_usage_ortho.png \
		-D 'show_phone_ref=true' -D 'show_usage_mirror=true' -D 'show_storage_mirror=false' \
		--autocenter --viewall --imgsize=1024,768 --projection=ortho \
		--camera=0,0,0,63.435,0,225,100 mount.scad

preview_usage_side.png: mount.scad
	$(OPENSCAD) -o preview_usage_side.png \
		-D 'show_phone_ref=true' -D 'show_usage_mirror=true' -D 'show_storage_mirror=false' \
		--autocenter --viewall --imgsize=800,600 --view axes \
		--camera=0,200,0,0,0,0 mount.scad

# -- Storage Previews (No Phone + Storage Mirror) --
preview_storage_ortho.png: mount.scad
	$(OPENSCAD) -o preview_storage_ortho.png \
		-D 'show_phone_ref=false' -D 'show_usage_mirror=false' -D 'show_storage_mirror=true' \
		--autocenter --viewall --imgsize=1024,768 --projection=ortho \
		--camera=0,0,0,63.435,0,225,100 mount.scad

preview_storage_side.png: mount.scad
	$(OPENSCAD) -o preview_storage_side.png \
		-D 'show_phone_ref=false' -D 'show_usage_mirror=false' -D 'show_storage_mirror=true' \
		--autocenter --viewall --imgsize=800,600 --view axes \
		--camera=0,200,0,0,0,0 mount.scad


clean:
	rm -f mount.stl preview_*.png
