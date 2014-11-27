/**
 *  (c) VARIANTE <http://variante.io>
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.transitions.easing
{
    import com.greensock.easing.Circ;
    import com.greensock.easing.Ease;

    /**
     * Wrapper class for Circ easing.
     */
    public class Circ
    {
        /**
         * @see com.greensock.easing.Circ#easeOut
         */
        public static var easeOut:Ease = com.greensock.easing.Circ.easeOut;

        /**
         * @see com.greensock.easing.Circ#easeIn
         */
        public static var easeIn:Ease = com.greensock.easing.Circ.easeIn;

        /**
         * @see com.greensock.easing.Circ#easeInOut
         */
        public static var easeInOut:Ease = com.greensock.easing.Circ.easeInOut;
    }
}

