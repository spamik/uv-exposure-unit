use <MCAD/boxes.scad>

// box setup
bb_size = 15;
space_uv_w = 220;
space_uv_h = 160;
space_uv_z = 110;
space_ec_w = 75;
mh_pitch = 15;
cover_frame_size = 2;

// mount holes
mh_inner_dia = 3;
mh_out_dia = 10;
mh_out_h = 3.5;
mh_x_positions = [1, 2, 3, 4, 5, 7.2, 8.2, 9.2, 10.2, 11.2, 12.2, 13.2, 14.35, 15.5, 16.5, 17.5, 18.5, 19.5, 20.5];
mh_y_positions = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];

top_cover_z = 25;
top_cover_plate_z = 4;


total_w = space_uv_w+space_ec_w+3*bb_size;
total_h = space_uv_h+2*bb_size;
total_z = space_uv_z+top_cover_z+2*bb_size;


//bottom_plate(1);
//translate([0, 0, bb_size+2]) bottom_plate(-1);

//translate([total_w/2-bb_size, total_h/-2, bb_size/-2]) right_zbar();
//translate([total_w/-2+space_ec_w+bb_size, total_h/-2, -bb_size/2]) middle_zbar();
//translate([total_w/-2+space_ec_w+bb_size, total_h/2, -bb_size/2]) mirror([0, 1, 0]) middle_zbar();

//translate([total_w/-2, total_h/-2, bb_size/-2]) left_zbar();

//translate([total_w/-2+(space_ec_w+2*bb_size)/2, 0, total_z-bb_size]) top_plate();

//translate([0, 0, total_z-top_cover_z-bb_size+1]) uv_plate();
//translate([0, 0, total_z-top_cover_z-bb_size+1]) uv_plate(2);

//translate([-19.5, total_h/2+0.1, total_z-top_cover_z-bb_size/2+5.1]) rotate(a=[0, 90, 90]) import("test_hinge.stl");

//hinge_washer();

mount_hole_cover();

module mount_hole_cover() {
    difference() {
        cylinder(d=mh_out_dia-0.3, h=mh_out_h, $fn=100);
        translate([0, 0, 1]) cylinder(d=mh_out_dia-0.3-1.6, h=mh_out_h, $fn=100);
        translate([(mh_out_dia-0.3)/-2, 0, 0]) cube(size=[1.8, 1.8, mh_out_h*3], center=true);
        translate([(mh_out_dia-0.3)/2, 0, 0]) cube(size=[1.8, 1.8, mh_out_h*3], center=true);

    }
}

module hinge_washer() {
    hinge_w = 30;
    hinge_d = 4;
    washer_d = bb_size/2-hinge_d;
    hinge_down_cutoff = 2;

    difference() {        
        union() {
            cube(size=[hinge_w, bb_size, washer_d]);
            cube(size=[hinge_w, hinge_down_cutoff, bb_size/2]);
            translate([0, -cover_frame_size, bb_size/2-cover_frame_size]) cube(size=[hinge_w, cover_frame_size+hinge_down_cutoff, cover_frame_size]);
        }

        translate([hinge_w/2-mh_pitch/2, bb_size/2, -1]) cylinder(d=3.5, h=washer_d+2, $fn=100);
        translate([hinge_w/2+mh_pitch/2, bb_size/2, -1]) cylinder(d=3.5, h=washer_d+2, $fn=100);

    }
}

module uv_plate(cut_side=1) {
    uvp_w = space_uv_w + 2*bb_size;

