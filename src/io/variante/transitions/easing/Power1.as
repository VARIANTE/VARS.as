/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.transitions.easing
{
    import com.greensock.easing.Ease;
    import com.greensock.easing.Power1;

    /**
     * Wrapper class for Power1 easing.
     */
    public class Power1
    {
        /**
         * @see com.greensock.easing.Power1#easeOut
         */
        public static var easeOut:Ease = com.greensock.easing.Power1.easeOut;

        /**
         * @see com.greensock.easing.Power1#easeIn
         */
        public static var easeIn:Ease = com.greensock.easing.Power1.easeIn;

        /**
         * @see com.greensock.easing.Power1#easeInOut
         */
        public static var easeInOut:Ease = com.greensock.easing.Power1.easeInOut;
    }
}
