include <BOSL/constants.scad>
use <BOSL/masks.scad>
use <BOSL/transforms.scad>
use <BOSL/metric_screws.scad>
use <agentscad/hirth-joint.scad>

// M4 screws

// which part
part = 0; // [0: "Sleeve", 1: "Ceiling mount", 2: "Arm", 3: "Bar Connector"]

// Wall thickness
walls = 2;

// Bar thickness
bar_height = 25;

// Size of each arm's length
arm_length = 200;

// Tolerance
t = 0.2;

// XXX manual adjustment when the bar is too thick and the cylinder on the bar connector needs to be wider
bar_connector_extra_radius = 2.5;

module __Customizer_Limit__() {}
// Minimum angle
$fa = 0.5;
// Minimum size
$fs = 0.5;

bar_width = 180;
bar_depth = 43;
bar_hole_radius = 2.5;
bar_hole_offset = 20;

hteeth=40;
hradius = bar_depth/2;
hheight = 1.2;
in_radius = 0.85*hradius;

cm_width = 100;
cm_depth = 50;
/* thickness */
cm_height = 10;

assert((hradius*2 > bar_height + 14), "Bar height (thickness) should be smaller. Or increase hradius");

/*
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
*/

module bar_connector()
{
    /* kludge radius */
    kradius = hradius + bar_connector_extra_radius;
    bc_height = 50;
    hole_w = bar_height + hheight*4;
    /* leave a little room after the hirthJoint ends */
    hole_h = in_radius * 2 + 2;
    union() {
	difference() {
	    /*
	     * the reason we don't directly use hirthJointSinus with bc_height
	     * is because of the hole: we need it to hold a screw
	     */
	    union() {
		up(bc_height) hirthJointSinus(hradius, hteeth, hheight);
		cylinder(h = bc_height, r = kradius);
	    }
	    mirror([0, 0, 1]) metric_bolt(size=4, l=bc_height*2, pitch=0);
	    //mirror([0, 0, 1]) metric_bolt(size=6, l=bc_height*0.85, pitch=0);
	    /* nut hole so we can have the screw coming from the sleeve */
	    up(hole_h) metric_nut(size=4, hole=false);
	    mirror([0, 0, 1]) fillet_cylinder_mask(r=kradius, fillet=10);
	    up(hole_h/2) cube([hole_w, kradius*2, hole_h], center=true);
	    up(in_radius) left(kradius) rotate([0, 90, 0]) metric_nut(size=4, hole=false);
	    up(in_radius) right(kradius) rotate([0, 90, 0]) metric_bolt(size=4, l=kradius*2, pitch=0);
	}
	right(hole_w/2) up(in_radius) rotate([0, 270, 0]) hirthJointSinus(in_radius, hteeth, hheight);
	left(hole_w/2) up(in_radius) rotate([0, 90, 0]) hirthJointSinus(in_radius, hteeth, hheight);
    }
}

module arm_holes(w)
{
    r = 0.45 * w;
    off = r * 2 * 1.1;
    rotate([0, 90, 0]) union() {
	#cylinder(h=w, r=r, center=true);
	back(off) cylinder(h=w, r=r, center=true);
	back(off * 2) cylinder(h=w, r=r, center=true);
	forward(off) cylinder(h=w, r=r, center=true);
	forward(off * 2) cylinder(h=w, r=r, center=true);
    }
}

module arm()
{
    //w = hradius - hheight*4;
    w = bar_height;
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
	back(arm_length/2 - in_radius) right(w/2) rotate([0, 90, 0]) metric_bolt(size=4, l=w*2, pitch=0);
	forward(arm_length/2 - in_radius) right(w/2) rotate([0, 90, 0]) metric_bolt(size=4, l=w*2, pitch=0);
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

s3_w1 = 188.122;
s3_w2 = 181.570;
s3_h = 9.5;
s3_d = 267;
s3_scr_off = 15.5;
s3_scr_bottom_off = 18;
s3_w_w = 24;
s3_w_off = 4;
s3_ports_w = 150;
s3_ports_d = 7;
s3_cutoff = 30;
/* we don't want to cover the volume buttons */
s3_vol_offset = 170;
module surface3()
{
    diff = s3_w1 - s3_w2;
    linear_extrude(height=s3_d) polygon([[0,0], [188.122, 0], [188.122 - diff/2, 9.5], [diff/2, 9.5]]);
}

module surface3_sleeve()
{
    walls2 = walls*2;
    sleeve_w = s3_w1 + walls2*2;
    sleeve_d = s3_h + walls2*2;
    sleeve_h = s3_vol_offset + walls2;
    win_hole_h = s3_scr_bottom_off - s3_w_off;
    difference() {
	union() {
	    cube([sleeve_w, sleeve_d, sleeve_h]);
	    right(sleeve_w/2) up(s3_d/2 + walls2) back(sleeve_d) rotate([270,0,0]) hirthJointSinus(hradius, hteeth, hheight);
	}
	right(walls2) back(walls2) up(walls2) surface3();
	right(sleeve_w/2) back(sleeve_d/2) cube([s3_ports_w, s3_ports_d, walls2*2], center=true);
	right(sleeve_w/2) up(s3_d/2 + s3_scr_bottom_off) cube([s3_w1 - s3_scr_off*2, walls2*2, s3_d], center=true);
	right(sleeve_w/2) up(win_hole_h/2 + s3_w_off) cube([s3_w_w, walls2*2, win_hole_h], center=true);
	right(sleeve_w/2) up(sleeve_h/2 + walls2 + s3_cutoff) cube([s3_w1, walls2*2, sleeve_h - s3_cutoff], center=true);
	right(sleeve_w/2) up(s3_d/2 + walls2) rotate([90, 0, 0]) metric_bolt(size=4, l=sleeve_h, pitch=0);
    }
}

if (part == 0) surface3_sleeve();
if (part == 1) ceiling_mount();
if (part == 2) arm();
if (part == 3) bar_connector();
//if (part == 99)surface_bar();

