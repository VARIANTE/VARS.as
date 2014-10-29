/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.transitions.easing
{
    import com.greensock.easing.Ease;
    import com.greensock.easing.Expo;

    /**
     * Wrapper class for Expo easing.
     */
    public class Expo
    {
        /**
         * @see com.greensock.easing.Expo#easeOut
         */
        public static var easeOut:Ease = com.greensock.easing.Expo.easeOut;

        /**
         * @see com.greensock.easing.Expo#easeIn
         */
        public static var easeIn:Ease = com.greensock.easing.Expo.easeIn;

        /**
         * @see com.greensock.easing.Expo#easeInOut
         */
        public static var easeInOut:Ease = com.greensock.easing.Expo.easeInOut;
    }
}
