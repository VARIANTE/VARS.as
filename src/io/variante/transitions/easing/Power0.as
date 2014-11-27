/**
 *  (c) VARIANTE <http://variante.io>
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.transitions.easing
{
    import com.greensock.easing.Ease;
    import com.greensock.easing.Power0;

    /**
     * Wrapper class for Power0 easing.
     */
    public class Power0
    {
        /**
         * @see com.greensock.easing.Power0#easeOut
         */
        public static var easeOut:Ease = com.greensock.easing.Power0.easeOut;

        /**
         * @see com.greensock.easing.Power0#easeIn
         */
        public static var easeIn:Ease = com.greensock.easing.Power0.easeIn;

        /**
         * @see com.greensock.easing.Power0#easeInOut
         */
        public static var easeInOut:Ease = com.greensock.easing.Power0.easeInOut;
    }
}
