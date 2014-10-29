/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.events
{
    import flash.events.Event;
    import flash.events.TextEvent;

    /**
     * Extended flash.events.TextEvent with the ability to store user data.
     */
    public class VSTextEvent extends TextEvent implements IVSEvent
    {
        public static const TEXT_INPUT:String = 'TEXT_INPUT';
        public static const LINK:String       = 'LINK';

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
         * Creates a new VSTextEvent instance.
         *
         * @param $type
         * @param $data
         * @param $bubbles
         * @param $cancelable
         * @param $text
         */
        public function VSTextEvent($type:String, $data:Object = null, $bubbles:Boolean = false, $cancelable:Boolean = false, $text:String = '')
        {
            data = $data;
            super($type, $bubbles, $cancelable, $text);
        }

        /**
         * @inheritDoc
         */
        public override function clone():Event
        {
            return new VSTextEvent(type, data, bubbles, cancelable, text);
        }
    }
}
