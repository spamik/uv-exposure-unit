include <backbone.scad>

base_thick = 2;
cover_thick = 1;
tolerance = 0.7;
overlap = 10;

//uv_cover_bottom();
//uv_cover_bottom(0);
//ec_cover_bottom();

//translate([150, 0, 0]) ec_cover_side(1);
//translate([0, 150, 0]) uv_cover_side();
//translate([0, 150, 0]) uv_cover_side(0);
//uv_ec_plate();
//uv_back_plate();
//ec_uv_back_plate();
ec_cover_front();

module ec_cover_front() {
    height = total_z-2*bb_size-2*tolerance;
    difference() {
        union() {
            cube(size=[space_uv_h-2*tolerance, total_z-2*bb_size-2*tolerance, base_thick], center=true);
            translate([0, 0, cover_thick/2]) cube(size=[space_uv_h-2*tolerance-2*cover_frame_size, total_z-2*bb_size-2*tolerance-2*cover_frame_size, base_thick+cover_thick], center=true);
        }

        // diodes
        diod_d = 5;
        translate([64.5/-2+22.85, height/-2 + 20 - 1 + 1.6, -base_thick]) cylinder(d=diod_d, h=base_thick*3, $fn=100);
        translate([64.5/-2+22.85+6.35, height/-2 + 20 - 1 + 1.6, -base_thick]) cylinder(d=diod_d, h=base_thick*3, $fn=100);
        // keyboard
        translate([0, height/-2+50, cover_thick/2+base_thick+cover_thick-0.9]) cube(size=[69.5, 20.5, base_thick+cover_thick], center=true);
        translate([0, height/-2+50+17/2-3.5/2, -base_thick]) cube(size=[18, 3.5, base_thick*5], center=true);
        // display
        display_pure_w = 27;
        display_pure_h = 15;
        display_total_h = 27;
        display_offset = 20;
        translate([0, display_offset, -base_thick]) cube(size=[display_pure_w, display_pure_h, base_thick*5], center=true);
        translate([0, display_offset+4.5/2, cover_thick/2-cover_tick]) union() {
            cube(size=[display_pure_w+2, display_total_h+2, base_thick+cover_thick], center=true);
            mount_hole = 2.5;
            mount_hole_offset = 2;
            translate([display_pure_w/2 - mount_hole_offset, display_total_h/2 - mount_hole_offset, -base_thick]) cylinder(d=mount_hole, h=base_thick*5, $fn=100);
            translate([display_pure_w/-2 + mount_hole_offset, display_total_h/2 - mount_hole_offset, -base_thick]) cylinder(d=mount_hole, h=base_thick*5, $fn=100);
            translate([display_pure_w/2 - mount_hole_offset, display_total_h/-2 + mount_hole_offset, -base_thick]) cylinder(d=mount_hole, h=base_thick*5, $fn=100);
            translate([display_pure_w/-2 + mount_hole_offset, display_total_h/-2 + mount_hole_offset, -base_thick]) cylinder(d=mount_hole, h=base_thick*5, $fn=100);
        }
        
    }
}

module ec_uv_back_plate() {
    cube(size=[space_uv_h-2*tolerance, total_z-space_uv_z-3*bb_size-tolerance, base_thick], center=true);
    translate([0, cover_frame_size/2, cover_thick/2]) cube(size=[space_uv_h-2*tolerance-2*cover_frame_size, total_z-space_uv_z-3*bb_size-tolerance-cover_frame_size, base_thick+cover_thick], center=true);
}

module uv_back_plate() {
    union() {
        cube(size=[space_uv_h-2*tolerance, space_uv_z-2*tolerance, base_thick], center=true);
        translate([0, 0, cover_thick/2]) cube(size=[space_uv_h-2*tolerance-2*cover_frame_size, space_uv_z-2*tolerance-2*cover_frame_size, base_thick+cover_thick], center=true);
    }
}