    difference() {
        translate([space_ec_w/2+bb_size/2, 0, 0]) difference() {
            union() {
                cube(size=[uvp_w, total_h, bb_size], center=true);
                // cover frames
                translate([0, total_h/-2+cover_frame_size/2, cover_frame_size/-2]) cube(size=[uvp_w, cover_frame_size, bb_size+cover_frame_size], center=true);
                translate([0, total_h/2-cover_frame_size/2, cover_frame_size/-2]) cube(size=[uvp_w, cover_frame_size, bb_size+cover_frame_size], center=true);
                translate([uvp_w/2-cover_frame_size/2, 0, cover_frame_size/-2]) cube(size=[cover_frame_size, total_h, bb_size+cover_frame_size], center=true);

            }
            cube(size=[space_uv_w, space_uv_h, bb_size+2], center=true);
        }

        // mounting holes              
        for (i = mh_x_positions) {
            translate([total_w/-2 + mh_out_dia/2 + i*mh_pitch, total_h/-2+bb_size+1, 0]) rotate(a=[90, 0, 0]) mounting_hole();
            translate([total_w/-2 + mh_out_dia/2 + i*mh_pitch, total_h/2+1, 0]) rotate(a=[90, 0, 0]) mounting_hole();
        }
        for (i = mh_y_positions) {
            translate([total_w/-2-1, total_h/-2+mh_out_dia/2 + i*mh_pitch, 0]) rotate(a=[90, 0, 90]) mounting_hole();
            translate([total_w/-2-1+bb_size+space_ec_w, total_h/-2+mh_out_dia/2 + i*mh_pitch, 0]) rotate(a=[90, 0, 90]) mounting_hole();
            translate([total_w/2-1-bb_size, total_h/-2+mh_out_dia/2 + i*mh_pitch, 0]) rotate(a=[90, 0, 90]) mounting_hole();
        }

        // cut corners
        translate([17*mh_pitch+mh_out_dia/2-0.5, total_h/2, 0]) cube(size=[total_w, bb_size, bb_size+10], center=true); 
        translate([19*mh_pitch+mh_out_dia/2-0.5, total_h/-2, 0]) cube(size=[total_w, bb_size, bb_size+10], center=true); 
        zbar_h = 2.5*mh_pitch + mh_out_dia/2;
        translate([total_w/2, total_h/-2+zbar_h/2-1]) cube(size=[bb_size, zbar_h+2, bb_size+5], center=true);
        translate([total_w/2, total_h/2-zbar_h/2+1]) cube(size=[bb_size, zbar_h+2, bb_size+5], center=true);
        lp_cut_w = 7.2*mh_pitch + 0.5*mh_pitch + mh_out_dia/2;
        translate([total_w/-2+lp_cut_w/2, total_h/-2, 0]) cube(size=[lp_cut_w, bb_size, bb_size+5], center=true);
        translate([total_w/-2+lp_cut_w/2, total_h/2, 0]) cube(size=[lp_cut_w, bb_size, bb_size+5], center=true);
        lp_cut_h = 1.5*mh_pitch + mh_out_dia/2+0.5;
        translate([total_w/-2+bb_size+space_ec_w, total_h/-2+lp_cut_h/2, 0]) cube(size=[bb_size, lp_cut_h, bb_size+5], center=true);
        translate([total_w/-2+bb_size+space_ec_w, total_h/2-lp_cut_h/2, 0]) cube(size=[bb_size, lp_cut_h, bb_size+5], center=true);
        // left hinge
        hinge_w = 2*mh_pitch+1;
        translate([total_w/-2+hinge_w/2+(8.2+0.5)*mh_pitch+mh_out_dia/2-0.5, total_h/2, 0]) cube(size=[hinge_w, bb_size, bb_size+5], center=true);

        // cut sides
        if (cut_side==1) {
            translate([(15.5+0.5)*mh_pitch+mh_out_dia/2, 0, 0]) cube(size=[total_w, total_h+2, bb_size+10], center=true);
            translate([(12.2+0.5)*mh_pitch+mh_out_dia/2-0.5, total_h/-2, 0]) cube(size=[total_w, bb_size, bb_size+10], center=true);
            translate([(12.2+0.5)*mh_pitch+mh_out_dia/2-0.5, total_h/2, 0]) cube(size=[total_w, bb_size, bb_size+10], center=true);
        }
        else {
            left_w = (12.2+0.5)*mh_pitch+mh_out_dia/2;
            translate([total_w/-2+left_w/2, 0, 0]) cube(size=[left_w, total_h+2, bb_size+10], center=true);
            translate([(total_w-((15.5+0.5)*mh_pitch+mh_out_dia/2))*-1+0.5, total_h/-2+bb_size, 0]) cube(size=[total_w, bb_size, bb_size+10], center=true);
            translate([(total_w-((15.5+0.5)*mh_pitch+mh_out_dia/2))*-1+0.5, total_h/+2-bb_size, 0]) cube(size=[total_w, bb_size, bb_size+10], center=true);

        }
    }
}

