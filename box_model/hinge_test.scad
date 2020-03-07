$fn=100;

screw_dia = 3.5;
screw_head = 8;
h_size = 4;
l_part = 36;
s_part = 30;
pitch = 15;

difference() {
	union() {
		import("hinge_test_part1.stl");
		import("hinge_test_part2.stl");
	}
		translate([l_part/2-7.5+2, pitch/2, -h_size-1]) cylinder(d=screw_dia, h=h_size*2);
		translate([l_part/2-7.5+2, pitch/-2, -h_size-1]) cylinder(d=screw_dia, h=h_size*2);
		translate([s_part/-2+(s_part/2-h_size)/2, pitch/2, -h_size-1]) cylinder(d=screw_dia, h=h_size*2);
		translate([s_part/-2+(s_part/2-h_size)/2, pitch/-2, -h_size-1]) cylinder(d=screw_dia, h=h_size*2);

		translate([l_part/2-7.5+2, pitch/2, h_size/-2]) cylinder(d=screw_head, h=h_size*2);
		translate([l_part/2-7.5+2, pitch/-2, h_size/-2]) cylinder(d=screw_head, h=h_size*2);
		translate([s_part/-2+(s_part/2-h_size)/2, pitch/2, h_size*-1.5]) cylinder(d=screw_head, h=h_size);
		translate([s_part/-2+(s_part/2-h_size)/2, pitch/-2, h_size*-1.5]) cylinder(d=screw_head, h=h_size);
}