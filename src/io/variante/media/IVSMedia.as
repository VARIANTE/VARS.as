/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.media
{
    import io.variante.events.IVSEventDispatcher;

    /**
     * Generic interface for all media types in VARS.
     */
    public interface IVSMedia extends IVSEventDispatcher
    {
        /**
         * Gets the source media path.
         */
        function get source():String;

        /**
         * Sets the source media path.
         */
        function set source($value:String):void;
    }
}