module top_plate() {
    tp_w = space_ec_w + 2*bb_size;
    difference() {
        union() {
            difference() {
                union() {
                    cube(size=[tp_w, total_h, bb_size], center=true);
                    // cover frames
                    translate([0, total_h/-2+cover_frame_size/2, cover_frame_size/-2]) cube(size=[tp_w, cover_frame_size, bb_size+cover_frame_size], center=true);
                    translate([0, total_h/2-cover_frame_size/2, cover_frame_size/-2]) cube(size=[tp_w, cover_frame_size, bb_size+cover_frame_size], center=true);
                    translate([tp_w/-2+cover_frame_size/2, 0, cover_frame_size/-2]) cube(size=[cover_frame_size, total_h, bb_size+cover_frame_size], center=true);
                    translate([tp_w/2-cover_frame_size/2, 0, cover_frame_size/-2]) cube(size=[cover_frame_size, total_h, bb_size+cover_frame_size], center=true);

                }
                cube(size=[space_ec_w, space_uv_h, bb_size+2], center=true);

                // mount holes
                for (i = mh_x_positions) {
                    translate([tp_w/-2 + mh_out_dia/2 + i*mh_pitch, total_h/-2+bb_size+1, 0]) rotate(a=[90, 0, 0]) mounting_hole();
                    translate([tp_w/-2 + mh_out_dia/2 + i*mh_pitch, total_h/2+1, 0]) rotate(a=[90, 0, 0]) mounting_hole();
                }
                for (i = mh_y_positions) {
                    translate([tp_w/-2-1, total_h/-2+mh_out_dia/2 + i*mh_pitch, 0]) rotate(a=[90, 0, 90]) mounting_hole();
                    translate([tp_w/-2-1+bb_size+space_ec_w, total_h/-2+mh_out_dia/2 + i*mh_pitch, 0]) rotate(a=[90, 0, 90]) mounting_hole();            
                }
            }
            // top cover frames
            translate([0, total_h/-2+bb_size/2+cover_frame_size/2, bb_size/2-cover_frame_size/2]) cube(size=[tp_w, bb_size+cover_frame_size, cover_frame_size], center=true);
            translate([0, total_h/2-bb_size/2-cover_frame_size/2, bb_size/2-cover_frame_size/2]) cube(size=[tp_w, bb_size+cover_frame_size, cover_frame_size], center=true);
            translate([tp_w/-2+bb_size/2+cover_frame_size/2, 0, bb_size/2-cover_frame_size/2]) cube(size=[bb_size+cover_frame_size, total_h, cover_frame_size], center=true);
            translate([tp_w/2-bb_size/2-cover_frame_size/2, 0, bb_size/2-cover_frame_size/2]) cube(size=[bb_size+cover_frame_size, total_h, cover_frame_size], center=true);

        }

        // cut outs
        // left
        l_w = 2.5*mh_pitch+mh_out_dia/2;
        l_h = 2.5*mh_pitch + mh_out_dia/2;
        translate([tp_w/-2+(l_w+1)/2-1, total_h/-2, 0]) cube(size=[l_w+1, bb_size, bb_size+5], center=true); 
        translate([tp_w/-2+(l_w+1)/2-1, total_h/2, 0]) cube(size=[l_w+1, bb_size, bb_size+5], center=true); 
        translate([tp_w/-2, total_h/-2+(l_h+1)/2-1, 0]) cube(size=[bb_size, l_h+1, bb_size+5], center=true);
        translate([tp_w/-2, total_h/2-(l_h+1)/2+1, 0]) cube(size=[bb_size, l_h+1, bb_size+5], center=true);
        // right
        uvec_zbar_w = 2.2*mh_pitch+1.5*mh_out_dia;
        translate([tp_w/-2+uvec_zbar_w/2+5*mh_pitch-mh_out_dia/4, total_h/-2+(bb_size/2+1)/2-1, 0]) cube(size=[uvec_zbar_w, bb_size/2+1, bb_size+5], center=true);
        translate([tp_w/-2+uvec_zbar_w/2+5*mh_pitch-mh_out_dia/4, total_h/2-(bb_size/2+1)/2+1, 0]) cube(size=[uvec_zbar_w, bb_size/2+1, bb_size+5], center=true);
        r_h = 1.5*mh_pitch+mh_out_dia/2+0.5;
        translate([tp_w/2, total_h/-2 + r_h/2, 0]) cube(size=[bb_size, r_h, bb_size+5], center=true);
        translate([tp_w/2, total_h/2 - r_h/2, 0]) cube(size=[bb_size, r_h, bb_size+5], center=true);
        // tamper switch
        ts_w = 3*mh_pitch;
        translate([tp_w/2-bb_size, total_h/-2+ts_w/2+2.5*mh_pitch+mh_out_dia/2, 0]) cube(size=[bb_size, ts_w, bb_size+5], center=true);
    }
}

