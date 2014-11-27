/**
 *  (c) VARIANTE <http://variante.io>
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.transitions.easing
{
    import com.greensock.easing.Back;
    import com.greensock.easing.Ease;

    /**
     * Wrapper class for Back easing.
     */
    public class Back
    {
        /**
         * @see com.greensock.easing.Back#easeOut
         */
        public static var easeOut:Ease = com.greensock.easing.Back.easeOut;

        /**
         * @see com.greensock.easing.Back#easeIn
         */
        public static var easeIn:Ease = com.greensock.easing.Back.easeIn;

        /**
         * @see com.greensock.easing.Back#easeInOut
         */
        public static var easeInOut:Ease = com.greensock.easing.Back.easeInOut;
    }
}

