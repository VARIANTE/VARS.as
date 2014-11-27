/**
 *  (c) VARIANTE <http://variante.io>
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.utils
{
    import flash.display.DisplayObject;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.net.URLRequest;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;
    import io.variante.events.VSEvent;
    import io.variante.events.VSEventDispatcher;
    import io.variante.events.VSIOErrorEvent;
    import io.variante.events.VSProgressEvent;

    /**
     * Dispatched during the loading process of each asset.
     *
     * @eventType io.variante.events.VSProgressEvent.PROGRESS
     */
    [Event(name = 'PROGRESS', type = 'io.variante.events.VSProgressEvent')]

    /**
     * Dispatched after loading and storing each asset.
     *
     * @eventType io.variante.events.VSProgressEvent.LOADED
     */
    [Event(name = 'LOADED', type = 'io.variante.events.VSProgressEvent')]

    /**
     * Dispatched after loading and storing all assets.
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
     *  A class used for preloading multimedia asset(s).
     */
    public class VSAssetLoader extends VSEventDispatcher
    {
        /**
         * @private
         *
         * Dictionary that stores loaded objects.
         */
        private var _assets:Object;

        /**
         * @private
         *
         * Loader context.
         */
        private var _loaderContext:LoaderContext;

        /**
         * @private
         *
         * Queue of objects to be loaded.
         */
        private var _queue:Array;

        /**
         * @private
         *
         * Length of the queue.
         */
        private var _queueLength:int;

        /**
         * @private
         *
         * Index of object being preloaded in the queue.
         */
        private var _loadID:int;

        /**
         * @private
         *
         * Loader instance for preloading objects in the queue.
         */
        private var _preloader:Loader;

        /**
         * @private
         *
         * Percentage of bytes loaded of the intermediate object.
         */
        private var _loaded:Number;

        /**
         * @private
         *
         * Percentage of bytes loaded of the entire queue.
         */
        private var _loadedTotal:Number;

        /**
         * @private
         *
         * Number of bytes loaded of the intermediate asset.
         */
        private var _bytesLoaded:Number;

        /**
         * @private
         *
         * File size (in bytes) of the intermediate asset.
         */
        private var _fileSize:Number;

        /**
         * Gets the queue.
         */
        public function get queue():Array { return _queue; }

        /**
         * Gets the loaded objects.
         */
        public function get assets():Object { return _assets; }

        /**
         * Gets the percentage of bytes loaded for the intermediate asset.
         */
        public function get loaded():Number { return (isNaN(_loaded)) ? 0 : _loaded; }

        /**
         * Gets the integer representation of the percentage of bytes loaded for the intermediate asset.
         */
        public function get loadedInt():int { return (isNaN(_loaded)) ? 0 : Math.floor(_loaded * 100); }

        /**
         * Gets the total percentage of bytes loaded for the entire queue.
         */
        public function get loadedTotal():Number { return (isNaN(_loadedTotal)) ? 0 : _loadedTotal; }

        /**
         * Gets the integer representation of the total percentage of bytes loaded for the entire queue.
         */
        public function get loadedTotalInt():int { return (isNaN(_loadedTotal)) ? 0 : Math.floor(_loadedTotal * 100); }

        /**
         * Creates a new AssetLoader instance.
         *
         * @param $newApplicationDomain
         */
        public function VSAssetLoader($newApplicationDomain:Boolean = false)
        {
            _assets      = null;
            _queue       = null;
            _queueLength = 0;
            _loadID      = -1;
            _loaded      = 0;
            _loadedTotal = 0;
            _bytesLoaded = NaN;
            _fileSize    = NaN;

            if ($newApplicationDomain)
            {
                _loaderContext = new LoaderContext();
                _loaderContext.applicationDomain = new ApplicationDomain();
            }
            else
            {
                _loaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
            }
        }

        /**
         * Preloads the object in the specified path.
         *
         * @param $url
         */
        protected function _preload($url:String):void
        {
            _preloader.load(new URLRequest($url), _loaderContext);
            _preloader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, _onProgress, false, 0, false);
            _preloader.contentLoaderInfo.addEventListener(Event.COMPLETE, _onComplete, false, 0, true);
            _preloader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _onIOError, false, 0, true);
        }

        /**
         * Reads the passed in queue and begins preloading the assets in the queue.
         *
         * @param ...$params
         */
        public function load(...$params):void
        {
            _queue       = $params;
            _queueLength = _queue.length;
            _loadID      = 0;
            _assets      = new Object();

            _preloader = new Loader();
            _preload(_queue[_loadID]);
        }

        /**
         * Kills all current processes.
         */
        public function kill():void
        {
            _preloader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, _onProgress);
            _preloader.contentLoaderInfo.removeEventListener(Event.COMPLETE, _onComplete);
            _preloader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, _onIOError);
            _preloader = null;

            if (_assets != null)
            {
                VSObjectUtil.deleteKeys(_assets);
            }

            _assets      = null;
            _queue       = null;
            _queueLength = 0;
            _loadID      = -1;
            _loaded      = 0;
            _loadedTotal = 0;
            _bytesLoaded = NaN;
            _fileSize    = NaN;
        }

        /**
         * @private
         *
         * flash.events.ProgressEvent.PROGRESS handler, dispatched when an object is in the middle of being preloaded.
         *
         * @param $event
         */
        private function _onProgress($event:ProgressEvent):void
        {
            var target:LoaderInfo = ($event.currentTarget as LoaderInfo);

            _bytesLoaded = target.bytesLoaded;
            _fileSize    = target.bytesTotal;
            _loaded      = _bytesLoaded / _fileSize;
            _loadedTotal = (_loadID * (1 / _queueLength)) + (_loaded / _queueLength);

            dispatchEvent(new VSProgressEvent(VSProgressEvent.PROGRESS, null, $event.bubbles, $event.cancelable, $event.bytesLoaded, $event.bytesTotal));
        }

        /**
         * @private
         *
         * flash.events.Event.COMPLETE handler, dispatched when an object in the queue is done loading.
         *
         * @param $event
         */
        private function _onComplete($event:Event):void
        {
            // save the loaded asset
            _assets[_queue[_loadID]] = _preloader.content;

            dispatchEvent(new VSProgressEvent(VSProgressEvent.LOADED, { id: _loadID }, $event.bubbles, $event.cancelable));

            // load the next asset in queue or dispatch complete
            if (_loadID < _queueLength - 1)
            {
                _loadID++;
                _preload(_queue[_loadID]);
            }
            else
            {
                dispatchEvent(new VSEvent(VSEvent.COMPLETE, null, $event.bubbles, $event.cancelable));
            }
        }

        /**
         * @private
         *
         * flash.events.IOErrorEvent.IO_ERROR handler, dispatched when the specified url to load is not found.
         *
         * @param $event
         */
        private function _onIOError($event:IOErrorEvent):void
        {
            _assets[_queue[_loadID]] = null;

            dispatchEvent(new VSIOErrorEvent($event.type, { id: _loadID }, $event.bubbles, $event.cancelable, $event.text));

            // load the next asset in queue or dispatch complete
            if (_loadID < _queueLength - 1)
            {
                _loadID++;
                _preload(_queue[_loadID]);
            }
            else
            {
                dispatchEvent(new VSEvent(VSEvent.COMPLETE, null, $event.bubbles, $event.cancelable));
            }
        }
    }
}

