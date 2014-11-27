/**
 *  (c) VARIANTE <http://variante.io>
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.transitions.easing
{
    import com.greensock.easing.Ease;
    import com.greensock.easing.Power3;

    /**
     * Wrapper class for Power3 easing.
     */
    public class Power3
    {
        /**
         * @see com.greensock.easing.Power3#easeOut
         */
        public static var easeOut:Ease = com.greensock.easing.Power3.easeOut;

        /**
         * @see com.greensock.easing.Power3#easeIn
         */
        public static var easeIn:Ease = com.greensock.easing.Power3.easeIn;

        /**
         * @see com.greensock.easing.Power3#easeInOut
         */
        public static var easeInOut:Ease = com.greensock.easing.Power3.easeInOut;
    }
}

