/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.transitions.easing
{
    import com.greensock.easing.Ease;
    import com.greensock.easing.Elastic;

    /**
     * Wrapper class for Elastic easing.
     */
    public class Elastic
    {
        /**
         * @see com.greensock.easing.Elastic#easeOut
         */
        public static var easeOut:Ease = com.greensock.easing.Elastic.easeOut;

        /**
         * @see com.greensock.easing.Elastic#easeIn
         */
        public static var easeIn:Ease = com.greensock.easing.Elastic.easeIn;

        /**
         * @see com.greensock.easing.Elastic#easeInOut
         */
        public static var easeInOut:Ease = com.greensock.easing.Elastic.easeInOut;
    }
}
