// RAMPS mount underneath TS rails
// TODO: cable guides?
// TODO: fan mount?

// mounting holes from http://www.adafruit.com/datasheets/arduino_hole_dimensions.pdf
// also see http://www.wayneandlayne.com/blog/2010/12/19/nice-drawings-of-the-arduino-uno-and-mega-2560/
arduino_length = 102;
arduino_depth = 54;
arduino_hole_positions = [
	[15.2,50.8],
	[90.2,50.8],
	[66.0,35.6],
	[66.0,7.6],
	[14,2.5],
	[96.5,2.5]];
arduino_hole_radius = 3.3/2;

module arduino_indents(padding=1) {
	height=20;
	padding2=padding*2;
	cable_length = 50;
	cable_height = 15;
	
	boss_diameter = 5.5;
	boss_height = 2;
	
	difference() {
		union() {
			translate([-padding,-padding]) {
				// room for entire arduino mega
				cube([101.8+padding2,53.3+padding2,height]);
				// extra room for barrel jack
				translate([-2,3.1]) cube([10+padding2,9+padding2,height]);
				// extra room for USB connector
				translate([-6.4,32]) cube([10+padding2,12+padding2,height]);
			}
			// extra room for USB cable
			translate([-6.4-cable_length,32-padding-2]) cube([1+cable_length,12+padding+4,cable_height]);
		}
		
		translate([0,0,-1]) for (p = arduino_hole_positions) {
			translate(p) cylinder(h=boss_height+1,r=0.5*boss_diameter);
		}

	}
}

bottom_thickness = 4;
bottom_float = 1.5; // distance above bottom of extrusion

bottom_extra_a = 28;
bottom_extra_b = 10;
bottom_extra_width = 110;
bottom_extra_thickness = 3;

side_thickness = 0;
extrusion_center_spacing = 155.5;
extrusion_mounting_hole_width = 5.5;



module ramps_mount() {
	difference() {
		union() {
			// Box around arduino
			cube([arduino_length+2*side_thickness,2*side_thickness+arduino_depth,20-bottom_float]);

			// bigger box around arduino
			translate([-0.5*((20+extrusion_center_spacing) -(arduino_length+2*side_thickness)),0,0]) cube([20+extrusion_center_spacing,2*side_thickness+arduino_depth,20-bottom_float]);
			
			// bottom extra flat space
			translate([-0.5*((bottom_extra_width) -(arduino_length+2*side_thickness)),-bottom_extra_a,0]) cube([bottom_extra_width,2*side_thickness+arduino_depth+bottom_extra_a+bottom_extra_b,bottom_extra_thickness]);
		}
		
		// mounting holes
		translate([-0.5*((20+extrusion_center_spacing) -(arduino_length+2*side_thickness)),0.5*(2*side_thickness+arduino_depth),0])
		for (side = [-1,1]) {
			translate([0.5*(extrusion_center_spacing+20)
			+side*0.5*(extrusion_center_spacing+20)
			,0,0])
			{
				#translate([-side*10,0,0.5*(20-bottom_float)-4]) cube([20-3,2*side_thickness+arduino_depth-3,20-bottom_float],center=true);
				
				for (slot=[-0.33,0.33]) {
					#translate([-side*10,slot*(2*side_thickness+arduino_depth),0.5*(20-bottom_float)+1]) cube([20-3,extrusion_mounting_hole_width,20-bottom_float],center=true);
				}
			}
		}
		
		// randomly spaced holes
		// distances happen to be good for mounting 40mm fan
		for (ystart = [-bottom_extra_a,arduino_depth+2*side_thickness]) 
		{
			translate([0.5*(arduino_length+2*side_thickness),ystart,0])
			for (xoffset = [-48:16:48]) {
				for (yoffset = [5:12:20]) {
					translate([xoffset,yoffset,0]) cylinder(r=1.6,h=20,center=true);
				}
			}
		}
		
		// arduino indents
		translate([arduino_length+side_thickness-8,arduino_depth+side_thickness,bottom_thickness]) rotate([0,0,180]) {
			arduino_indents();

			translate([0,0,-10]) for (p = arduino_hole_positions) {
				translate(p) cylinder(h=100,r=arduino_hole_radius,$fn=8);
			}
			
			// captive hex nuts
			translate([0,0,-bottom_thickness-1]) for (p = arduino_hole_positions) {
				translate(p) {
					cylinder(h=2.2+1,r=6.2/2,$fn=6);
					// Encourage useful bottom hex holes by allowing straighter bridges
					translate([0,0,2.2+1]) cube(size=[6.2*sin(30),6.2*cos(30),1.0],center=true);
				}
			}
		}
	}
}

if (0) {
	// assembly preview
	
	// extrusion
	color("silver") translate([-100,-20,0]) cube([200,20,20]);

	translate([-.5*arduino_length-side_thickness,0,bottom_float])
	ramps_mount();
} else {
	// for printing
	ramps_mount();
}