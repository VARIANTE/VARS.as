/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.utils
{
    /**
     * Utility class for handling assertions.
     */
    public class VSAssert
    {
        /**
         * Asserts that an expression is true.
         *
         * @param $expression
         * @param $message
         */
        public static function assert($expression:Boolean, $message:String):void
        {
            if ($expression == false)
            {
                throw new Error($message);
            }
        }

        /**
         * Throws a new <code>Error</code> with a message.
         *
         * @param $message
         */
        public static function panic($message:String):void
        {
            throw new Error($message);
        }
    }
}
