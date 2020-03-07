include <backbone.scad>
include <reinforcements.scad>

rails_pitch = 64.5;
rail_d = 3.5;
rail_size = 12;
bottom_holder_y = space_ec_w -1;
holder_h = 5;

//ec_holder_bottom();
ec_washer();

module ec_holder_bottom() {
	bottom_holder_w = rails_pitch + rail_size;
	mount_w = bottom_holder_w+25;
	difference() {
		cube(size=[bottom_holder_w, bottom_holder_y, holder_h], center=true);
		cube(size=[bottom_holder_w-2*rail_size, bottom_holder_y-2*rail_size, holder_h*2], center=true);

		// rails
		translate([rails_pitch/-2, 0, 0]) cube(size=[rail_d, bottom_holder_w-2*rf_xsize, holder_h*2], center=true);
		translate([rails_pitch/2, 0, 0]) cube(size=[rail_d, bottom_holder_w-2*rf_xsize, holder_h*2], center=true);

	}
	difference() {
		union() {
			translate([0, bottom_holder_y/2-rf_xsize/2, holder_h/-2]) cube(size=[mount_w, rf_xsize, holder_h*2], center=true);
			translate([0, bottom_holder_y/-2+rf_xsize/2, holder_h/-2]) cube(size=[mount_w, rf_xsize, holder_h*2], center=true);
		}
		// screw holes
		translate([-3*mh_pitch, bottom_holder_y-1, holder_h*-1.5+rf_zsize/2]) rotate(a=[90, 0, 0]) cylinder(d=mh_inner_dia, h=bottom_holder_y*2, $fn=100);
		translate([3*mh_pitch, bottom_holder_y-1, holder_h*-1.5+rf_zsize/2]) rotate(a=[90, 0, 0]) cylinder(d=mh_inner_dia, h=bottom_holder_y*2, $fn=100);
		// nut traps
		translate([-3*mh_pitch, bottom_holder_y/2-rf_xsize/2, holder_h*-1.5+rf_zsize/2]) rotate(a=[90, 0, 0]) nut_trap(h=bottom_holder_y-rf_xsize);
		translate([3*mh_pitch, bottom_holder_y/2-rf_xsize/2, holder_h*-1.5+rf_zsize/2]) rotate(a=[90, 0, 0]) nut_trap(h=bottom_holder_y-rf_xsize);
	}


}

module ec_washer() {
	difference() {
		cylinder(d=rail_size, h=20, $fn=100);
		translate([0, 0, -1]) cylinder(d=rail_d, h=22, $fn=100);
	}
}