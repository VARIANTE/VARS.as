/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.transitions.easing
{
    import com.greensock.easing.Ease;
    import com.greensock.easing.Linear;

    /**
     * Wrapper class for Linear easing.
     */
    public class Linear
    {
        /**
         * @see com.greensock.easing.Linear#easeNone
         */
        public static var easeNone:Ease = com.greensock.easing.Linear.easeNone;

        /**
         * @see com.greensock.easing.Linear#ease
         */
        public static var ease:Ease = com.greensock.easing.Linear.ease;

        /**
         * @see com.greensock.easing.Linear#easeOut
         */
        public static var easeOut:Ease = com.greensock.easing.Linear.easeOut;

        /**
         * @see com.greensock.easing.Linear#easeIn
         */
        public static var easeIn:Ease = com.greensock.easing.Linear.easeIn;

        /**
         * @see com.greensock.easing.Linear#easeInOut
         */
        public static var easeInOut:Ease = com.greensock.easing.Linear.easeInOut;
    }
}
