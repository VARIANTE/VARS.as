/**
 *  (c) VARIANTE <http://variante.io>
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.enums
{
    /**
     * A set of default types that can be used to identify dirty properties
     * of a display object.
     */
    public class VSDirtyType
    {
        /**
         * Change in visual properties that are related to the overall dimension of the display object.
         * i.e. width, height, scaleX, scaleY
         */
        public static const DIMENSION:uint = 0;

        /**
         * Change in visual properties that are related to the position of the display object.
         * i.e. x, y, z
         */
        public static const POSITION:uint = 1;

        /**
         * Change in depth of the display object its parent's display list.
         */
        public static const DEPTH:uint = 2;

        /**
         * Change in visual properties that are related to the overall shape of the display object.
         */
        public static const SHAPE:uint = 3;

        /**
         * Change in internal state of the display object.
         * i.e. A button that is selected/highlighted/enabled, etc.
         */
        public static const STATE:uint = 4

        /**
         * Change in view of a display object.
         * i.e. A button's idle view, highlighted view, selected view, etc.
         */
        public static const VIEW:uint = 5;

        /**
         * Change in child display objects.
         */
        public static const CHILDREN:uint = 6;

        /**
         * Change in data of a display object.
         */
        public static const DATA:uint = 7;

        /**
         * Change in stage size.
         */
        public static const STAGE:uint = 8;

        /**
         * Change in any custom properties.
         */
        public static const CUSTOM:uint = 9;

        /**
         * Maximum number of dirty types.
         */
        public static const MAX_TYPES:uint = 10;
    }
}
