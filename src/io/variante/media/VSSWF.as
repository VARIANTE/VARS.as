/**
 *  ©2013 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.media
{
    import flash.display.DisplayObject;
    import io.variante.display.VSDisplayObject;
    import io.variante.enums.VSDirtyType;
    import io.variante.events.VSEvent;
    import io.variante.events.VSIOErrorEvent;
    import io.variante.events.VSProgressEvent;
    import io.variante.utils.VSAssert;
    import io.variante.utils.VSAssetLoader;

    /**
     * Dispatched when the SWF is loaded.
     *
     * @eventType io.variante.events.VSEvent.COMPLETE
     */
    [Event(name = 'COMPLETE', type = 'io.variante.events.VSEvent')]

    /**
     * Dispatched during the loading process.
     *
     * @eventType io.variante.events.VSProgressEvent.PROGRESS
     */
    [Event(name = 'PROGRESS', type = 'io.variante.events.VSProgressEvent')]

    /**
     * Dispatched when loading fails.
     *
     * @eventType io.variante.events.VSIOErrorEvent.IO_ERROR
     */
    [Event(name = 'IO_ERROR', type = 'io.variante.events.VSIOErrorEvent')]

    /**
     * Generic SWF component.
     */
    public class VSSWF extends VSDisplayObject implements IVSMedia
    {
        /**
         * @private
         *
         * Custom width reference.
         */
        private var _width:Number;

        /**
         * @private
         *
         * Custom height reference.
         */
        private var _height:Number;

        /**
         * @private
         *
         * VSAssetLoader instance.
         */
        private var _loader:VSAssetLoader;

        /**
         * @private
         *
         * Source path of SWF.
         */
        private var _source:String;

        /**
         * @private
         *
         * SWF instance.
         */
        private var _swf:DisplayObject;

        /**
         * @inheritDoc
         */
        override public function get width():Number
        {
            return (isNaN(_width)) ? super.width : _width;
        }

        /**
         * @inheritDoc
         */
        override public function set width($value:Number):void
        {
            _width = $value;

            setDirty(VSDirtyType.DIMENSION);
        }

        /**
         * @inheritDoc
         */
        override public function get height():Number
        {
            return (isNaN(_height)) ? super.height : _height;
        }

        /**
         * @inheritDoc
         */
        override public function set height($value:Number):void
        {
            _height = $value;

            setDirty(VSDirtyType.DIMENSION);
        }

        /**
         * @inheritDoc
         */
        public function get source():String
        {
            return _source;
        }

        /**
         * @inheritDoc
         */
        public function set source($value:String):void
        {
            VSAssert.assert(!initialized, 'Source of VSSWF instance must be set before it is initialized.');
            _source = $value;
        }

        /**
         * Creates a new VSSWF instance.
         *
         * @param $source
         */
        public function VSSWF($source:String = null)
        {
            source = $source;
        }

        /**
         * @inheritDoc
         */
        override protected function init():void
        {
            _loader = new VSAssetLoader();
            _loader.addEventListener(VSEvent.COMPLETE, _onComplete, false, 0, true);
            _loader.addEventListener(VSProgressEvent.PROGRESS, _onProgress, false, 0, true);
            _loader.addEventListener(VSIOErrorEvent.IO_ERROR, _onIOError, false, 0, true);
            _loader.load(_source);

            super.init();
        }

        /**
         * @inheritDoc
         */
        override protected function initComplete():void
        {
            if (_loader == null)
            {
                super.initComplete();
            }
        }

        /**
         * @inheritDoc
         */
        override protected function destroy():void
        {
            super.destroy();
        }

        /**
         * @inheritDoc
         */
        override protected function render():void
        {
            if (getDirty(VSDirtyType.DIMENSION))
            {
                _swf.width  = width;
                _swf.height = height;
            }

            super.render();
        }

        /**
         * @private
         *
         * Event handler triggered when the source is loaded.
         *
         * @param $event
         */
        private function _onComplete($event:VSEvent):void
        {
            _swf = DisplayObject(_loader.assets[_source]);

            if (_swf is VSDisplayObject)
            {
                VSDisplayObject(_swf).data = data;
            }

            _loader.removeEventListener(VSEvent.COMPLETE, _onComplete);
            _loader.removeEventListener(VSProgressEvent.PROGRESS, _onProgress);
            _loader.removeEventListener(VSIOErrorEvent.IO_ERROR, _onIOError);
            _loader.kill();
            _loader = null;

            if (isNaN(_width))
            {
                _width = _swf.width;
            }

            if (isNaN(_height))
            {
                _height = _swf.height;
            }

            dispatchEvent(new VSEvent($event.type));

            addChild(_swf);

            if (!initialized)
            {
                super.initComplete();
            }
        }

        /**
         * @private
         *
         * Event handler triggered while source is loading.
         *
         * @param $event
         */
        private function _onProgress($event:VSProgressEvent):void
        {
            dispatchEvent(new VSProgressEvent($event.type, $event.data, $event.bubbles, $event.cancelable, $event.bytesLoaded, $event.bytesTotal));
        }

        /**
         * @private
         *
         * Event handler triggered if source failed to load.
         *
         * @param $event
         */
        private function _onIOError($event:VSIOErrorEvent):void
        {
            _loader.removeEventListener(VSEvent.COMPLETE, _onComplete);
            _loader.removeEventListener(VSProgressEvent.PROGRESS, _onProgress);
            _loader.removeEventListener(VSIOErrorEvent.IO_ERROR, _onIOError);
            _loader.kill();
            _loader = null;

            dispatchEvent(new VSIOErrorEvent($event.type, $event.data, $event.bubbles, $event.cancelable, $event.text, $event.errorID));
        }
    }
}
