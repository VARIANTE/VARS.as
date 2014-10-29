/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.utils
{
    /**
     * Utility class for Array objects.
     */
    public class VSArrayUtil
    {
        /**
         * Returns a copy of a linear Array object with duplicated elements removed.
         *
         * @param $array
         *
         * @return A copy of the linear Array object with duplicated elements removed.
         */
        public static function removeDuplicatesOf($array:Array):Array
        {
            var l:uint = $array.length;
            var o:Array = new Array();

            for (var i:uint = 0; i < l; i++)
            {
                var v:Object = $array[i];

                if (o.indexOf(v) == -1)
                {
                    o.push(v);
                }
            }

            return o;
        }

        /**
         * Returns a new linear Array object that contains one occurance of each of the duplicated elements in a linear Array object.
         *
         * @param $array
         *
         * @return A new linear Array object that contains one occurance of each of the duplicated elements in a linear Array object.
         */
        public static function getDuplicatesOf($array:Array):Array
        {
            var l:uint = $array.length;
            var candidates:Array = new Array();
            var duplicates:Array = new Array();

            for (var i:uint = 0; i < l; i++)
            {
                var v:Object = $array[i];

                if (candidates.indexOf(v) == -1)
                {
                    candidates.push(v);
                }
                else
                {
                    duplicates.push(v);
                }
            }

            return removeDuplicatesOf(duplicates);
        }

        /**
         * Checks to see if two Array objects are equal.
         *
         * @param $array1
         * @param $array2
         *
         * @return <code>true</code> if equal, <code>false</code> otherwise.
         */
        public static function isEqual($array1:Array, $array2:Array):Boolean
        {
            if ($array1 == null && $array2 == null)
            {
                return true;
            }

            if ($array1 == null || $array2 == null)
            {
                return false;
            }

            var l1:uint = $array1.length;
            var l2:uint = $array2.length;

            if (l1 != l2)
            {
                return false;
            }

            for (var i:uint = 0; i < l1; i++)
            {
                if (!VSObjectUtil.isEqual($array1[i], $array2[i]))
                {
                    return false;
                }
            }

            return true;
        }

        /**
         * Checks to see if an Array object is linear (1-dimensional).
         *
         * @param $array
         *
         * @return <code>true</code> if linear, <code>false</code> otherwise.
         */
        public static function isLinear($array:Array):Boolean
        {
            var l:uint = $array.length;

            for (var i:uint = 0; i < l; i++)
            {
                if ($array[i] is Array)
                {
                    return false;
                }
            }

            return true;
        }
    }
}
