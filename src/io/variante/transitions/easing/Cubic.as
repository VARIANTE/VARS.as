/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.transitions.easing
{
    import com.greensock.easing.Cubic;
    import com.greensock.easing.Ease;

    /**
     * Wrapper class for Cubic easing.
     */
    public class Cubic
    {
        /**
         * @see com.greensock.easing.Cubic#easeOut
         */
        public static var easeOut:Ease = com.greensock.easing.Cubic.easeOut;

        /**
         * @see com.greensock.easing.Cubic#easeIn
         */
        public static var easeIn:Ease = com.greensock.easing.Cubic.easeIn;

        /**
         * @see com.greensock.easing.Cubic#easeInOut
         */
        public static var easeInOut:Ease = com.greensock.easing.Cubic.easeInOut;
    }
}