module ec_cover_bottom() {
    cube(size=[space_ec_w-2*tolerance, space_uv_h-2*tolerance, base_thick], center=true);
    translate([0, 0, cover_thick/2]) cube(size=[space_ec_w-2*cover_frame_size-2*tolerance, space_uv_h-2*cover_frame_size-2*tolerance, base_thick+cover_thick], center=true);
}

module uv_cover_bottom(cut_side=1) {
    difference() {
        union() {
            cube(size=[space_uv_w-2*tolerance, space_uv_h-2*tolerance, base_thick], center=true);
            translate([0, 0, cover_thick/2]) cube(size=[space_uv_w-2*cover_frame_size-2*tolerance, space_uv_h-2*cover_frame_size-2*tolerance, base_thick+cover_thick], center=true);
        }
        if(cut_side==1) {
            translate([overlap, space_uv_h/-2, -base_thick]) cube(size=[space_uv_w, space_uv_h, base_thick*3]);
            translate([0, space_uv_h/-2, (cover_thick+base_thick)/-2-0.49]) cube(size=[space_uv_w, space_uv_h, base_thick+1]);
        }
        else {
            translate([-space_uv_w, space_uv_h/-2, -base_thick]) cube(size=[space_uv_w, space_uv_h, base_thick*3]);
            translate([overlap/2-0.01, 0, base_thick+cover_thick/2]) cube(size=[overlap, space_uv_h, base_thick+cover_thick], center=true);
        }
        
    }
}

module ec_cover_side(connector_cut=0) {
    difference() {
        union() {
            cube(size=[space_ec_w-2*tolerance, total_z-2*bb_size-2*tolerance, base_thick], center=true);
            translate([0, 0, cover_thick/2]) cube(size=[space_ec_w-2*cover_frame_size-2*tolerance, total_z-2*bb_size-2*cover_frame_size-2*tolerance, base_thick+cover_thick], center=true);        
        }
        if(connector_cut==1) {
            connector_inner = 12;
            connector_outer = 15;
            translate([connector_outer/-2-5, total_z/-2+3*bb_size, -base_thick]) cylinder(d=connector_inner, h=base_thick*3, $fn=100);
            translate([connector_outer/-2-5, total_z/-2+3*bb_size, base_thick/2-0.5]) cylinder(d=connector_outer, h=base_thick*3, $fn=100);
            translate([connector_outer/2+5, total_z/-2+3*bb_size, -base_thick]) cylinder(d=connector_inner, h=base_thick*3, $fn=100);
            translate([connector_outer/2+5, total_z/-2+3*bb_size, base_thick/2-0.5]) cylinder(d=connector_outer, h=base_thick*3, $fn=100);
        }
    }
}

module uv_cover_side(cut_side=1) {
    difference() {
        union() {
            cube(size=[space_uv_w-2*tolerance, space_uv_z-2*tolerance, base_thick], center=true);
            translate([0, 0, cover_thick/2]) cube(size=[space_uv_w-2*cover_frame_size-2*tolerance, space_uv_z-2*cover_frame_size-2*tolerance, base_thick+cover_thick], center=true);
        }
        if(cut_side==1) {
            translate([overlap, space_uv_z/-2, -base_thick]) cube(size=[space_uv_w, space_uv_z, base_thick*3]);
            translate([0, space_uv_z/-2, (cover_thick+base_thick)/-2-0.49]) cube(size=[space_uv_w, space_uv_z, base_thick+1]);
        }
        else {
            translate([-space_uv_w, space_uv_z/-2, -base_thick]) cube(size=[space_uv_w, space_uv_z, base_thick*3]);
            translate([overlap/2-0.01, 0, base_thick+cover_thick/2]) cube(size=[overlap, space_uv_z, base_thick+cover_thick], center=true);
        }
        
    }
}

module uv_ec_plate() {
    difference() {
        cube(size=[space_uv_h-2*tolerance, space_uv_z-2*tolerance, base_thick/2], center=true);
        translate([0, space_uv_z/2, base_thick/-2-1]) cylinder(d=15, h=base_thick+2);
    }
}