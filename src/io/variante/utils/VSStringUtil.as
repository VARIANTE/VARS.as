/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.utils
{
    /**
     * Utility class for String objects.
     */
    public class VSStringUtil
    {
        /**
         * Returns a copy of a string with the specified character filtered, option to make the output string camel case (lower/upper).
         *
         * @param $string
         * @param $filterChar
         * @param $useCamelCase
         * @param $useUpperCamelCase
         *
         * @return A copy of the string with the specified character filtered, option to make the output string camel case (lower/upper)
         */
        public static function filter($string:String, $filterChar:String, $useCamelCase:Boolean = false, $upperCamelCase:Boolean = false):String
        {
            VSAssert.assert($filterChar != null && $filterChar.length == 1, 'Invalid $filterChar specified.');

            var a:Array = $string.split($filterChar);
            var l:uint = a.length;

            for (var i:uint = 0; i < l; i++)
            {
                var v:String = a[i];

                if ($useCamelCase || $upperCamelCase)
                {
                    if ((i == 0 && $upperCamelCase) || (i > 0))
                    {
                        v = v.charAt(0).toUpperCase() + v.substring(1, v.length);
                    }

                    a[i] = v;
                }
            }

            return a.join('');
        }

        /**
         * Gets the file name extension from a file name.
         *
         * @param $filename
         *
         * @return The file name extension. Null if no extensions are found.
         */
        public static function getFileExtension($fileName:String):String
        {
            var i:int = $fileName.lastIndexOf('.');
            var l:int = $fileName.length;

            if (i == -1)
            {
                return null;
            }

            return ($fileName.substring(i + 1, l));
        }
    }
}
