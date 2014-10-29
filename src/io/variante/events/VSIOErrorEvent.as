/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.events
{
    import flash.events.Event;
    import flash.events.IOErrorEvent;

    /**
     * Extended flash.events.IOErrorEvent with the ability to store user data.
     */
    public class VSIOErrorEvent extends IOErrorEvent implements IVSEvent
    {
        public static const IO_ERROR:String      = 'IO_ERROR';
        public static const NETWORK_ERROR:String = 'NETWORK_ERROR';
        public static const VERIFY_ERROR:String  = 'VERIFY_ERROR';
        public static const DISK_ERROR:String    = 'DISK_ERROR';

        /**
         * User data.
         */
        private var _data:Object;

        /**
         * @inheritDoc
         */
        public function get data():Object { return _data; }

        /**
         * @inheritDoc
         */
        public function set data(value:Object):void { _data = value; }

        /**
         * Creates a new VSIOErrorEvent instance.
         *
         * @param $type
         * @param $data
         * @param $bubbles
         * @param $cancelable
         * @param $text
         * @param $id
         */
        public function VSIOErrorEvent($type:String, $data:Object = null, $bubbles:Boolean = false, $cancelable:Boolean = false, $text:String = '', $id:int = 0)
        {
            data = $data;
            super($type, $bubbles, $cancelable, $text, $id);
        }

        /**
         * @inheritDoc
         */
        public override function clone():Event
        {
            return new VSIOErrorEvent(type, data, bubbles, cancelable, text, errorID);
        }
    }
}
