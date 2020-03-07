include <backbone.scad>

rf_xsize = 5;
rf_zsize = 7;
rf_side_overlap = bb_size - cover_frame_size - 2 - 0.25;

//translate([50, 0, 0]) center_tight_rf();
//uv_side_center_rf();
//uv_side_front_rf(1);
//ec_side_rf();
//uv_side_back_rf();
//ts_mount();
//uv_back_rf();
//uv_back_mount_rf();
//ec_top_side_rf();
//ec_front_rf();
//uv_holder_front();
//uv_washer();
//uv_holder_back();
//glass_holder();

module ec_front_rf() {
	difference() {
		cube(size=[space_uv_h-1, total_z-2*bb_size-1, rf_side_overlap-0.3], center=true);
		cube(size=[space_uv_h-1- 2*rf_xsize, total_z-2*bb_size-1- 2*rf_xsize, rf_side_overlap*3], center=true);
	}
}

module ec_top_side_rf() {
	difference() {
		uv_side_center_rf();
		translate([-1, -1, rf_zsize+bb_size-4]) cube(size=[mh_out_dia+2, rf_side_overlap+rf_xsize+2, space_uv_z*2]);
	}
}

module uv_back_mount_rf() {
	uv_side_center_rf(overlap=3);
}

module uv_back_rf() {
	size_x = space_uv_h-2;
	size_y = space_uv_z - 2;
	size_z = rf_side_overlap-3;
	difference() {
		cube(size=[size_x, size_y, size_z], center=true);
		cube(size=[size_x-2*rf_xsize, size_y-2*rf_xsize, rf_side_overlap], center=true);
	}
}

module ts_mount() {
	ts_w = bb_size/2+cover_frame_size;
	ts_d = 3*mh_pitch-1;
	ts_h = bb_size;

	switch_h = 10;
	switch_w = 21;
	switch_d = 6.4;

	pcb_mount_w = 5;

	union() {
		difference() {
			cube(size=[ts_w, ts_d, ts_h]);

			// cover frame
			translate([-1, -1, -1]) cube(size=[cover_frame_size+1, ts_d+2, bb_size-cover_frame_size+1]);
			// mount holes
			translate([0, ts_d/2-mh_pitch, ts_h/2]) rotate(a=[0, 90, 0]) cylinder(d=mh_inner_dia, h=ts_w+2, $fn=100);
			translate([0, ts_d/2+mh_pitch, ts_h/2]) rotate(a=[0, 90, 0]) cylinder(d=mh_inner_dia, h=ts_w+2, $fn=100);
			translate([0, ts_d/2-mh_pitch, ts_h/2]) rotate(a=[0, 90, 0]) nut_trap(h=ts_w/2);
			translate([0, ts_d/2+mh_pitch, ts_h/2]) rotate(a=[0, 90, 0]) nut_trap(h=ts_w/2);

			// switch cutout
			translate([ts_w-switch_d, ts_d/2-switch_w/2, ts_h-switch_h]) cube(size=[switch_d+1, switch_w, switch_h+1]);
			// pcb cutout
			translate([-1, ts_d/2-switch_w/2, -1]) cube(size=[ts_w+2, switch_w, ts_h-switch_h+1.01]);
		}
		difference() {
			translate([-pcb_mount_w, (ts_d-switch_w)/2, ts_h-switch_h]) cube(size=[pcb_mount_w+cover_frame_size+1, switch_w, 2]);
			translate([-pcb_mount_w+(pcb_mount_w+cover_frame_size)/2, ts_d/2, 0]) cylinder(d=2.4, h=ts_h, $fn=100);
		}
	}
}

module uv_side_back_rf() {
	bottom_w = mh_out_dia;
	top_w = 2*mh_pitch + mh_out_dia;
	total_w = top_w + rf_side_overlap;
	rf_h = space_uv_z +2*bb_size - 2*4;

