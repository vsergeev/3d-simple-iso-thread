include <simple_iso_thread.scad>

$fn = $preview ? 0 : 50;
fragments = $preview ? 5 : 100;

module hexagon(width) {
    polygon([
        [-width / 2, 0], [-width / 2, (width / 2) * tan(30)],
        [0, width * tan(30)], [width / 2, (width / 2) * tan(30)],
        [width / 2, 0], [width / 2, -(width / 2) * tan(30)],
        [0, -width * tan(30)], [-width / 2, -(width / 2) * tan(30)]
    ]);
}

/* M6-1x12 Bolt */
union() {
    translate([0, 0, 12]) linear_extrude(4) hexagon(10);
    translate([0, 0, 11.5]) cylinder(h=0.5, d=6);
    simple_iso_thread(6, 1, 12, type="external", chamfer_top=0, chamfer_bottom=0.5, fragments=fragments);
}

/* M6-1 Nut */
translate([20, 0, 0]) difference() {
    linear_extrude(5) hexagon(10);
    simple_iso_thread(6, 1, 5, type="internal", chamfer_top=0.5, chamfer_bottom=0.5, fragments=fragments);
}

/* M10-1.5x16 Bolt */
translate([0, 20, 0]) union() {
    translate([0, 0, 16]) linear_extrude(6.4) hexagon(16);
    translate([0, 0, 15.5]) cylinder(h=0.5, d=10);
    simple_iso_thread(10, 1.5, 16, type="external", chamfer_top=0, chamfer_bottom=0.5, fragments=fragments);
}

/* M10-1.5 Nut */
translate([20, 20, 0]) difference() {
    linear_extrude(8) hexagon(16);
    simple_iso_thread(10, 1.5, 8, type="internal", chamfer_top=0.5, chamfer_bottom=0.5, fragments=fragments);
}
