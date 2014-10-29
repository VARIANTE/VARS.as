/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.utils
{
    import flash.utils.getQualifiedClassName;

    /**
     * Set of utility methods for Vector objects.
     */
    public class VSVectorUtil
    {
        public static const VECTOR_CLASS_NAME:String = '__AS3__.vec::Vector';

        /**
         * Checks to see if two Vectors are equal.
         *
         * @param $vector1
         * @param $vector2
         *
         * @return <code>true</code> if equal, <code>false</code> otherwise.
         */
        public static function isEqual($vector1:Object, $vector2:Object):Boolean
        {
            var l1:uint = $vector1.length;
            var l2:uint = $vector2.length;

            if (getQualifiedClassName($vector1).indexOf(VECTOR_CLASS_NAME) < 0 || getQualifiedClassName($vector2).indexOf(VECTOR_CLASS_NAME) < 0)
            {
                return false;
            }

            if (getQualifiedClassName($vector1) != getQualifiedClassName($vector2))
            {
                return false;
            }

            if (l1 != l2)
            {
                return false;
            }

            for (var i:uint = 0; i < l1; i++)
            {
                if (!VSObjectUtil.isEqual($vector1[i], $vector2[i]))
                {
                    return false;
                }
            }

            return true;
        }
    }
}
