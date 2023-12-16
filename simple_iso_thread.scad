/***********************************************************
 * Simple ISO Thread Module - vsergeev
 * https://github.com/vsergeev/3d-simple-iso-thread
 * CC-BY-4.0
 *
 * Release Notes
 *  * v1.0 - 06/24/2020
 *      * Initial release.
 **********************************************************/

module simple_iso_thread(diameter, pitch, height, type="external", chamfer_top=0, chamfer_bottom=0, fragments=100) {
    assert(type == "external" || type == "internal", "Unknown thread type: should be \"external\" or \"internal\".");

    h = pitch / (2 * tan(30));

    /* Clearances from ideal for major and minor radiuses */
    c_maj = (type == "external") ? -(h / 8) : (h / 8);
    c_min = (type == "external") ? -(h / 8) : (h / 8);

    /* Major and minor radiuses */
    r_maj = diameter / 2 + c_maj;
    r_min = diameter / 2 - (5 * h / 8) + c_min;

    /* Major and minor widths, with scaling for additional clearance */
    w_maj = 2 * tan(30) * (h / 8 - c_maj) * (type == "external" ? 0.75 : 1);
    w_min = 2 * tan(30) * (h / 4 + c_min) * (type == "external" ? 1 : 0.50);

    /* Total degrees to turn thread */
    degrees = (height / pitch) * 360;

    intersection() {
        difference() {
            union() {
                /* Threads with additional 360 degrees above and below */
                for (d = [-360:360 / fragments:degrees + 360]) {
                    translate([0, 0, d * (pitch / 360)])
                        rotate(d)
                            rotate_extrude(angle = 360 / fragments)
                                polygon([
                                    [0, pitch / 2],
                                    [r_min, pitch / 2],
                                    [r_min, pitch / 2 - w_min / 2],
                                    [r_maj, w_maj / 2],
                                    [r_maj, -w_maj / 2],
                                    [r_min, -(pitch / 2 - w_min / 2)],
                                    [r_min, -pitch / 2],
                                    [0, -pitch / 2]
                                ]);
                }

                /* Bottom chamfer profile for internal threads (added) */
                if (type == "internal" && chamfer_bottom > 0) {
                    rotate_extrude()
                        polygon([
                            [0, chamfer_bottom],
                            [r_maj, chamfer_bottom],
                            [r_maj + chamfer_bottom, 0],
                            [r_maj + chamfer_bottom, -chamfer_bottom],
                            [0, -chamfer_bottom]
                        ]);
                }
                /* Top chamfer profile for internal threads (added) */
                if (type == "internal" && chamfer_top > 0) {
                    rotate_extrude()
                        polygon([
                            [0, height + chamfer_top],
                            [r_maj + chamfer_top, height + chamfer_top],
                            [r_maj + chamfer_top, height],
                            [r_maj, height - chamfer_top],
                            [0, height - chamfer_top]
                        ]);
                }
            }

            /* Bottom chamfer profile for external threads (subtracted) */
            if (type == "external" && chamfer_bottom > 0) {
                rotate_extrude()
                    polygon([
                        [r_maj - 1.5 * chamfer_bottom, -chamfer_bottom / 2],
                        [r_maj + chamfer_bottom / 2, -chamfer_bottom / 2],
                        [r_maj + chamfer_bottom / 2, 1.5 * chamfer_bottom]
                    ]);
            }
            /* Top chamfer profile for external threads (subtracted) */
            if (type == "external" && chamfer_top > 0) {
                rotate_extrude()
                    polygon([
                        [r_maj - 1.5 * chamfer_top, height + chamfer_top / 2],
                        [r_maj + chamfer_top / 2, height + chamfer_top / 2],
                        [r_maj + chamfer_top / 2, height - 1.5 * chamfer_top]
                    ]);
            }
        }

        /* Bounding cylinder (intersected) */
        if (type == "internal")
            translate([0, 0, -chamfer_bottom])
                cylinder(h = height + chamfer_top + chamfer_bottom, r = r_maj * 2);
        else
            cylinder(h = height, r = r_maj * 2);
    }
}
