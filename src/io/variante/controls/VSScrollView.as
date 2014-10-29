/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.controls
{
    import flash.display.DisplayObject;
    import flash.display.Shape;
    import io.variante.debug.VSDebug;
    import io.variante.display.VSDisplayObject;
    import io.variante.display.VSInteractiveObject;
    import io.variante.enums.VSDirtyType;
    import io.variante.helpers.VSArtist;
    import io.variante.transitions.VSTween;

    /**
     * Container for scrollable content.
     */
    public class VSScrollView extends VSInteractiveObject
    {
        /**
         * @private
         *
         * Default scroll duration (in seconds).
         */
        private static const DEFAULT_SCROLL_DURATION:Number = 0.3;

        /**
         * @private
         *
         * Custom width.
         */
        private var _width:Number;

        /**
         * @private
         *
         * Custom height.
         */
        private var _height:Number;

        /**
         * @private
         *
         * Top padding of the scrollable content.
         */
        private var _topPadding:Number;

        /**
         * @private
         *
         * Right padding of the scrollable content.
         */
        private var _rightPadding:Number;

        /**
         * @private
         *
         * bottom padding of the scrollable content.
         */
        private var _bottomPadding:Number;

        /**
         * @private
         *
         * Left padding of the scrollable content.
         */
        private var _leftPadding:Number;

        /**
         * @private
         *
         * Display width, this is the width of the viewable area which is masked.
         */
        private var _displayWidth:Number;

        /**
         * @private
         *
         * Display height, this is the height of the viewable area which is masked.
         */
        private var _displayHeight:Number;

        /**
         * @private
         *
         * Starting x-position of the scrollable content.
         */
        private var _startPosX:Number;

        /**
         * @private
         *
         * Ending x-position of the scrollable content.
         */
        private var _endPosX:Number;

        /**
         * @private
         *
         * Starting y-position of the scrollable content.
         */
        private var _startPosY:Number;

        /**
         * @private
         *
         * Ending y-position of the scrollable content.
         */
        private var _endPosY:Number;

        /**
         * @private
         *
         * The mask of the content in this VSScrollView.
         */
        private var _contentMask:Shape;

        /**
         * @private
         *
         * Container for all the contents.
         */
        private var _content:VSDisplayObject;

        /**
         * @private
         *
         * Invisible hit region.
         */
        private var _hitArea:Shape;

        /**
         * @inheritDoc
         */
        override public function set width($value:Number):void
        {
            if (_width == $value) return;

            _width = $value;

            super.width = $value;
        }

        /**
         * @inheritDoc
         */
        override public function set height($value:Number):void
        {
            if (_height == $value) return;

            _height = $value;

            super.height = $value;
        }

        /**
         * Gets/sets the top padding of the scrollable content.
         */
        public function get topPadding():Number { return _topPadding; }
        public function set topPadding($value:Number):void
        {
            if (_topPadding == $value) return;

            _topPadding = $value;

            setDirty(VSDirtyType.DIMENSION);
        }

        /**
         * Gets/sets the right padding of the scrollable content.
         */
        public function get rightPadding():Number { return _rightPadding; }
        public function set rightPadding($value:Number):void
        {
            if (_rightPadding == $value) return;

            _rightPadding = $value;

            setDirty(VSDirtyType.DIMENSION);
        }

        /**
         * Gets/sets the bottom padding of the scrollable content.
         */
        public function get bottomPadding():Number { return _bottomPadding; }
        public function set bottomPadding($value:Number):void
        {
            if (_bottomPadding == $value) return;

            _bottomPadding = $value;

            setDirty(VSDirtyType.DIMENSION);
        }

        /**
         * Gets/sets the left padding of the scrollable content.
         */
        public function get leftPadding():Number { return _leftPadding; }
        public function set leftPadding($value:Number):void
        {
            if (_leftPadding == $value) return;

            _leftPadding = $value;

            setDirty(VSDirtyType.DIMENSION);
        }

        /**
         * Gets/sets the display width of the VSScrollView. This is used
         * by the VSHScrollbar to determine the horizontal scroll region.
         */
        public function get displayWidth():Number { return isNaN(_displayWidth) ? width : _displayWidth; }
        public function set displayWidth($value:Number):void
        {
            if (_displayWidth == $value) return;

            _displayWidth = $value;

            setDirty(VSDirtyType.DIMENSION);
        }

        /**
         * Gets/sets the display height of the VSScrollView. This is used
         * by the VSVScrollbar to determine the vertical scroll region.
         */
        public function get displayHeight():Number { return isNaN(_displayHeight) ? height : _displayHeight; }
        public function set displayHeight($value:Number):void
        {
            if (_displayHeight == $value) return;

            _displayHeight = $value;

            setDirty(VSDirtyType.DIMENSION);
        }

        /**
         * Creates a new VSScrollView instance.
         */
        public function VSScrollView()
        {
            _topPadding    = 0;
            _rightPadding  = 0;
            _bottomPadding = 0;
            _leftPadding   = 0;
            _displayWidth  = NaN;
            _displayHeight = NaN;
            _width         = NaN;
            _height        = NaN;

            _content = new VSDisplayObject();
        }

        /**
         * @inheritDoc
         */
        override protected function init():void
        {
            _hitArea = VSArtist.drawRect(1, 1, 0);

            _contentMask = VSArtist.drawRect(1, 1, 1, 0);

            _content.mask = _contentMask;

            addChild(_hitArea);
            addChild(_contentMask);
            addChild(_content);

            super.init();
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
            if (getDirty(VSDirtyType.CHILDREN))
            {
                if (isNaN(_width)) super.width  = _content.width + _leftPadding + _rightPadding;
                if (isNaN(_height)) super.height = _content.height + _topPadding + _bottomPadding;
            }

            if (getDirty(VSDirtyType.DIMENSION))
            {
                _hitArea.width  = displayWidth;
                _hitArea.height = displayHeight;

                _contentMask.width  = displayWidth;
                _contentMask.height = displayHeight;

                _content.x = _leftPadding;
                _content.y = _topPadding;

                _startPosX = _leftPadding;
                _endPosX   = -(_content.width + _leftPadding + _rightPadding - _displayWidth);
                _startPosY = _topPadding;
                _endPosY   = -(_content.height + _topPadding + _bottomPadding - _displayHeight);
            }

            super.render();
        }

        /**
         * Scrolls to the target position.
         *
         * @param $posX
         * @param $posY
         * @param $duration
         */
        public function scrollTo($posX:Number = NaN, $posY:Number = NaN, $duration:Number = DEFAULT_SCROLL_DURATION):void
        {
            VSDebug.logm(this, 'scrollTo(' + $posX + ', ' + $posY + ', ' + $duration + ')');

            if (!isNaN($posX))
            {
                VSTween.to(_content, $duration, { x: $posX + _leftPadding });
            }

            if (!isNaN($posY))
            {
                VSTween.to(_content, $duration, { y: $posY + _topPadding });
            }
        }

        /**
         * @inheritDoc
         *
         * Override this method so that all display objects except for member display objects
         * will be added to the content container.
         */
        override public function addChild($child:DisplayObject):DisplayObject
        {
            if ($child == _hitArea || $child == _contentMask || $child == _content)
            {
                return super.addChild($child);
            }
            else
            {
                return _content.addChild($child);
            }
        }

        /**
         * @inheritDoc
         *
         * Override this method so that all display objects except for member display objects
         * will be added to the content container.
         */
        override public function addChildAt($child:DisplayObject, $index:int):DisplayObject
        {
            if ($child == _hitArea || $child == _contentMask || $child == _content)
            {
                return super.addChildAt($child, $index);
            }
            else
            {
                return _content.addChildAt($child, $index);
            }
        }

        /**
         * @inheritDoc
         *
         * Override this method so that all display objects except for member display objects
         * will be removed from the content container.
         */
        override public function removeChild($child:DisplayObject):DisplayObject
        {
            if ($child == _hitArea || $child == _contentMask || $child == _content)
            {
                return super.removeChild($child);
            }
            else
            {
                return _content.removeChild($child);
            }
        }

        /**
         * @inheritDoc
         *
         * Override this method so that all display objects except for member display objects
         * will be removed from the content container.
         */
        override public function removeChildAt($index:int):DisplayObject
        {
            return super.removeChildAt($index);
        }
    }
}
