/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.utils
{
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;
    import flash.utils.getQualifiedSuperclassName;

    /**
     * Set of utility methods for Objects.
     */
    public class VSObjectUtil
    {
        /**
         * Clones an Object instance.
         *
         * @param $target
         *
         * @return Clone of the Object instance..
         */
        public static function clone($target:Object):Object
        {
            if (getQualifiedClassName($target) != getQualifiedClassName(Object))
            {
                return null;
            }

            var buffer:ByteArray = new ByteArray();
            buffer.writeObject($target);
            buffer.position = 0;

            var result:Object = buffer.readObject();
            return result;
        }

        /**
         * Checks to see if an Object instance contains properties that equals to a specified
         * value, then returns the respective keys.
         *
         * @param $target
         * @param $value
         *
         * @return String Vector containing all the keys.
         */
        public static function keysOf($target:Object, $value:Object):Vector.<String>
        {
            if (getQualifiedClassName($target) != getQualifiedClassName(Object))
            {
                return null;
            }

            var keys:Vector.<String> = null;

            for (var k:String in $target)
            {
                if (isEqual($value, $target[k]))
                {
                    if (keys == null)
                    {
                        keys = new Vector.<String>();
                    }

                    keys.push(k);
                }
            }

            return keys;
        }

        /**
         * Checks to see if an Object instance contains the specified key.
         *
         * @param $target
         * @param $key
         *
         * @return <code>true</code> if the Object instance contains the specified key, <code>false</code> otherwise.
         */
        public static function hasKey($target:Object, $key:String):Boolean
        {
            if (getQualifiedClassName($target) != getQualifiedClassName(Object))
            {
                return false;
            }

            for (var k:String in $target)
            {
                if (k == $key)
                {
                    return true;
                }
            }

            return false;
        }

        /**
         * Checks to see if an Object instance contains the specified value in any of its keys.
         *
         * @param $target
         * @param $value
         *
         * @return <code>true</code> if the Object instance has keys associated with the specified value, <code>false</code> otherwise.
         */
        public static function hasValue($target:Object, $value:Object):Boolean
        {
            if (getQualifiedClassName($target) != getQualifiedClassName(Object))
            {
                return false;
            }

            for (var k:String in $target)
            {
                if (isEqual($value, $target[k]))
                {
                    return true;
                }
            }

            return false;
        }

        /**
         * Deletes all the keys of an Object instance.
         *
         * @param $object
         */
        public static function deleteKeys($object:Object):void
        {
            for (var k:String in $object)
            {
                delete $object[k];
            }
        }

        /**
         * Checks recursively to see if two Object instances are equal.
         *
         * @param $object1
         * @param $object2
         *
         * @return <code>true</code> if equal, <code>false</code> otherwise.
         */
        public static function isEqual($object1:Object, $object2:Object):Boolean
        {
            if (getQualifiedClassName($object1) != getQualifiedClassName($object2))
            {
                return false;
            }
            else if (getQualifiedClassName($object1) == getQualifiedClassName(Object))
            {
                for (var k:String in $object1)
                {
                    if (!isEqual($object1[k], $object2[k]))
                    {
                        return false;
                    }
                }

                return true;
            }
            else if (getQualifiedClassName($object1) == getQualifiedClassName(Array))
            {
                return VSArrayUtil.isEqual($object1 as Array, $object2 as Array);
            }
            else if (getQualifiedClassName($object1) == getQualifiedClassName(Dictionary))
            {
                return VSDictionaryUtil.isEqual($object1 as Dictionary, $object2 as Dictionary);
            }
            else if (getQualifiedClassName($object1).indexOf(VSVectorUtil.VECTOR_CLASS_NAME) >= 0)
            {
                return VSVectorUtil.isEqual($object1 as (getDefinitionByName(getQualifiedClassName($object1)) as Class), $object2 as (getDefinitionByName(getQualifiedClassName($object2)) as Class));
            }
            else if (typeof($object1) != typeof(Object))
            {
                return ($object1 == $object2);
            }
            else if (getQualifiedClassName($object1) == getQualifiedClassName(null) && getQualifiedClassName($object2) == getQualifiedClassName(null))
            {
                return true;
            }
            else
            {
                VSAssert.panic('Type ' + getQualifiedClassName($object1) + ' is not supported.');

                return false;
            }
        }

        /**
         * Applies properties from an Object instance to another Object instance for overlapping keys only.
         *
         * @param $target
         * @param $properties
         */
        public static function applyProperties($target:Object, $properties:Object):void
        {
            for (var k:String in $properties)
            {
                if ($target.hasOwnProperty(k))
                {
                    $target[k] = $properties[k];
                }
            }
        }

        /**
         * Gets the name of the class of an Object instance without package details.
         *
         * @param $object
         *
         * @return Class name of the Object instance without package details.
         */
        public static function getClassName($object:Object):String
        {
            var qualifiedClassName:String = getQualifiedClassName($object);
            var index:int                 = qualifiedClassName.indexOf('::') + 2;
            var className:String          = qualifiedClassName.substr(index, qualifiedClassName.length - index);

            return className;
        }

        /**
         * Gets the name of the superclass of an Object instance without package details.
         *
         * @param $object
         *
         * @return Name of superclass of the Object instance without package details.
         */
        public static function getSuperclassName($object:Object):String
        {
            var qualifiedSuperclassName:String = getQualifiedSuperclassName($object);
            var index:int                      = qualifiedSuperclassName.indexOf('::') + 2;
            var superclassName:String          = qualifiedSuperclassName.substr(index, qualifiedSuperclassName.length - index);

            return superclassName;
        }
    }
}
