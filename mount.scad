include <BOSL/constants.scad>
use <BOSL/masks.scad>
use <BOSL/transforms.scad>
use <BOSL/metric_screws.scad>
use <agentscad/hirth-joint.scad>

// M4 screws

// Bar thickness
bar_height = 7.5;

// Size of each arm's length
arm_length = 200;

// Tolerance
t = 0.2;

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

cm_width = 100;
cm_depth = 50;
cm_height = 5;

module surface_bar()
{
    union() {
	difference() {
	    cube([bar_width, bar_depth, bar_height]);
	    up(10) right(bar_hole_offset) back(bar_depth/2) metric_bolt(size=4, l=20, pitch=0);
	    up(10) right(bar_width - bar_hole_offset) back(bar_depth/2) metric_bolt(size=4, l=20, pitch=0);
	    right(bar_width/2) back(bar_depth/2) metric_nut(size=4, hole=false);
	    right(bar_width/2) back(bar_depth/2) mirror([0, 0, 1]) metric_bolt(size=4, l=20, pitch=0);
	    up(bar_height) mirror([0,0,1]) right(bar_hole_offset) back(bar_depth/2) metric_nut(size=4, hole=false);
	    up(bar_height) mirror([0,0,1]) right(bar_width - bar_hole_offset) back(bar_depth/2) metric_nut(size=4, hole=false);
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
	    mirror([0, 0, 1]) metric_bolt(size=6, l=bc_height*0.85, pitch=0);
	    mirror([0, 0, 1]) fillet_cylinder_mask(r=hradius, fillet=10);
	    up(bc_height*0.35) cube([hradius, hradius*2, bc_height*0.85], center=true);
	    up(in_radius) left(hradius) rotate([0, 90, 0]) metric_nut(size=4, hole=false);
	    up(in_radius) right(hradius) rotate([0, 90, 0]) #metric_bolt(size=4, l=hradius*2, pitch=0);
	}
	right(hradius/2) up(in_radius) rotate([0, 270, 0]) hirthJointSinus(in_radius, hteeth, hheight);
	left(hradius/2) up(in_radius) rotate([0, 90, 0]) hirthJointSinus(in_radius, hteeth, hheight);
    }
}

module arm_holes(w)
{
    union() {
	rotate([45, 0, 0])cube(w, center=true);
	back(w/2 + w)rotate([45, 0, 0])cube(w, center=true);
	back(w + 2*w)rotate([45, 0, 0])cube(w, center=true);
	forward(w/2 + w)rotate([45, 0, 0])cube(w, center=true);
	forward(w + 2*w)rotate([45, 0, 0])cube(w, center=true);
    }
}

module arm()
{
    w = hradius - hheight*4;
    difference() {
	union() {
	    difference() {
		cube([w, arm_length, in_radius*2], center=true);
		back(arm_length/2) down(in_radius) fillet_mask_x(l=w, r=in_radius);
		back(arm_length/2) up(in_radius) fillet_mask_x(l=w, r=in_radius);
		forward(arm_length/2) down(in_radius) fillet_mask_x(l=w, r=in_radius);
		forward(arm_length/2) up(in_radius) fillet_mask_x(l=w, r=in_radius);
		arm_holes(w);
	    }
	    right(w/2-t) forward(arm_length/2 - in_radius) rotate([0,90,0]) hirthJointSinus(in_radius, hteeth, hheight);
	    left(w/2-t) forward(arm_length/2 - in_radius) rotate([0,270,0]) hirthJointSinus(in_radius, hteeth, hheight);
	    right(w/2-t) back(arm_length/2 - in_radius) rotate([0,90,0]) hirthJointSinus(in_radius, hteeth, hheight);
	    left(w/2-t) back(arm_length/2 - in_radius) rotate([0,270,0]) hirthJointSinus(in_radius, hteeth, hheight);
	}
	back(arm_length/2 - in_radius) right(w/2) rotate([0, 90, 0]) #metric_bolt(size=4, l=w*2, pitch=0);
	forward(arm_length/2 - in_radius) right(w/2) rotate([0, 90, 0]) #metric_bolt(size=4, l=w*2, pitch=0);
    }
}

module ceiling_mount()
{
    bolt_offset = 10;
    union() {
	difference() {
	    cube([cm_width, cm_depth, cm_height], center=true);
	    up(cm_height) left(cm_width/2 - bolt_offset) metric_bolt(size=4, l=cm_height*2, pitch=0);
	    up(cm_height) right(cm_width/2 - bolt_offset) metric_bolt(size=4, l=cm_height*2, pitch=0);
	    up(cm_height) metric_bolt(size=4, l=cm_height*2, pitch=0);
	    down(cm_height/2) metric_nut(size=4, hole=false);
	}
	up(cm_height/2) hirthJointSinus(hradius, hteeth, hheight);
    }
}

//back(100) ceiling_mount();
left(100) arm();
//right(100) surface_bar();
//bar_connector();
