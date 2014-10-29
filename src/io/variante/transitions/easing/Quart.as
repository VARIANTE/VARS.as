/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.transitions.easing
{
    import com.greensock.easing.Ease;
    import com.greensock.easing.Quart;

    /**
     * Wrapper class for Quart easing.
     */
    public class Quart
    {
        /**
         * @see com.greensock.easing.Quart#easeOut
         */
        public static var easeOut:Ease = com.greensock.easing.Quart.easeOut;

        /**
         * @see com.greensock.easing.Quart#easeIn
         */
        public static var easeIn:Ease = com.greensock.easing.Quart.easeIn;

        /**
         * @see com.greensock.easing.Quart#easeInOut
         */
        public static var easeInOut:Ease = com.greensock.easing.Quart.easeInOut;
    }
}