module left_zbar() {
    zbar_w = 2.5*mh_pitch+mh_out_dia/2 - 0.5;
    zbar_h = 2.5*mh_pitch + mh_out_dia/2 - 0.5;
    
    difference() {   
        // base shape
        union() {
            cube(size=[bb_size, bb_size, total_z]);
            cube(size=[zbar_w, bb_size, bb_size]);
            cube(size=[bb_size, zbar_h, bb_size]);
            translate([0, 0, total_z-bb_size]) cube(size=[zbar_w, bb_size, bb_size]);
            translate([0, 0, total_z-bb_size]) cube(size=[bb_size, zbar_h, bb_size]);
            
            // cover frames
            // front
            cube(size=[zbar_w, cover_frame_size, cover_frame_size+bb_size]);
            cube(size=[bb_size+cover_frame_size, cover_frame_size, total_z]);
            translate([0, 0, total_z-bb_size-cover_frame_size]) cube(size=[zbar_w, cover_frame_size, bb_size+cover_frame_size]);
            // side
            cube(size=[cover_frame_size, zbar_h, bb_size+cover_frame_size]);
            cube(size=[cover_frame_size, bb_size+cover_frame_size, total_z]);
            translate([0, 0, total_z-bb_size-cover_frame_size]) cube(size=[cover_frame_size, zbar_h, bb_size+cover_frame_size]);

        }

        // mount holes
        // bottom x
        translate([mh_out_dia/2 + 1*mh_pitch, bb_size+1, bb_size/2]) rotate(a=[90, 0, 0]) mounting_hole();
        translate([mh_out_dia/2 + 2*mh_pitch, bb_size+1, bb_size/2]) rotate(a=[90, 0, 0]) mounting_hole();
        // top x
        translate([mh_out_dia/2 + 1*mh_pitch, bb_size+1, total_z-bb_size/2]) rotate(a=[90, 0, 0]) mounting_hole();
        translate([mh_out_dia/2 + 2*mh_pitch, bb_size+1, total_z-bb_size/2]) rotate(a=[90, 0, 0]) mounting_hole();
        // bottom y
        translate([-1, mh_out_dia/2 + 1*mh_pitch, bb_size/2]) rotate(a=[90, 0, 90]) mounting_hole();
        translate([-1, mh_out_dia/2 + 2*mh_pitch, bb_size/2]) rotate(a=[90, 0, 90]) mounting_hole();
        // top y
        translate([-1, mh_out_dia/2 + 1*mh_pitch, total_z-bb_size/2]) rotate(a=[90, 0, 90]) mounting_hole();
        translate([-1, mh_out_dia/2 + 2*mh_pitch, total_z-bb_size/2]) rotate(a=[90, 0, 90]) mounting_hole();

        // cut sides
        translate([bb_size/2, bb_size/2, -1]) cube(size=[zbar_w, bb_size/2+1, , bb_size+1.5]);
        translate([bb_size/2, bb_size/2, -1]) cube(size=[bb_size/2+1, zbar_h, bb_size+1.5]);
        translate([bb_size/2, bb_size/2, total_z-bb_size-0.5]) cube(size=[zbar_w, bb_size/2+1, , bb_size+1.5]);
        translate([bb_size/2, bb_size/2, total_z-bb_size-0.5]) cube(size=[bb_size/2+1, zbar_h, bb_size+1.5]);

    }
}

