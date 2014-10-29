/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.events
{
    import flash.events.Event;
    import flash.events.ProgressEvent;

    /**
     * Extended flash.events.ProgressEvent with the ability to store user data.
     */
    public class VSProgressEvent extends ProgressEvent implements IVSEvent
    {
        public static const PROGRESS:String    = 'PROGRESS';
        public static const SOCKET_DATA:String = 'SOCKET_DATA';
        public static const LOADED:String      = 'LOADED';

        /**
         * Custom data.
         */
        private var _data:Object;

        /**
         * @inheritDoc
         */
        public function get data():Object { return _data; }

        /**
         * @inheritDoc
         */
        public function set data($value:Object):void { _data = $value; }

        /**
         * Creates a new VSProgressEvent instance.
         *
         * @param $type
         * @param $data
         * @param $bubbles
         * @param $cancelable
         * @param $bytesLoaded
         * @param $bytesTotal
         */
        public function VSProgressEvent($type:String, $data:Object = null, $bubbles:Boolean = false, $cancelable:Boolean = false, $bytesLoaded:Number = 0, $bytesTotal:Number = 0):void
        {
            data = $data;
            super($type, $bubbles, $cancelable, $bytesLoaded, $bytesTotal);
        }

        /**
         * @inheritDoc
         */
        override public function clone():Event
        {
            return new VSProgressEvent(type, data, bubbles, cancelable, bytesLoaded, bytesTotal);
        }
    }
}
