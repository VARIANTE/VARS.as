/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.transitions.easing
{
    import com.greensock.easing.Ease;
    import com.greensock.easing.Power2;

    /**
     * Wrapper class for Power2 easing.
     */
    public class Power2
    {
        /**
         * @see com.greensock.easing.Power2#easeOut
         */
        public static var easeOut:Ease = com.greensock.easing.Power2.easeOut;

        /**
         * @see com.greensock.easing.Power2#easeIn
         */
        public static var easeIn:Ease = com.greensock.easing.Power2.easeIn;

        /**
         * @see com.greensock.easing.Power2#easeInOut
         */
        public static var easeInOut:Ease = com.greensock.easing.Power2.easeInOut;
    }
}

