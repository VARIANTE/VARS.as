/**
 *  (c) VARIANTE <http://variante.io>
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.transitions.easing
{
    import com.greensock.easing.Ease;
    import com.greensock.easing.Quad;

    /**
     * Wrapper class for Quad easing.
     */
    public class Quad
    {
        /**
         * @see com.greensock.easing.Quad#easeOut
         */
        public static var easeOut:Ease = com.greensock.easing.Quad.easeOut;

        /**
         * @see com.greensock.easing.Quad#easeIn
         */
        public static var easeIn:Ease = com.greensock.easing.Quad.easeIn;

        /**
         * @see com.greensock.easing.Quad#easeInOut
         */
        public static var easeInOut:Ease = com.greensock.easing.Quad.easeInOut;
    }
}

