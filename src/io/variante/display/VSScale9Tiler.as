/**
 *  (c) VARIANTE <http://variante.io>
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.display
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.PixelSnapping;
    import flash.display.Sprite;
    import io.variante.enums.VSDirtyType;
    import io.variante.events.VSEvent;
    import io.variante.events.VSIOErrorEvent;
    import io.variante.utils.VSAssetLoader;

    public class VSScale9Tiler extends VSDisplayObject
    {
        private var _sources:Array;
        private var _bitmapData:Array;
        private var _al:VSAssetLoader;

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
         * Tiles.
         */
        private var _tileTL:Sprite;
        private var _tileT:Sprite;
        private var _tileTR:Sprite;
        private var _tileL:Sprite;
        private var _tileC:Sprite;
        private var _tileR:Sprite;
        private var _tileBL:Sprite;
        private var _tileB:Sprite;
        private var _tileBR:Sprite;

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
         * Creates a new VSScale9Tiler instance.
         */
        public function VSScale9Tiler()
        {
            _topOffset    = 0;
            _rightOffset  = 0;
            _bottomOffset = 0;
            _leftOffset   = 0;
        }

        /**
         * @inheritDoc
         */
        override protected function init():void
        {
            _tileTL = new Sprite();
            _tileT  = new Sprite();
            _tileTR = new Sprite();
            _tileL  = new Sprite();
            _tileC  = new Sprite();
            _tileR  = new Sprite();
            _tileBL = new Sprite();
            _tileB  = new Sprite();
            _tileBR = new Sprite();

            addChild(_tileTL);
            addChild(_tileT);
            addChild(_tileTR);
            addChild(_tileL);
            addChild(_tileC);
            addChild(_tileR);
            addChild(_tileBL);
            addChild(_tileB);
            addChild(_tileBR);

            super.init();
        }

        /**
         * @inheritDoc
         */
        override protected function destroy():void
        {
            _sources = null;

            if (_al != null)
            {
                _al.removeEventListener(VSEvent.COMPLETE, _onTileSourcesLoaded);
                _al.removeEventListener(VSIOErrorEvent.IO_ERROR, _onTileSourceIOError);
                _al = null;
            }

            super.destroy();
        }

        /**
         * @inheritDoc
         */
        override protected function render():void
        {
            if (_bitmapData != null)
            {
                if (getDirty(VSDirtyType.DATA))
                {
                    _setTiles.apply(null, _bitmapData);
                }

                if (getDirty(VSDirtyType.POSITION) || getDirty(VSDirtyType.DIMENSION) || getDirty(VSDirtyType.DATA))
                {
                    _tileTL.x = -leftOffset;
                    _tileTL.y = -topOffset;

                    _tileT.x = _tileTL.x + _tileTL.width;
                    _tileT.y = _tileTL.y;
                    _tileT.width = width - _tileTL.width - _tileTR.width - leftOffset - rightOffset;

                    _tileTR.x = _tileT.x + _tileT.width;
                    _tileTR.y = _tileTL.y;

                    _tileL.x = _tileTL.x;
                    _tileL.y = _tileTL.y + _tileTL.height;
                    _tileL.height = height - _tileTL.height - _tileBL.height - topOffset - bottomOffset;

                    _tileC.x = _tileL.x + _tileL.width;
                    _tileC.y = _tileL.y;
                    _tileC.width = width - _tileL.width - _tileR.width - leftOffset - rightOffset;
                    _tileC.height = height - _tileT.height - _tileB.height - topOffset - bottomOffset;

                    _tileR.x = _tileC.x + _tileC.width;
                    _tileR.y = _tileL.y;

                    _tileBL.x = _tileTL.x;
                    _tileBL.y = _tileL.y + _tileL.height;

                    _tileB.x = _tileC.x;
                    _tileB.y = _tileC.y + _tileC.height;
                    _tileB.width = width - _tileBL.width - _tileBR.width - leftOffset - rightOffset;

                    _tileBR.x = _tileTR.x;
                    _tileBR.y = _tileBL.y;
                }
            }

            super.render();
        }

        /**
         * Sets the BitmapData for each of the 9 tiles.
         *
         * @param $topLeft
         * @param $top
         * @param $topRight
         * @param $left
         * @param $center
         * @param $right
         * @param $bottomLeft
         * @param $bottom
         * @param $bottomRight
         */
        public function setBitmapDataOfTiles($topLeft:BitmapData = null, $top:BitmapData = null, $topRight:BitmapData = null, $left:BitmapData = null, $center:BitmapData = null, $right:BitmapData = null, $bottomLeft:BitmapData = null, $bottom:BitmapData = null, $bottomRight:BitmapData = null):void
        {
            _bitmapData = new Array();

            _bitmapData.push($topLeft, $top, $topRight, $left, $center, $right, $bottomLeft, $bottom, $bottomRight);

            setDirty(VSDirtyType.DATA);
        }

        /**
         * Sets the sources for each of the 9 tiles.
         *
         * @param $topLeft
         * @param $top
         * @param $topRight
         * @param $left
         * @param $center
         * @param $right
         * @param $bottomLeft
         * @param $bottom
         * @param $bottomRight
         */
        public function setSourcesOfTiles($topLeft:String = '', $top:String = '', $topRight:String = '', $left:String = '', $center:String = '', $right:String = '', $bottomLeft:String = '', $bottom:String = '', $bottomRight:String = ''):void
        {
            _sources = [$topLeft, $top, $topRight, $left, $center, $right, $bottomLeft, $bottom, $bottomRight];

            _al = new VSAssetLoader();
            _al.addEventListener(VSEvent.COMPLETE, _onTileSourcesLoaded, false, 0, true);
            _al.addEventListener(VSIOErrorEvent.IO_ERROR, _onTileSourceIOError, false, 0, true);
            _al.load.apply(null, _sources);
        }

        /**
         * @private
         *
         * Sets the tiles.
         *
         * @param $topLeft
         * @param $top
         * @param $topRight
         * @param $left
         * @param $center
         * @param $right
         * @param $bottomLeft
         * @param $bottom
         * @param $bottomRight
         */
        private function _setTiles($topLeft:BitmapData = null, $top:BitmapData = null, $topRight:BitmapData = null, $left:BitmapData = null, $center:BitmapData = null, $right:BitmapData = null, $bottomLeft:BitmapData = null, $bottom:BitmapData = null, $bottomRight:BitmapData = null):void
        {
            // empty all containers
            while (_tileTL.numChildren > 0) _tileTL.removeChildAt(0);
            while (_tileT.numChildren > 0)  _tileT.removeChildAt(0);
            while (_tileTR.numChildren > 0) _tileTR.removeChildAt(0);
            while (_tileL.numChildren > 0)  _tileL.removeChildAt(0);
            while (_tileC.numChildren > 0)  _tileC.removeChildAt(0);
            while (_tileR.numChildren > 0)  _tileR.removeChildAt(0);
            while (_tileBL.numChildren > 0) _tileBL.removeChildAt(0);
            while (_tileB.numChildren > 0)  _tileB.removeChildAt(0);
            while (_tileBR.numChildren > 0) _tileBR.removeChildAt(0);

            var totalWidth:Number = 0;
            var totalHeight:Number = 0;

            if ($topLeft)     { _tileTL.addChild(new Bitmap($topLeft, PixelSnapping.AUTO, true));                                                           }
            if ($top)         { _tileT.addChild(new Bitmap($top, PixelSnapping.AUTO, true)); totalHeight += $top.height;                                    }
            if ($topRight)    { _tileTR.addChild(new Bitmap($topRight, PixelSnapping.AUTO, true));                                                          }
            if ($left)        { _tileL.addChild(new Bitmap($left, PixelSnapping.AUTO, true)); totalWidth += $left.width;                                    }
            if ($center)      { _tileC.addChild(new Bitmap($center, PixelSnapping.AUTO, true)); totalWidth += $center.width; totalHeight += $center.height; }
            if ($right)       { _tileR.addChild(new Bitmap($right, PixelSnapping.AUTO, true)); totalWidth += $right.width;                                  }
            if ($bottomLeft)  { _tileBL.addChild(new Bitmap($bottomLeft, PixelSnapping.AUTO, true));                                                        }
            if ($bottom)      { _tileB.addChild(new Bitmap($bottom, PixelSnapping.AUTO, true)); totalHeight += $bottom.height;                              }
            if ($bottomRight) { _tileBR.addChild(new Bitmap($bottomRight, PixelSnapping.AUTO, true));                                                       }

            if (width <= 0)
            {
                width = totalWidth - leftOffset - rightOffset;
            }

            if (height <= 0)
            {
                height = totalHeight - topOffset - bottomOffset;
            }
        }

        /**
         * io.variante.events.VSEvent.COMPLETE handler, when all the sources for each tile are loaded.
         *
         * @param $event
         */
        private function _onTileSourcesLoaded($event:VSEvent):void
        {
            var bitmapDataTL:BitmapData = (_al.assets[_sources[0]] == null) ? null : (_al.assets[_sources[0]] as Bitmap).bitmapData;
            var bitmapDataT:BitmapData  = (_al.assets[_sources[1]] == null) ? null : (_al.assets[_sources[1]] as Bitmap).bitmapData;
            var bitmapDataTR:BitmapData = (_al.assets[_sources[2]] == null) ? null : (_al.assets[_sources[2]] as Bitmap).bitmapData;
            var bitmapDataL:BitmapData  = (_al.assets[_sources[3]] == null) ? null : (_al.assets[_sources[3]] as Bitmap).bitmapData;
            var bitmapDataC:BitmapData  = (_al.assets[_sources[4]] == null) ? null : (_al.assets[_sources[4]] as Bitmap).bitmapData;
            var bitmapDataR:BitmapData  = (_al.assets[_sources[5]] == null) ? null : (_al.assets[_sources[5]] as Bitmap).bitmapData;
            var bitmapDataBL:BitmapData = (_al.assets[_sources[6]] == null) ? null : (_al.assets[_sources[6]] as Bitmap).bitmapData;
            var bitmapDataB:BitmapData  = (_al.assets[_sources[7]] == null) ? null : (_al.assets[_sources[7]] as Bitmap).bitmapData;
            var bitmapDataBR:BitmapData = (_al.assets[_sources[8]] == null) ? null : (_al.assets[_sources[8]] as Bitmap).bitmapData;

            setBitmapDataOfTiles(bitmapDataTL, bitmapDataT, bitmapDataTR, bitmapDataL, bitmapDataC, bitmapDataR, bitmapDataBL, bitmapDataB, bitmapDataBR);

            _al.removeEventListener(VSEvent.COMPLETE, _onTileSourcesLoaded);
            _al.removeEventListener(VSIOErrorEvent.IO_ERROR, _onTileSourceIOError);
            _al = null;
            _sources = null;
        }

        /**
         * io.variante.events.VSIOErrorEvent.IO_ERROR handler, when a source path for a tile is invalid.
         *
         * @param $event
         */
        private function _onTileSourceIOError($event:VSIOErrorEvent):void
        {
            // do nothing
        }
    }
}