	difference() {
		cube(size=[rf_xsize, total_w, rf_h]);

		// cut to bb sides
		translate([-1, -1, -1]) cube(size=[rf_zsize+2, rf_side_overlap+1, bb_size-4+1]);
		translate([-1, -1, rf_h-bb_size+4]) cube(size=[rf_zsize+2, rf_side_overlap+1, bb_size-4+1]);

		// cut Z to rf_zsize
		translate([-1, rf_side_overlap+rf_xsize, rf_zsize]) cube(size=[rf_zsize+2, total_w, rf_h-2*rf_zsize]);
		// side cut
		translate([-1, rf_xsize, bb_size-4+rf_zsize]) cube(size=[rf_zsize+2, total_w, rf_h-2*(bb_size-4+rf_zsize)]);

		// nut traps
		translate([rf_xsize/2, rf_side_overlap+mh_out_dia/2+2*mh_pitch, rf_zsize/2]) rotate(a=[0, 90, 0]) rotate(a=[0, 0, 90]) nut_trap(h=rf_xsize);
		translate([rf_xsize/2, rf_side_overlap+mh_out_dia/2+2*mh_pitch, rf_h-rf_zsize/2]) rotate(a=[0, 90, 0]) rotate(a=[0, 0, 90]) nut_trap(h=rf_xsize);
		// screw_holes
		translate([-1, rf_side_overlap+mh_out_dia/2+2*mh_pitch, rf_zsize/2]) rotate(a=[0, 90, 0]) rotate(a=[0, 0, 90]) cylinder(d=mh_inner_dia, h=rf_zsize+2, $fn=100);
		translate([-1, rf_side_overlap+mh_out_dia/2+2*mh_pitch, rf_h-rf_zsize/2]) rotate(a=[0, 90, 0]) rotate(a=[0, 0, 90]) cylinder(d=mh_inner_dia, h=rf_zsize+2, $fn=100);


	}

}

module ec_side_rf() {
	rf_w = 4*mh_pitch + mh_out_dia;
	rf_d = rf_side_overlap+rf_xsize;
	rf_h = total_z - 2*4;

	difference() {
		cube(size=[rf_w, rf_d, rf_h]);

		// make it frame
		translate([rf_xsize, -1, rf_zsize]) cube(size=[rf_w-2*rf_xsize, rf_d+2, rf_h-2*rf_zsize]);
		// bottom cut
		translate([-1, -1, -1]) cube(size=[rf_w+2, rf_side_overlap+1, bb_size-4+1.5]);
		// top cut
		translate([-1, -1, rf_h-bb_size+4-0.5]) cube(size=[rf_w+2, rf_side_overlap+1, bb_size-4+1.5]);

		
		for(i=[1:3]) {
			// screw holes
			translate([mh_out_dia/2+i*mh_pitch, 0, rf_zsize/2]) rotate(a=[-90, 0, 0]) cylinder(d=mh_inner_dia, h=rf_d+2, $fn=100);
			translate([mh_out_dia/2+i*mh_pitch, 0, rf_h-rf_zsize/2]) rotate(a=[-90, 0, 0]) cylinder(d=mh_inner_dia, h=rf_d+2, $fn=100);
			// nut traps
			translate([mh_out_dia/2+i*mh_pitch, rf_side_overlap+rf_xsize/2, rf_zsize/2]) rotate(a=[-90, 0, 0]) nut_trap(h=rf_zsize/2+1);
			translate([mh_out_dia/2+i*mh_pitch, rf_side_overlap+rf_xsize/2, rf_h-rf_zsize/2]) rotate(a=[-90, 0, 0]) nut_trap(h=rf_zsize/2+1);
		}
	}
	
}

module uv_side_front_rf(side=1) {
	bottom_w = mh_out_dia;
	top_w = mh_pitch + mh_out_dia;
	total_w = top_w + rf_side_overlap;
	rf_h = space_uv_z +2*bb_size - 2*4;