module middle_zbar() {
    uvec_zbar_w = 2.2*mh_pitch+1.5*mh_out_dia-1;
    difference () {
        union() {
            // base
            translate([0, 0, 0]) cube(size=[bb_size, bb_size, total_z]);
            translate([5*mh_pitch-mh_out_dia/4 - bb_size - space_ec_w+0.5, 0, 0]) cube(size=[uvec_zbar_w, bb_size, bb_size]);
            translate([5*mh_pitch-mh_out_dia/4 - bb_size - space_ec_w+0.5, 0, total_z-bb_size]) cube(size=[uvec_zbar_w/2, bb_size, bb_size]);
            translate([5*mh_pitch-mh_out_dia/4 - bb_size - space_ec_w+0.5, 0, total_z-top_cover_z-bb_size]) difference() {
                union() {
                    cube(size=[uvec_zbar_w, bb_size, bb_size]);
                    // cover frame - front / uv / top
                    translate([0, 0, -cover_frame_size]) cube(size=[uvec_zbar_w, cover_frame_size, bb_size+cover_frame_size]);
                }
                translate([-1, -1, -1-cover_frame_size]) cube(size=[uvec_zbar_w/2, bb_size+2, bb_size+2+cover_frame_size]);
            }
            translate([0, 0, total_z-top_cover_z-bb_size]) cube(size=[bb_size, mh_pitch*1.5+mh_out_dia/2, bb_size]);
            translate([0, 0, total_z-bb_size]) cube(size=[bb_size, mh_pitch*1.5+mh_out_dia/2, bb_size]);
            
            // cover frames
            // bottom
            translate([5*mh_pitch-mh_out_dia/4 - bb_size - space_ec_w+0.5, 0, 0]) cube(size=[uvec_zbar_w, cover_frame_size, cover_frame_size+bb_size]);
            // front / ec
            translate([-cover_frame_size, 0, 0]) cube(size=[bb_size, cover_frame_size, total_z]);
            // front / ec /top
            translate([5*mh_pitch-mh_out_dia/4 - bb_size - space_ec_w+0.5, 0, total_z-bb_size-cover_frame_size]) cube(size=[uvec_zbar_w/2, cover_frame_size, cover_frame_size+bb_size]);
            // front / uv
            translate([0, 0, 0]) cube(size=[bb_size+cover_frame_size, cover_frame_size, total_z-top_cover_z]);
            // ec / uv space
            translate([bb_size - cover_frame_size, 0, 0]) cube(size=[cover_frame_size, bb_size+cover_frame_size, total_z]);
            // top insidec space
            
            translate([bb_size-cover_frame_size, 0, total_z-cover_frame_size-bb_size]) cube(size=[cover_frame_size, mh_pitch*1.5+mh_out_dia/2, cover_frame_size+bb_size]);
            
        }

        // mount holes
        // bottom
        translate([-space_ec_w-bb_size+mh_out_dia/2+5*mh_pitch, bb_size+1, bb_size/2]) rotate(a=[90, 0, 0]) mounting_hole();
        translate([-space_ec_w-bb_size+mh_out_dia/2+7.2*mh_pitch, bb_size+1, bb_size/2]) rotate(a=[90, 0, 0]) mounting_hole();
        // top x
        translate([-space_ec_w-bb_size+mh_out_dia/2+5*mh_pitch, bb_size+1, total_z-bb_size/2]) rotate(a=[90, 0, 0]) mounting_hole();
        // middle x
        translate([-space_ec_w-bb_size+mh_out_dia/2+7.2*mh_pitch, bb_size+1, total_z-top_cover_z-bb_size/2]) rotate(a=[90, 0, 0]) mounting_hole();
        // top y
        translate([-1, mh_out_dia/2+1*mh_pitch, total_z-bb_size/2]) rotate(a=[90, 0, 90]) mounting_hole();
        // middle y
        translate([-1, mh_out_dia/2+1*mh_pitch, total_z-top_cover_z-bb_size/2]) rotate(a=[90, 0, 90]) mounting_hole();
        
        // cut sides
        // bottom
        translate([5*mh_pitch-mh_out_dia/4 - bb_size - space_ec_w-1, bb_size/2, -1]) cube(size=[uvec_zbar_w+2, bb_size, bb_size+1.5]);
        // middle
        translate([bb_size/2, bb_size/2, total_z-top_cover_z-bb_size-0.5]) cube(size=[uvec_zbar_w, bb_size+1.5*mh_pitch, bb_size+1]);
        // top
        translate([-total_w, bb_size/2, total_z-bb_size-0.5]) cube(size=[total_w+bb_size/2, bb_size+1.5*mh_pitch, bb_size+2]);

    }
    
}

