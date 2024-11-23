include <BOSL/constants.scad>
use <BOSL/masks.scad>
use <BOSL/transforms.scad>
use <BOSL/metric_screws.scad>
use <agentscad/hirth-joint.scad>

// M4 screws

// Bar thickness
bar_height = 7.5;

module __Customizer_Limit__() {}
// Minimum angle
$fa = 0.1;
// Minimum size
$fs = 0.1;
$fn=100;

bar_width = 180;
bar_depth = 43;
bar_hole_radius = 2.5;
bar_hole_offset = 20;

hteeth=21;
hradius = bar_depth/2;
hheight = 1.2;
in_radius = 0.85*hradius;

module bar()
{
    union() {
	difference() {
	    cube([bar_width, bar_depth, bar_height]);
	    right(bar_hole_offset) back(bar_depth/2) cylinder(bar_height, r = bar_hole_radius);
	    right(bar_width - bar_hole_offset) back(bar_depth/2) cylinder(bar_height, r = bar_hole_radius);
	    right(bar_width/2) back(bar_depth/2) metric_nut(size=4, hole=false);
	    right(bar_width/2) back(bar_depth/2) mirror([0, 0, 1]) metric_bolt(size=4, l=20, pitch=0);
	}
	right(bar_width/2) back(bar_depth/2) up(bar_height) hirthJointSinus(hradius, hteeth, hheight);
    }
}

module bar_connector()
{
    bc_height = 50;
    union() {
	difference() {
	    /*
	     * the reason we don't directly use hirthJointSinus with bc_height
	     * is because of the hole: we need it to hold a screw
	     */
	    union() {
		up(bc_height) hirthJointSinus(hradius, hteeth, hheight);
		cylinder(h = bc_height, r = hradius);
	    }
	    mirror([0, 0, 1]) metric_bolt(size=4, l=bc_height*2, pitch=0);
	    mirror([0, 0, 1]) metric_bolt(size=6, l=bc_height*0.75, pitch=0);
	    mirror([0, 0, 1]) fillet_cylinder_mask(r=hradius, fillet=10);
	    up(bc_height*0.35) cube([hradius, hradius*2, bc_height*0.75], center=true);
	    up(in_radius) left(hradius) rotate([0, 90, 0]) metric_nut(size=4, hole=false);
	    up(in_radius) right(hradius) rotate([0, 90, 0]) #metric_bolt(size=4, l=hradius*2, pitch=0);
	}
	right(hradius/2) up(in_radius) rotate([0, 270, 0]) hirthJointSinus(in_radius, hteeth, hheight);
    }
}

//bar();
bar_connector();