	difference() {
		cube(size=[rf_xsize, total_w, rf_h]);

		// cut to bb sides
		translate([-1, -1, -1]) cube(size=[rf_zsize+2, rf_side_overlap+1, bb_size-4+1]);
		translate([-1, -1, rf_h-bb_size+4]) cube(size=[rf_zsize+2, rf_side_overlap+1, bb_size-4+1]);

		// cut Z to rf_zsize
		translate([-1, rf_side_overlap+rf_xsize, rf_zsize]) cube(size=[rf_zsize+2, total_w, rf_h-2*rf_zsize]);
		// side cut
		translate([-1, rf_xsize, bb_size-4+rf_zsize]) cube(size=[rf_zsize+2, total_w, rf_h-2*(bb_size-4+rf_zsize)]);
		// bottom mount hole shortenint
		translate([-1, rf_side_overlap+bottom_w, -1]) cube(size=[rf_zsize+2, total_w, rf_zsize+2]);

		// nut traps
		translate([side*rf_xsize/2, rf_side_overlap+mh_out_dia/2, rf_zsize/2]) rotate(a=[0, 90, 0]) rotate(a=[0, 0, 90]) nut_trap(h=rf_xsize);
		translate([side*rf_xsize/2, rf_side_overlap+mh_out_dia/2+mh_pitch, rf_h-rf_zsize/2]) rotate(a=[0, 90, 0]) rotate(a=[0, 0, 90]) nut_trap(h=rf_xsize);
		// screw_holes
		translate([-1, rf_side_overlap+mh_out_dia/2, rf_zsize/2]) rotate(a=[0, 90, 0]) rotate(a=[0, 0, 90]) cylinder(d=mh_inner_dia, h=rf_zsize+2, $fn=100);
		translate([-1, rf_side_overlap+mh_out_dia/2+mh_pitch, rf_h-rf_zsize/2]) rotate(a=[0, 90, 0]) rotate(a=[0, 0, 90]) cylinder(d=mh_inner_dia, h=rf_zsize+2, $fn=100);


	}

}

module uv_side_center_rf(overlap=rf_side_overlap) {
	rf_side_overlap=overlap;
	rf_w = mh_out_dia;
	rf_d = rf_side_overlap + rf_xsize;
	rf_h = space_uv_z + 2*bb_size - 2*4;

	difference() {
		cube(size=[rf_w, rf_d, rf_h]);

		translate([-1, -1, -1]) cube(size=[rf_w+2, rf_side_overlap+1, bb_size-4+1]);
		translate([-1, -1, rf_h-bb_size+4]) cube(size=[rf_w+2, rf_side_overlap+1, bb_size/2+4+1]);
		translate([-1, rf_xsize, bb_size-4+rf_zsize]) cube(size=[rf_w+2, rf_d, space_uv_z-2*rf_zsize]);

		// nut traps
		translate([rf_w/2, rf_d-rf_xsize/2, rf_zsize/2]) rotate(a=[-90, 0, 0]) nut_trap(h=rf_xsize);
		translate([rf_w/2, rf_d-rf_xsize/2, rf_h-rf_zsize/2]) rotate(a=[-90, 0, 0]) nut_trap(h=rf_xsize);

		// screw holes
		translate([rf_w/2, -1, rf_zsize/2]) rotate(a=[-90, 0, 0]) cylinder(d=mh_inner_dia, h=rf_d, $fn=100);
		translate([rf_w/2, -1, rf_h-rf_zsize/2]) rotate(a=[-90, 0, 0]) cylinder(d=mh_inner_dia, h=rf_d, $fn=100);

	}
}

module center_tight_rf() {
	tight_tolerance = 2;
	ctrf_w = (15.5-13.2)*mh_pitch + mh_out_dia;
	ctrf_h = space_uv_h - tight_tolerance;

	center_cutoff = rf_zsize+3;

	difference() {
		cube(size=[ctrf_w, ctrf_h, rf_zsize], center=true);

		translate([center_cutoff-ctrf_w, 0, 0]) cube(size=[ctrf_w, ctrf_h-2*rf_xsize, rf_zsize+2], center=true); 
		translate([-center_cutoff+ctrf_w, 0, 0]) cube(size=[ctrf_w, ctrf_h-2*rf_xsize, rf_zsize+2], center=true); 
		translate([0, ctrf_h/-2+(rf_xsize*3)/2-1, 0]) cube(size=[mh_out_dia+2, rf_xsize*3, rf_zsize+2], center=true);
		translate([0, ctrf_h/2-(rf_xsize*3)/2+1, 0]) cube(size=[mh_out_dia+2, rf_xsize*3, rf_zsize+2], center=true);


		// nut traps
		translate([ctrf_w/-2+center_cutoff/2, ctrf_h/2-rf_xsize/2, 0]) rotate(a=[90, 0, 0]) nut_trap(h=rf_xsize);
		translate([ctrf_w/2-center_cutoff/2, ctrf_h/2-rf_xsize/2, 0]) rotate(a=[90, 0, 0]) nut_trap(h=rf_xsize);
		translate([ctrf_w/-2+center_cutoff/2, ctrf_h/-2+rf_xsize/2, 0]) rotate(a=[-90, 0, 0]) nut_trap(h=rf_xsize);
		translate([ctrf_w/2-center_cutoff/2, ctrf_h/-2+rf_xsize/2, 0]) rotate(a=[-90, 0, 0]) nut_trap(h=rf_xsize);

		// screw holes
		translate([ctrf_w/-2+center_cutoff/2, ctrf_h/2+1, 0]) rotate(a=[90, 0, 0]) cylinder(d=mh_inner_dia, h=ctrf_h+2, $fn=100);
		translate([ctrf_w/2-center_cutoff/2, ctrf_h/2+1, 0]) rotate(a=[90, 0, 0]) cylinder(d=mh_inner_dia, h=ctrf_h+2, $fn=100);



	}
		//translate([ctrf_w/-2+rf_zsize/2, ctrf_h/2+rf_xsize/2, 0]) rotate(a=[90, 0, 0]) nut_trap(h=rf_xsize+100);

}