module right_zbar() {
    zbar_z = total_z - top_cover_z;
    zbar_w = 2.5*mh_pitch-mh_out_dia+(total_w-20.5*mh_pitch-mh_out_dia);
    zbar_h = 2.5*mh_pitch + mh_out_dia/2;
    
    difference() {
        // base zbar shape
        union() {
            cube(size=[bb_size, bb_size, zbar_z]);
            translate([-zbar_w+bb_size+0.5, 0, 0]) cube(size=[zbar_w-0.5, bb_size, bb_size]);
            cube(size=[bb_size, zbar_h-0.5, bb_size]);
            translate([-zbar_w+bb_size+0.5, 0, zbar_z-bb_size]) cube(size=[zbar_w-0.5, bb_size, bb_size]);
            translate([0, 0, zbar_z-bb_size]) cube(size=[bb_size, zbar_h-0.5, bb_size]);
            
            // cover frames
            translate([-zbar_w+bb_size+0.5, 0, 0]) cube(size=[zbar_w-0.5, cover_frame_size, bb_size+cover_frame_size]);
            translate([-zbar_w+bb_size+0.5, 0, zbar_z-bb_size-cover_frame_size]) cube(size=[zbar_w-0.5, cover_frame_size, bb_size+cover_frame_size]);
            translate([-cover_frame_size, 0, 0]) cube(size=[cover_frame_size+bb_size, cover_frame_size, zbar_z]);
            translate([bb_size-cover_frame_size, 0, 0]) cube(size=[cover_frame_size, bb_size+cover_frame_size, zbar_z]);
            translate([bb_size-cover_frame_size, 0, 0]) cube(size=[cover_frame_size, zbar_h-0.5, bb_size+cover_frame_size]);
            translate([bb_size-cover_frame_size, 0, zbar_z-bb_size-cover_frame_size]) cube(size=[cover_frame_size, zbar_h-0.5, bb_size+cover_frame_size]);
        }
        
        // mount holes
        // x z1
        translate([19.5*mh_pitch-(total_w-zbar_w)-zbar_w+bb_size+mh_out_dia/2, bb_size+1, bb_size/2]) rotate(a=[90, 0, 0]) mounting_hole();
        translate([20.5*mh_pitch-(total_w-zbar_w)-zbar_w+bb_size+mh_out_dia/2, bb_size+1, bb_size/2]) rotate(a=[90, 0, 0]) mounting_hole();
        // x z2
        translate([19.5*mh_pitch-(total_w-zbar_w)-zbar_w+bb_size+mh_out_dia/2, bb_size+1, bb_size/-2+zbar_z]) rotate(a=[90, 0, 0]) mounting_hole();
        translate([20.5*mh_pitch-(total_w-zbar_w)-zbar_w+bb_size+mh_out_dia/2, bb_size+1, bb_size/-2+zbar_z]) rotate(a=[90, 0, 0]) mounting_hole();
        // y z1
        translate([-1, mh_out_dia/2+1*mh_pitch, bb_size/2]) rotate(a=[90, 0, 90]) mounting_hole();
        translate([-1, mh_out_dia/2+2*mh_pitch, bb_size/2]) rotate(a=[90, 0, 90]) mounting_hole();
        // y z2
        translate([-1, mh_out_dia/2+1*mh_pitch, bb_size/-2+zbar_z]) rotate(a=[90, 0, 90]) mounting_hole();
        translate([-1, mh_out_dia/2+2*mh_pitch, bb_size/-2+zbar_z]) rotate(a=[90, 0, 90]) mounting_hole();
        
        // bottom split
        translate([-zbar_w-1, bb_size/2, -1]) cube(size=[zbar_w+1+bb_size/2, bb_size/2+1, bb_size+1.5]);
        translate([-1, bb_size/2, -1]) cube(size=[1+bb_size/2, zbar_h+1, bb_size+1.5]);
        translate([-zbar_w-1, bb_size/2, zbar_z-bb_size-1]) cube(size=[zbar_w+1+bb_size/2, bb_size/2+1, bb_size+1.5]);
        translate([-1, bb_size/2, zbar_z-bb_size-1]) cube(size=[1+bb_size/2, zbar_h+1, bb_size+1.5]);
    }
}

