/**
 *  ©2013 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.utils
{
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import io.variante.events.VSEvent;
    import io.variante.events.VSEventDispatcher;
    import io.variante.events.VSIOErrorEvent;
    import io.variante.events.VSProgressEvent;

    /**
     * Dispatched when loading operation is in progress.
     *
     * @eventType io.variante.events.VSProgressEvent.PROGRESS
     */
    [Event(name = 'PROGRESS', type = 'io.variante.events.VSProgressEvent')]

    /**
     * Dispatched when loading operation is complete.
     *
     * @eventType io.variante.events.VSEvent.COMPLETE
     */
    [Event(name = 'COMPLETE', type = 'io.variante.events.VSEvent')]

    /**
     * Dispatched when loading operation fails.
     *
     * @eventType io.variante.events.VSIOErrorEvent.IO_ERROR
     */
    [Event(name = 'IO_ERROR', type = 'io.variante.events.VSIOErrorEvent')]

    /**
     * Utility class for loading and parsing XML files.
     */
    public class VSXMLLoader extends VSEventDispatcher
    {
        /**
         * @private
         *
         * Internal URL loader instance.
         */
        private var _urlLoader:URLLoader;

        /**
         * @private
         *
         * Source of XML file.
         */
        private var _source:String;

        /**
         * @private
         *
         * Stored data of last loaded XML file.
         */
        private var _data:XML;

        /**
         * @private
         *
         * Boolean value that indicates whether XML whitespace is ignored.
         */
        private var _ignoreWhiteSpace:Boolean;

        /**
         * Gets the stored XML data.
         */
        public function get data():XML
        {
            return _data;
        }

        /**
         * Gets the source of the XML file.
         */
        public function get source():String
        {
            return _source;
        }

        /**
         * Gets the boolean value that indicates whether XML whitespace is ignored.
         */
        public function get ignoreWhiteSpace():Boolean
        {
            return _ignoreWhiteSpace;
        }

        /**
         * Sets the boolean value that indicates whether XML whitespace is ignored.
         */
        public function set ignoreWhiteSpace($value:Boolean):void
        {
            _ignoreWhiteSpace = $value;

            XML.ignoreWhitespace = $value;
        }

        /**
         * Creates a new VSXMLLoader instance.
         */
        public function VSXMLLoader() {}

        /**
         * Starts loading operation of set source XML file.
         *
         * @param $source
         */
        public function load($source:String):void
        {
            VSAssert.assert($source != null, 'Source cannot be null when attempting the load operation.');

            kill();

            _source = $source;

            _urlLoader = new URLLoader();
            _urlLoader.addEventListener(ProgressEvent.PROGRESS, _onLoadProgress, false, 0, true);
            _urlLoader.addEventListener(Event.COMPLETE, _onLoadComplete, false, 0, true);
            _urlLoader.addEventListener(IOErrorEvent.IO_ERROR, _onLoadFail, false, 0, true);
            _urlLoader.load(new URLRequest(_source));
        }

        /**
         * Kills the current loading operation if it exists.
         */
        public function kill():void
        {
            if (_urlLoader != null)
            {
                _urlLoader.removeEventListener(ProgressEvent.PROGRESS, _onLoadProgress);
                _urlLoader.removeEventListener(Event.COMPLETE, _onLoadComplete);
                _urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, _onLoadFail);
                _urlLoader.close();
                _urlLoader = null;

                _source = null;
            }
        }

        /**
         * @private
         *
         * Event handler triggered when loading operation is in progress.
         *
         * @param $event
         */
        private function _onLoadProgress($event:ProgressEvent):void
        {
            dispatchEvent(new VSProgressEvent(VSProgressEvent.PROGRESS, null, $event.bubbles, $event.cancelable, $event.bytesLoaded, $event.bytesTotal));
        }

        /**
         * @private
         *
         * Event handler triggered when loading operation is complete.
         *
         * @param $event
         */
        private function _onLoadComplete($event:Event):void
        {
            _data = new XML(_urlLoader.data);

            dispatchEvent(new VSEvent(VSEvent.COMPLETE));

            kill();
        }

        /**
         * @private
         *
         * Event handler triggered when loading operation fails.
         *
         * @param $event
         */
        private function _onLoadFail($event:IOErrorEvent):void
        {
            dispatchEvent(new VSIOErrorEvent(VSIOErrorEvent.IO_ERROR));

            kill();
        }
    }
}