module uv_holder_front() {
	holder_w = mh_pitch+mh_out_dia;
	holder_h = space_uv_h-1;
	insert_nut_d = 3.7;
	insert_nut_h = 10;

	difference() {
		cube(size=[holder_w, holder_h, rf_zsize], center=true);
		// insert nuts
		translate([mh_pitch/-2, holder_h/-2-0.1, 0])rotate(a=[-90, 0, 0]) cylinder(d=insert_nut_d, h=insert_nut_h, $fn=100);
		translate([mh_pitch/2, holder_h/-2-0.1, 0])rotate(a=[-90, 0, 0]) cylinder(d=insert_nut_d, h=insert_nut_h, $fn=100);
		translate([mh_pitch/-2, holder_h/2+0.1, 0])rotate(a=[90, 0, 0]) cylinder(d=insert_nut_d, h=insert_nut_h, $fn=100);
		translate([mh_pitch/2, holder_h/2+0.1, 0])rotate(a=[90, 0, 0]) cylinder(d=insert_nut_d, h=insert_nut_h, $fn=100);
		// uv rail
		translate([0, 122/-2, 0]) cube(size=[holder_w-4, 3.6, rf_zsize+2], center=true);
		translate([0, 122/-2, -rf_zsize+2.3]) cube(size=[holder_w+2, 5.5, rf_zsize], center=true);
		translate([0, 122/2, 0]) cube(size=[holder_w-4, 3.6, rf_zsize+2], center=true);
		translate([0, 122/2, -rf_zsize+2.3]) cube(size=[holder_w+2, 5.5, rf_zsize], center=true);
		// material saving
		translate([holder_w*2/-3, 0, 0]) cube(size=[holder_w, holder_h*2/3, rf_zsize+2], center=true);
		translate([holder_w*2/3, 0, 0]) cube(size=[holder_w, holder_h*2/3, rf_zsize+2], center=true);

	}
	
}

module uv_holder_back() {
	holder_w = 2*mh_pitch+mh_out_dia;
	holder_h = space_uv_h-1;
	insert_nut_d = 3.7;
	insert_nut_h = 10;

	difference() {
		cube(size=[holder_w, holder_h, rf_zsize], center=true);
		// insert nuts
		translate([mh_pitch*-1, holder_h/-2-0.1, 0])rotate(a=[-90, 0, 0]) cylinder(d=insert_nut_d, h=insert_nut_h, $fn=100);
		translate([0, holder_h/-2-0.1, 0])rotate(a=[-90, 0, 0]) cylinder(d=insert_nut_d, h=insert_nut_h, $fn=100);
		translate([mh_pitch*-1, holder_h/2+0.1, 0])rotate(a=[90, 0, 0]) cylinder(d=insert_nut_d, h=insert_nut_h, $fn=100);
		translate([0, holder_h/2+0.1, 0])rotate(a=[90, 0, 0]) cylinder(d=insert_nut_d, h=insert_nut_h, $fn=100);
		// uv rail
		translate([0, 122/-2, 0]) cube(size=[holder_w-4, 3.6, rf_zsize+2], center=true);
		translate([0, 122/-2, -rf_zsize+2.3]) cube(size=[holder_w+2, 5.5, rf_zsize], center=true);
		translate([0, 122/2, 0]) cube(size=[holder_w-4, 3.6, rf_zsize+2], center=true);
		translate([0, 122/2, -rf_zsize+2.3]) cube(size=[holder_w+2, 5.5, rf_zsize], center=true);
		// material saving
		translate([holder_w*2/-3, 0, 0]) cube(size=[holder_w, holder_h*2/3, rf_zsize+2], center=true);
		translate([holder_w*2/3, 0, 0]) cube(size=[holder_w, holder_h*2/3, rf_zsize+2], center=true);

	}
	
}