module bottom_plate(cut_side=1) {
    difference() {
        union() {
            difference() {
                cube(size=[total_w, total_h, bb_size], center=true);
                translate([total_w/-2+space_ec_w/2+bb_size, 0, 0]) cube(size=[space_ec_w, space_uv_h, bb_size+2], center=true);
                translate([total_w/2-space_uv_w/2-bb_size, 0, 0]) cube(size=[space_uv_w, space_uv_h, bb_size+2], center=true);
                
                // mounting holes              
                for (i = mh_x_positions) {
                    translate([total_w/-2 + mh_out_dia/2 + i*mh_pitch, total_h/-2+bb_size+1, 0]) rotate(a=[90, 0, 0]) mounting_hole();
                    translate([total_w/-2 + mh_out_dia/2 + i*mh_pitch, total_h/2+1, 0]) rotate(a=[90, 0, 0]) mounting_hole();
                }
                for (i = mh_y_positions) {
                    translate([total_w/-2-1, total_h/-2+mh_out_dia/2 + i*mh_pitch, 0]) rotate(a=[90, 0, 90]) mounting_hole();
                    translate([total_w/-2-1+bb_size+space_ec_w, total_h/-2+mh_out_dia/2 + i*mh_pitch, 0]) rotate(a=[90, 0, 90]) mounting_hole();
                    translate([total_w/2-1-bb_size, total_h/-2+mh_out_dia/2 + i*mh_pitch, 0]) rotate(a=[90, 0, 90]) mounting_hole();
                }
            }
            
            // frames for covers
            translate([0, total_h/-2+(bb_size+cover_frame_size)/2, bb_size/-2+cover_frame_size/2]) cube(size=[total_w, bb_size+cover_frame_size, cover_frame_size], center=true);
            translate([0, total_h/2-(bb_size+cover_frame_size)/2, bb_size/-2+cover_frame_size/2]) cube(size=[total_w, bb_size+cover_frame_size, cover_frame_size], center=true);
            translate([total_w/-2+(bb_size+cover_frame_size)/2, 0, bb_size/-2+cover_frame_size/2]) cube(size=[bb_size+cover_frame_size, total_h, cover_frame_size], center=true);
            translate([total_w/2-(bb_size+cover_frame_size)/2, 0, bb_size/-2+cover_frame_size/2]) cube(size=[bb_size+cover_frame_size, total_h, cover_frame_size], center=true);
            translate([total_w/-2+(bb_size+2*cover_frame_size)/2+space_ec_w+bb_size-cover_frame_size, 0, bb_size/-2+cover_frame_size/2]) cube(size=[bb_size+2*cover_frame_size, total_h, cover_frame_size], center=true);
            translate([0, total_h/-2+cover_frame_size/2, bb_size/2+(cover_frame_size+1)/2-1]) cube(size=[total_w, cover_frame_size, 1+cover_frame_size], center=true);
            translate([0, total_h/2-cover_frame_size/2, bb_size/2+(cover_frame_size+1)/2-1]) cube(size=[total_w, cover_frame_size, 1+cover_frame_size], center=true);
            translate([total_w/-2+cover_frame_size/2, 0, bb_size/2+(cover_frame_size+1)/2-1]) cube(size=[cover_frame_size, total_h, 1+cover_frame_size], center=true);
            translate([total_w/2-cover_frame_size/2, 0, bb_size/2+(cover_frame_size+1)/2-1]) cube(size=[cover_frame_size, total_h, 1+cover_frame_size], center=true);
        }
        
        // cutting sides for mounting Z bars
        // LF corner
        lf1_w = 2.5*mh_pitch+mh_out_dia/2;
        translate([total_w/-2+(lf1_w+1)/2-1, total_h/-2+(bb_size/2+1)/2-1, 0]) cube(size=[lf1_w+1, bb_size/2+1, bb_size+5], center=true);
        lf1_h = 2.5*mh_pitch + mh_out_dia/2;
        translate([total_w/-2+(bb_size/2+1)/2-1, total_h/-2+(lf1_h+1)/2-1, 0]) cube(size=[bb_size/2+1, lf1_h+1, bb_size+5], center=true);
        // LB corner
        translate([total_w/-2+(lf1_w+1)/2-1, total_h/2-(bb_size/2+1)/2+1, 0]) cube(size=[lf1_w+1, bb_size/2+1, bb_size+5], center=true);
        translate([total_w/-2+(bb_size/2+1)/2-1, total_h/2-(lf1_h+1)/2+1, 0]) cube(size=[bb_size/2+1, lf1_h+1, bb_size+5], center=true);
        // RF corner
        rf1_w = 2.5*mh_pitch-mh_out_dia+(total_w-20.5*mh_pitch-mh_out_dia);
        translate([total_w/2-(rf1_w+1)/2+1, total_h/-2+(bb_size/2+1)/2-1, 0]) cube(size=[rf1_w+1, bb_size/2+1, bb_size+5], center=true);
        translate([total_w/2-(bb_size/2+1)/2+1, total_h/-2+(lf1_h+1)/2-1, 0]) cube(size=[bb_size/2+1, lf1_h+1, bb_size+5], center=true);
        // RB corner
        translate([total_w/2-(rf1_w+1)/2+1, total_h/2-(bb_size/2+1)/2+1, 0]) cube(size=[rf1_w+1, bb_size/2+1, bb_size+5], center=true);
        translate([total_w/2-(bb_size/2+1)/2+1, total_h/2-(lf1_h+1)/2+1, 0]) cube(size=[bb_size/2+1, lf1_h+1, bb_size+5], center=true);
        
        // UV / EC Z bar
        uvec_zbar_w = 2.2*mh_pitch+1.5*mh_out_dia;
        translate([total_w/-2+uvec_zbar_w/2+5*mh_pitch-mh_out_dia/4, total_h/-2+(bb_size/2+1)/2-1, 0]) cube(size=[uvec_zbar_w, bb_size/2+1, bb_size+5], center=true);
        translate([total_w/-2+uvec_zbar_w/2+5*mh_pitch-mh_out_dia/4, total_h/2-(bb_size/2+1)/2+1, 0]) cube(size=[uvec_zbar_w, bb_size/2+1, bb_size+5], center=true);
        
        // split on two parts
        cut_margin_r = 19+mh_pitch/2;
        cut_margin_l = 13+mh_pitch/2;
        if(cut_side==1) {            
            translate([total_w/2+cut_margin_r, 0, 0]) cube(size=[total_w, total_h+2, bb_size+5], center=true);
            translate([total_w/2-cut_margin_l, 0, 0]) cube(size=[total_w, total_h-bb_size, total_z+5], center=true);
        }
        else {
            translate([total_w/-2-cut_margin_l, 0, 0]) cube(size=[total_w, total_h+2, bb_size+5], center=true);
            translate([total_w/-2+cut_margin_r, -total_h+bb_size/2, 0]) cube(size=[total_w, total_h, total_z+5], center=true);
            translate([total_w/-2+cut_margin_r, total_h-bb_size/2, 0]) cube(size=[total_w, total_h, total_z+5], center=true);
        }
        
    }
    
    
    
}

module mounting_hole() {
    cylinder(d=mh_inner_dia, h=bb_size+2, $fn=100);
    cylinder(d=mh_out_dia, h=mh_out_h+1, $fn=100);
    translate([0, 0, bb_size+1-mh_out_h]) cylinder(d=mh_out_dia, h=mh_out_h+1, $fn=100);
}