/***********************************************************
 * Simple ISO Thread Module - vsergeev
 * https://github.com/vsergeev/3d-simple-iso-thread
 * CC-BY-4.0
 *
 * Release Notes
 *  * v1.0 - 06/24/2020
 *      * Initial release.
 **********************************************************/

module simple_iso_thread(diameter, pitch, height, type="external", chamfer_top=0, chamfer_bottom=0, clearance=0.05, fragments=100) {
    assert(type == "external" || type == "internal", "Unknown thread type: should be \"external\" or \"internal\".");

    /* Scale factor from clearance */
    scale_factor = (type == "external") ? (1 - clearance) : (1 + clearance);

    /* Major and minor radiuses */
    h = pitch / (2 * tan(30));
    r_maj = (diameter / 2) * scale_factor;
    r_min = (diameter / 2 - (5 * h / 8)) * scale_factor;

    /* Major and minor widths */
    w_maj = (pitch / 8) * scale_factor;
    w_min = (pitch / 4) * scale_factor;

    /* Total degrees to turn thread */
    degrees = (height / pitch) * 360;

    /* Overlap epsilon for clean differences */
    overlap_epsilon = 0.01;

    intersection() {
        difference() {
            union() {
                /* Threads with additional 360 degrees above and below */
                for (d = [-360:360 / fragments:degrees + 360]) {
                    translate([0, 0, d * (pitch / 360)])
                        rotate(d)
                            rotate_extrude(angle = 360 / fragments + overlap_epsilon)
                                polygon([
                                    [0, pitch / 2 + overlap_epsilon],
                                    [r_min, pitch / 2],
                                    [r_min, pitch / 2 - w_min / 2],
                                    [r_maj, w_maj / 2],
                                    [r_maj, -w_maj / 2],
                                    [r_min, -(pitch / 2 - w_min / 2)],
                                    [r_min, -pitch / 2],
                                    [0, -pitch / 2 - overlap_epsilon]
                                ]);
                }

                /* Fill center to remove artifacts from internal threads */
                if (type == "internal")
                    cylinder(h = height, r = r_min / 2);

                /* Bottom chamfer profile for internal threads (added) */
                if (type == "internal" && chamfer_bottom > 0) {
                    rotate_extrude()
                        polygon([
                            [0, chamfer_bottom],
                            [r_maj, chamfer_bottom],
                            [r_maj + chamfer_bottom, 0],
                            [r_maj + chamfer_bottom, -overlap_epsilon],
                            [0, -overlap_epsilon]
                        ]);
                }

                /* Top chamfer profile for internal threads (added) */
                if (type == "internal" && chamfer_top > 0) {
                    rotate_extrude()
                        polygon([
                            [0, height + overlap_epsilon],
                            [r_maj + chamfer_top, height + overlap_epsilon],
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
                        [r_maj - chamfer_bottom, -overlap_epsilon],
                        [r_maj + chamfer_bottom, -overlap_epsilon],
                        [r_maj + chamfer_bottom, chamfer_bottom * 2]
                    ]);
            }

            /* Top chamfer profile for external threads (subtracted) */
            if (type == "external" && chamfer_top > 0) {
                rotate_extrude()
                    polygon([
                        [r_maj - chamfer_top, height + overlap_epsilon],
                        [r_maj + chamfer_top, height + overlap_epsilon],
                        [r_maj + chamfer_top, height - chamfer_top * 2]
                    ]);
            }
        }

        /* Bounding cylinder (intersected) */
        if (type == "internal")
            translate([0, 0, -overlap_epsilon / 2])
                cylinder(h = height + overlap_epsilon, r = r_maj + max(chamfer_top, chamfer_bottom));
        else
            cylinder(h = height, r = r_maj);
    }
}
