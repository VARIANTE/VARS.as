/**
 *  (c) VARIANTE <http://variante.io>
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.events
{
    import flash.events.IEventDispatcher;

    /**
     * Extended flash.events.IEventDispatcher to allow custom event handling.
     */
    public interface IVSEventDispatcher extends IEventDispatcher
    {
        /**
         * Checks if current VSEventDispatcher instance has the specified event type and listener registered.
         *
         * @param $type
         * @param $listener
         *
         * @return Boolean value indicating whether listener is registered for the VSEventDispatcher instance.
         */
        function hasEventHandler($type:String, $listener:Function):Boolean;
    }
}
