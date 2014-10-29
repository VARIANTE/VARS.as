/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.transitions.easing
{
    import com.greensock.easing.Bounce;
    import com.greensock.easing.Ease;

    /**
     * Wrapper class for Bounce easing.
     */
    public class Bounce
    {
        /**
         * @see com.greensock.easing.Bounce#easeOut
         */
        public static var easeOut:Ease = com.greensock.easing.Bounce.easeOut;

        /**
         * @see com.greensock.easing.Bounce#easeIn
         */
        public static var easeIn:Ease = com.greensock.easing.Bounce.easeIn;

        /**
         * @see com.greensock.easing.Bounce#easeInOut
         */
        public static var easeInOut:Ease = com.greensock.easing.Bounce.easeInOut;
    }
}
