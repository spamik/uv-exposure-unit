include <reinforcements.scad>


z_size = top_cover_z-top_cover_plate_z;
lid_cover_zsize1 = 6;
lid_cover_zsize2 = 2;
lid_switch_x = 20;
lid_switch_y = 45;
tpe_press_base_z = 2.5;
tpe_press_z = 5+tpe_press_base_z;

uvp_w = space_uv_w + bb_size-1;

module uv_lid() {
    difference() {
		translate([space_ec_w/2+bb_size, 0, ]) difference() {
			cube(size=[uvp_w, total_h, z_size], center=true);

			translate([bb_size/-2, 0, 0]) cube(size=[uvp_w-bb_size-2*rf_xsize, total_h-2*bb_size-2*rf_xsize, z_size+2], center=true);
			translate([bb_size/-2, 0, cover_frame_size]) cube(size=[uvp_w-bb_size-2*rf_xsize, total_h-2*bb_size, z_size], center=true);

			// top cover mount holes
	        translate([uvp_w/-2+bb_size, total_h/-2+bb_size/2, 0]) cylinder(d=4, h=z_size, $fn=16);
	        translate([uvp_w/2-bb_size, total_h/-2+bb_size/2, 0]) cylinder(d=4, h=z_size, $fn=16);
	        translate([uvp_w/-2+bb_size, total_h/2-bb_size/2, 0]) cylinder(d=4, h=z_size, $fn=16);
	        translate([uvp_w/2-bb_size, total_h/2-bb_size/2, 0]) cylinder(d=4, h=z_size, $fn=16);
	        translate([0, total_h/2-bb_size/2, 0]) cylinder(d=4, h=z_size, $fn=16);
	        translate([0, total_h/-2+bb_size/2, 0]) cylinder(d=4, h=z_size, $fn=16);
	
		}
			hinge_w = 2*mh_pitch+2;
			hinge_lower = 6;
			hinge_higher = 12;

			// left hinge	      
	        translate([total_w/-2+hinge_w/2+(8.2+0.5)*mh_pitch+mh_out_dia/2-0.5, total_h/2-bb_size/2, z_size/-2+(hinge_lower+1)/2-1]) cube(size=[hinge_w, bb_size+2, hinge_lower+1], center=true);
	        translate([total_w/-2+hinge_w/2+(8.2+0.5)*mh_pitch+mh_out_dia/2-0.5, total_h/2+bb_size/2-bb_size/3, z_size/-2+(hinge_higher+1)/2-1]) cube(size=[hinge_w, bb_size, hinge_higher+1], center=true);
	        translate([total_w/-2+9.2*mh_pitch+mh_out_dia/2, total_h/2-bb_size/2-bb_size/4+1, z_size/-2 -1]) cylinder(d=4, h=z_size+2, $fn=16);
	        translate([total_w/-2+10.2*mh_pitch+mh_out_dia/2, total_h/2-bb_size/2-bb_size/4+1, z_size/-2 -1]) cylinder(d=4, h=z_size+2, $fn=16);
	        // right hinge
	        translate([total_w/-2+hinge_w/2+(16.5+0.5)*mh_pitch+mh_out_dia/2-0.5, total_h/2-bb_size/2, z_size/-2+(hinge_lower+1)/2-1]) cube(size=[hinge_w, bb_size+2, hinge_lower+1], center=true);
	        translate([total_w/-2+hinge_w/2+(16.5+0.5)*mh_pitch+mh_out_dia/2-0.5, total_h/2+bb_size/2-bb_size/3, z_size/-2+(hinge_higher+1)/2-1]) cube(size=[hinge_w, bb_size, hinge_higher+1], center=true);
	        translate([total_w/-2+17.5*mh_pitch+mh_out_dia/2, total_h/2-bb_size/2-bb_size/4+1, z_size/-2 -1]) cylinder(d=4, h=z_size+2, $fn=16);
	        translate([total_w/-2+18.5*mh_pitch+mh_out_dia/2, total_h/2-bb_size/2-bb_size/4+1, z_size/-2 -1]) cylinder(d=4, h=z_size+2, $fn=16);

	}


}

module uv_lid_cover(part=1) {
	difference() {
		union() {
			cube(size=[uvp_w, total_h, lid_cover_zsize1], center=true);
			translate([lid_switch_x/-2, total_h/-2+lid_switch_y/2+42, lid_cover_zsize1/2 - lid_cover_zsize2/2]) cube(size=[uvp_w+lid_switch_x, lid_switch_y, lid_cover_zsize2], center=true);

		}
			translate([uvp_w/-2+bb_size, total_h/-2+bb_size/2, lid_cover_zsize1/2-3]) screw_trap();
			translate([uvp_w/2-bb_size, total_h/-2+bb_size/2, lid_cover_zsize1/2-3]) screw_trap();
			translate([uvp_w/-2+bb_size, total_h/2-bb_size/2, lid_cover_zsize1/2-3]) screw_trap();
			translate([uvp_w/2-bb_size, total_h/2-bb_size/2, lid_cover_zsize1/2-3]) screw_trap();
			translate([0, total_h/2-bb_size/2, lid_cover_zsize1/2-3]) screw_trap();
			translate([0, total_h/-2+bb_size/2, lid_cover_zsize1/2-3]) screw_trap();

			if(part==1) {
				translate([uvp_w/2+7, 0, 0]) cube(size=[uvp_w, total_h+2, lid_cover_zsize1+2], center=true);
				translate([uvp_w/2-7, 0, 1.5]) cube(size=[uvp_w, total_h+2, lid_cover_zsize1], center=true);

			}
			else {
				translate([uvp_w/-2-7, 0, 0]) cube(size=[uvp_w, total_h+2, lid_cover_zsize1+2], center=true);
				translate([uvp_w/-2+7, 0, -lid_cover_zsize1+1.5]) cube(size=[uvp_w, total_h+2, lid_cover_zsize1], center=true);
			}

	}
}

module screw_trap() {
	cylinder(d=6.5, h=3+1, $fn=100);
	translate([0, 0, -10.3]) cylinder(d=3.6, h=10, $fn=100);
}

module tpe_press() {
	cube(size=[(uvp_w-bb_size-2*rf_xsize-2)/2, total_h-2*bb_size-1.5, tpe_press_base_z], center=true);
	translate([0, 0, tpe_press_z/2 - tpe_press_base_z/2]) cube(size=[(uvp_w-bb_size-2*rf_xsize-2)/2, total_h-2*bb_size-2.5-2*rf_xsize, tpe_press_z], center=true);

}

//translate([0, 0, total_z-bb_size/2-z_size/2-top_cover_plate_z+10]) uv_lid();
//translate([space_ec_w/2+bb_size, 0, total_z-bb_size/2-z_size/2-top_cover_plate_z+50]) uv_lid_cover(part=1);
translate([space_ec_w/2+bb_size-8, 0, total_z-bb_size/2-z_size/2-top_cover_plate_z+40]) tpe_press();
