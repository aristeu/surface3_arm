all: sleeve.stl ceiling_mount.stl arm.stl bar_connector.stl

sleeve.stl: mount.scad
	openscad -o $@ -D "part=0" mount.scad >/dev/null 2>&1
ceiling_mount.stl: mount.scad
	openscad -o $@ -D "part=1" mount.scad >/dev/null 2>&1
arm.stl: mount.scad
	openscad -o $@ -D "part=2" mount.scad >/dev/null 2>&1
bar_connector.stl: mount.scad
	openscad -o $@ -D "part=3" mount.scad >/dev/null 2>&1

