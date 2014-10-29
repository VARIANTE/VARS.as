/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.events
{
    /**
     * Interface for all events in VARS.
     */
    public interface IVSEvent
    {
        /**
         * Gets the custom data.
         */
        function get data():Object;

        /**
         * Sets the custom data.
         */
        function set data($value:Object):void;
    }
}