module uv_washer() {
	difference() {
		cylinder(d=6, h=12, $fn=100);
		translate([0, 0, -1]) cylinder(d=3.6, h=14, $fn=100);
	}
}

module glass_holder() {
	top_glass = 1.5;
	glass_h = 2;
	total_z = rf_zsize + top_glass+glass_h;
	
	translate([0, 0, 140]) difference() {
		translate([space_ec_w/2+bb_size/2, 0, 0]) difference() {
			cube(size=[space_uv_w-1, space_uv_h-1, total_z], center=true);

			// cut middle
			cube(size=[(space_uv_w-1)-2*rf_xsize, (space_uv_h-1)-2*rf_xsize, total_z+2], center=true);
			// glass cut
			gc_h = glass_h+0.4;
			translate([0, 0, total_z/2-gc_h/2-top_glass]) cube(size=[space_uv_w-1-3, space_uv_h-1-3, gc_h], center=true);
			
			// rf cutouts
			// left
			translate([(space_uv_w-1)/-2-1, (space_uv_h-1)/-2-1, total_z/-2-1]) cube(size=[rf_xsize+5, space_uv_h+2, rf_zsize+1+glass_h]);
			translate([(space_uv_w-1)/-2-1, (space_uv_h-1)/-2-1, total_z/-2-1]) cube(size=[2, space_uv_h+2, total_z+2]);

			// right
			translate([(space_uv_w-1)/2-rf_xsize-3, (space_uv_h-1)/-2-1, total_z/-2-1]) cube(size=[rf_xsize+4, 3*mh_pitch+mh_out_dia+3, rf_zsize+1]);
			translate([(space_uv_w-1)/2-rf_xsize-3, (space_uv_h-1)/2-3*mh_pitch-mh_out_dia-2, total_z/-2-1]) cube(size=[rf_xsize+4, 3*mh_pitch+mh_out_dia+3, rf_zsize+1]);
			// middle
			translate([-3.5, (space_uv_h-1)/-2-1, total_z/-2-1]) cube(size=[mh_out_dia*1.5+3, space_uv_h+2, rf_zsize+1]);
			
		}
		// screw holes
		translate([total_w/-2 + mh_out_dia/2 + 8.2*mh_pitch, space_uv_h/-2, (-top_glass-glass_h)/2]) rotate(a=[-90, 0, 0]) cylinder(d=3.7, h=rf_xsize*2+space_uv_h, $fn=100);
		translate([total_w/-2 + mh_out_dia/2 + 12.2*mh_pitch, space_uv_h/-2, (-top_glass-glass_h)/2]) rotate(a=[-90, 0, 0]) cylinder(d=3.7, h=rf_xsize*2+space_uv_h, $fn=100);
		translate([total_w/-2 + mh_out_dia/2 + 16.5*mh_pitch, space_uv_h/-2, (-top_glass-glass_h)/2]) rotate(a=[-90, 0, 0]) cylinder(d=3.7, h=rf_xsize*2+space_uv_h, $fn=100);
		//y
		translate([0, total_h/-2+mh_out_dia/2 + 5*mh_pitch, (-top_glass-glass_h)/2]) rotate(a=[-90, 0, -90]) cylinder(d=3.7, h=rf_xsize*2+space_uv_h, $fn=100);
		translate([0, total_h/-2+mh_out_dia/2 + 7*mh_pitch, (-top_glass-glass_h)/2]) rotate(a=[-90, 0, -90]) cylinder(d=3.7, h=rf_xsize*2+space_uv_h, $fn=100);
	}


}

module nut_trap (w = 5.5, h = 3)
{
        cylinder(r = w / 2 / cos(180 / 6) + 0.05, h=h, $fn=6);
}    