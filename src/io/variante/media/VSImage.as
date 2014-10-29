/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.media
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.utils.getQualifiedClassName;
    import io.variante.display.VSDisplayObject;
    import io.variante.enums.VSDirtyType;
    import io.variante.events.VSEvent;
    import io.variante.events.VSIOErrorEvent;
    import io.variante.events.VSProgressEvent;
    import io.variante.utils.VSAssert;
    import io.variante.utils.VSAssetLoader;

    /**
     * Dispatched when the image is loaded and set.
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
     * Image component.
     */
    public class VSImage extends VSDisplayObject implements IVSMedia
    {
        /**
         * @private
         *
         * Offsets.
         */
        private var _topOffset:Number;
        private var _rightOffset:Number;
        private var _bottomOffset:Number;
        private var _leftOffset:Number;

        /**
         * @private
         *
         * Source path of the image.
         */
        private var _source:String;

        /**
         * @private
         *
         * VSAssetLoader instance.
         */
        private var _loader:VSAssetLoader;

        /**
         * @private
         *
         * Container of the loaded image.
         */
        private var _container:Sprite;

        /**
         * @private
         *
         * Bitmap instance of loaded image.
         */
        private var _bitmap:Bitmap;

        /**
         * @private
         *
         * Saved BitmapData instance of loaded image.
         */
        private var _savedBitmapData:BitmapData;

        /**
         * @private
         *
         * Current width of the video.
         */
        private var _width:Number;

        /**
         * @private
         *
         * Set width of the video.
         */
        private var _setWidth:Number;

        /**
         * @private
         *
         * Current height of the video.
         */
        private var _height:Number;

        /**
         * @private
         *
         * Set height of the video.
         */
        private var _setHeight:Number;

        /**
         * @private
         *
         * Saved boolean value of smoothing property.
         */
        private var _smoothing:Boolean;

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
            _setWidth = $value;

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
            _setHeight = $value;

            setDirty(VSDirtyType.DIMENSION);
        }

        /**
         * Gets the top offset.
         */
        public function get topOffset():Number { return _topOffset; }

        /**
         * Sets the top offset.
         */
        public function set topOffset($value:Number):void
        {
            _topOffset = $value;

            setDirty(VSDirtyType.POSITION);
        }

        /**
         * Gets the right offset.
         */
        public function get rightOffset():Number { return _rightOffset; }

        /**
         * Sets the right offset.
         */
        public function set rightOffset($value:Number):void
        {
            _rightOffset = $value;

            setDirty(VSDirtyType.POSITION);
        }

        /**
         * Gets the bottom offset.
         */
        public function get bottomOffset():Number { return _bottomOffset; }

        /**
         * Sets the bottom offset.
         */
        public function set bottomOffset($value:Number):void
        {
            _bottomOffset = $value;

            setDirty(VSDirtyType.POSITION);
        }

        /**
         * Gets the left offset.
         */
        public function get leftOffset():Number { return _leftOffset; }

        /**
         * Sets the left offset.
         */
        public function set leftOffset($value:Number):void
        {
            _leftOffset = $value;

            setDirty(VSDirtyType.POSITION);
        }

        /**
         * Gets the bitmapData of the loaded image.
         */
        public function get bitmapData():BitmapData
        {
            return _savedBitmapData;
        }

        /**
         * Sets the bitmapData of the loaded image.
         */
        public function set bitmapData($value:BitmapData):void
        {
            if (_savedBitmapData == $value || (_bitmap && _savedBitmapData == _bitmap.bitmapData)) return;

            // if source is already set, remove it
            if (_source)
            {
                _source = null;
            }

            // if loading is in progress, terminate it
            if (_loader)
            {
                _loader.removeEventListener(VSProgressEvent.PROGRESS, _onLoadProgress);
                _loader.removeEventListener(VSEvent.COMPLETE, _onLoadComplete);
                _loader.removeEventListener(VSIOErrorEvent.IO_ERROR, _onLoadFail);
                _loader.kill();
                _loader = null;
            }

            _savedBitmapData = $value;

            if (isNaN(_setWidth))
            {
                _width  = _savedBitmapData.width - leftOffset - rightOffset;
            }

            if (isNaN(_setHeight))
            {
                _height = _savedBitmapData.height - topOffset - bottomOffset;
            }

            setDirty(VSDirtyType.DATA);
        }

        /**
         * Gets the smoothing property of the internal bitmap.
         */
        public function get smoothing():Boolean
        {
            return _smoothing;
        }

        /**
         * Sets the smoothing property of the internal bitmap.
         */
        public function set smoothing($value:Boolean):void
        {
            if (_smoothing == $value) return;

            _smoothing = $value;

            setDirty(VSDirtyType.VIEW);
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
            if (_source == $value) return;

            _source = $value;

            if (_loader != null)
            {
                _loader.removeEventListener(VSProgressEvent.PROGRESS, _onLoadProgress);
                _loader.removeEventListener(VSEvent.COMPLETE, _onLoadComplete);
                _loader.removeEventListener(VSIOErrorEvent.IO_ERROR, _onLoadFail);
                _loader.kill();
                _loader = null;
            }

            _loader = new VSAssetLoader();
            _loader.addEventListener(VSProgressEvent.PROGRESS, _onLoadProgress, false, 0, true);
            _loader.addEventListener(VSEvent.COMPLETE, _onLoadComplete, false, 0, true);
            _loader.addEventListener(VSIOErrorEvent.IO_ERROR, _onLoadFail, false, 0, true);
            _loader.load(_source);
        }

        /**
         * Creates a new VSImage instance.
         */
        public function VSImage($source:Object = null)
        {
            _topOffset    = 0;
            _rightOffset  = 0;
            _bottomOffset = 0;
            _leftOffset   = 0;

            smoothing = true;

            if ($source != null)
            {
                if ($source is String)
                {
                    source = String($source);
                }
                else if ($source is BitmapData)
                {
                    bitmapData = BitmapData($source);
                }
                else
                {
                    VSAssert.panic('Invalid source type: ' + getQualifiedClassName($source));
                }
            }
        }

        /**
         * @inheritDoc
         */
        override protected function init():void
        {
            _container = new Sprite();
            addChild(_container);

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
            if (_loader != null)
            {
                _loader.removeEventListener(VSProgressEvent.PROGRESS, _onLoadProgress);
                _loader.removeEventListener(VSEvent.COMPLETE, _onLoadComplete);
                _loader.removeEventListener(VSIOErrorEvent.IO_ERROR, _onLoadFail);
                _loader.kill();
                _loader = null;
            }

            super.destroy();
        }

        /**
         * @inheritDoc
         */
        override protected function render():void
        {
            if (_savedBitmapData != null)
            {
                if (getDirty(VSDirtyType.DATA))
                {
                    _setImage(_savedBitmapData);
                }

                if (getDirty(VSDirtyType.DIMENSION))
                {
                    _container.width = width + leftOffset + rightOffset;
                    _container.height = height + topOffset + bottomOffset;
                }

                if (getDirty(VSDirtyType.POSITION) || getDirty(VSDirtyType.DIMENSION) || getDirty(VSDirtyType.DATA))
                {
                    _container.x = -_leftOffset;
                    _container.y = -topOffset;
                }

                if (getDirty(VSDirtyType.VIEW))
                {
                    if (_bitmap != null)
                    {
                        _bitmap.smoothing = _smoothing;
                    }
                }
            }

            super.render();
        }

        /**
         * @private
         *
         * Sets the image.
         *
         * @param $bitmapData
         */
        private function _setImage($bitmapData:BitmapData):void
        {
            _bitmap = new Bitmap($bitmapData);

            if (!_container.contains(_bitmap))
            {
                _container.addChild(_bitmap);
            }

            if (isNaN(_setWidth))
            {
                _width  = _bitmap.width;
            }

            if (isNaN(_setHeight))
            {
                _height = _bitmap.height;
            }

            setDirty(VSDirtyType.DIMENSION);

            dispatchEvent(new VSEvent(VSEvent.COMPLETE));
        }

        /**
         * @private
         *
         * io.variante.events.VSProgressEvent.PROGRESS handler for io.variante.utils.VSAssetLoader, when the image is loading.
         *
         * @param $event
         */
        private function _onLoadProgress($event:VSProgressEvent):void
        {
            dispatchEvent($event);
        }

        /**
         * @private
         *
         * io.variante.events.VSEvent.COMPLETE handler for io.variante.utils.VSAssetLoader, when the image is done loading.
         *
         * @param $event
         */
        private function _onLoadComplete($event:VSEvent):void
        {
            _savedBitmapData = (_loader.assets[_source] as Bitmap).bitmapData;

            _loader.removeEventListener(VSProgressEvent.PROGRESS, _onLoadProgress);
            _loader.removeEventListener(VSEvent.COMPLETE, _onLoadComplete);
            _loader.removeEventListener(VSIOErrorEvent.IO_ERROR, _onLoadFail);
            _loader.kill();
            _loader = null;

            if (initialized)
            {
                setDirty(VSDirtyType.DATA);
            }
            else
            {
                super.initComplete();
            }
        }

        /**
         * @private
         *
         * io.variante.events.VSIOErrorEvent.IO_ERROR handler.
         *
         * @param $event
         */
        private function _onLoadFail($event:VSIOErrorEvent):void
        {
            _savedBitmapData = null;

            _loader.removeEventListener(VSProgressEvent.PROGRESS, _onLoadProgress);
            _loader.removeEventListener(VSEvent.COMPLETE, _onLoadComplete);
            _loader.removeEventListener(VSIOErrorEvent.IO_ERROR, _onLoadFail);
            _loader.kill();
            _loader = null;

            dispatchEvent($event);
        }
    }
}
