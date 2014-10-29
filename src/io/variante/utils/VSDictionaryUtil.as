/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.utils
{
    import flash.utils.Dictionary;

    /**
     * Set of utility methods for Dictionary objects.
     */
    public class VSDictionaryUtil
    {
        /**
         * Gets the size of a Dictionary object.
         *
         * @param $dictionary
         *
         * @return Size of the Dictionary object.
         */
        public static function sizeOf($dictionary:Dictionary):uint
        {
            VSAssert.assert($dictionary != null, 'Argument $dictionary is null.');

            var count:uint = 0;

            for (var k:Object in $dictionary)
            {
                if (k != null)
                {
                    count++;
                }
            }

            return count;
        }

        /**
         * Gets the corresponding key(s) of a value in a Dictionary object.
         *
         * @param $dictionary
         * @param $value
         *
         * @return An Array of corresponding key(s) to the specified value, <code>null</code> if no matching keys are found.
         */
        public static function keysOf($dictionary:Dictionary, $value:Object):Object
        {
            VSAssert.assert($dictionary != null, 'Argument in parameter $dictionary is null.');

            var o:Array = new Array();

            for (var k:Object in $dictionary)
            {
                if ($dictionary[k] == $value)
                {
                    o.push(k);
                }
            }

            return (o.length == 0) ? null : o;
        }

        /**
         * Checks to see if a Dictionary object contains the specified key.
         *
         * @param $dictionary
         * @param $key
         *
         * @return <code>true</code> if the Dictionary object contains the specified key, <code>false</code> otherwise.
         */
        public static function hasKey($dictionary:Object, $key:Object):Boolean
        {
            for (var k:Object in $dictionary)
            {
                if (VSObjectUtil.isEqual(k, $key))
                {
                    return true;
                }
            }

            return false;
        }

        /**
         * Checks to see if a Dictionary object contains the specified value in any of its keys.
         *
         * @param $dictionary
         * @param $value
         *
         * @return <code>true</code> if the Object instance has keys associated with the specified value, <code>false</code> otherwise.
         */
        public static function hasValue($dictionary:Object, $value:Object):Boolean
        {
            for (var k:Object in $dictionary)
            {
                if (VSObjectUtil.isEqual($value, $dictionary[k]))
                {
                    return true;
                }
            }

            return false;
        }

        /**
         * Deletes all the keys of an Dictionary instance.
         *
         * @param $dictionary
         */
        public static function deleteKeys($dictionary:Dictionary):void
        {
            for (var k:Object in $dictionary)
            {
                delete $dictionary[k];
            }
        }

        /**
         * Determines whether two Dictionary objects are equal.
         *
         * @param $dictionary1
         * @param $dictionary2
         *
         * @return <code>true</code> if equal, <code>false</code> otherwise.
         */
        public static function isEqual($dictionary1:Dictionary, $dictionary2:Dictionary):Boolean
        {
            var s1:uint = sizeOf($dictionary1);
            var s2:uint = sizeOf($dictionary2);

            if (s1 != s2)
            {
                return false;
            }

            for (var k:Object in $dictionary1)
            {
                var value1:Object = $dictionary1[k];
                var value2:Object = $dictionary2[k];

                if (value2 == null)
                {
                    return false;
                }

                if (!VSObjectUtil.isEqual(value1, value2))
                {
                    return false;
                }
            }

            return true;
        }
    }
}
