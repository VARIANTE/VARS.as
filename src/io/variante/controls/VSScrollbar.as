/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.controls
{
    import flash.display.Shape;
    import io.variante.debug.VSDebug;
    import io.variante.display.VSInteractiveObject;
    import io.variante.enums.VSDirtyType;
    import io.variante.events.VSEvent;
    import io.variante.events.VSMouseEvent;
    import io.variante.helpers.VSArtist;
    import io.variante.transitions.easing.Quart;
    import io.variante.transitions.VSTween;
    import io.variante.utils.VSAssert;

    /**
     * Horizontal/vertical Scrollbar component without any scroll arrows. This component
     * supports scroll wheels and has a customizable edge buffer region.
     */
    public final class VSScrollbar extends VSInteractiveObject
    {
        /**
         * Use this constant to change this VSScrollbar instance's orientation to vertical.
         */
        public static const VERTICAL:String = 'vertical';

        /**
        * Use this constant to change this VSScrollbar instance's orientation to horizontal.
         */
        public static const HORIZONTAL:String = 'horizontal';

        /**
         * @private
         *
         * Default thickness of the scrollbar, if no thickness is given.
         */
        private static const DEFAULT_THICKNESS:Number = 4;

        /**
         * @private
         *
         * Default length of the scroll bar, if no length is given.
         */
        private static const DEFAULT_LENGTH:Number = 200;

        /**
         * @private
         *
         * Default buffer height ratio at the top/bottom edge, to the height
         * of the scroll knob.
         */
        private static const DEFAULT_EDGE_BUFFER_RATIO:Number = 0.4;

        /**
         * @private
         *
         * Default wheel step, in pixels.
         */
        private static const DEFAULT_STEP:Number = 10;

        /**
         * @private
         *
         * Default hide duration (in seconds).
         */
        private static const DEFAULT_HIDE_DURATION:Number = 0.6;

        /**
         * @private
         *
         * Default hide delay (in seconds).
         */
        private static const DEFAULT_HIDE_DELAY:Number = 0.6;

        /**
         * @private
         *
         * Default scroll duration (in seconds).
         */
        private static const DEFAULT_SCROLL_DURATION:Number = 0.3;

        /**
         * @private
         *
         * Default scroll normalize duration (in seconds).
         */
        private static const DEFAULT_SCROLL_NORMALIZE_DURATION:Number = 0.3;

        /**
         * @private
         *
         * Target VSScrollView of this VSScrollbar.
         */
        private var _target:VSScrollView;

        /**
         * @private
         *
         * Starting y-position of the scroll knob.
         */
        private var _startPos:Number;

        /**
         * @private
         *
         * Ending y-position of the scroll knob.
         */
        private var _endPos:Number;

        /**
         * @private
         *
         * Mouse offset between the mouse y-position and the y-position
         * of the scroll knob.
         */
        private var _dragOffset:Number;

        /**
         * @private
         *
         * Top/bottom buffer height ratio to the height of the scroll knob.
         */
        private var _bufferRatio:Number;

        /**
         * @private
         *
         * Boolean value that indicates whether this scrollbar auto hides when inactive.
         */
        private var _autoHide:Boolean;

        /**
         * @private
         *
         * The number of pixels to scroll in the VSScrollView on each mouse wheel scroll.
         */
        private var _step:Number;

        /**
         * @private
         *
         * Boolean value that indicates whether this component is mouse wheel
         * enabled when hovering over the scrollbar or the scroll view.
         */
        private var _mouseWheelEnabled:Boolean;

        /**
         * @private
         *
         * Boolean value that indicates whether this component is mouse wheel
         * enabled at any point in the stage.
         */
        private var _stageMouseWheelEnabled:Boolean;

        /**
         * @private
         *
         * Boolean value that indicates whether this component is rolled over
         * and therefore can enable local mouse wheel capabilities.
         */
        private var _mouseWheelActivated:Boolean;

        /**
         * @private
         *
         * Boolean value that indicates whether this component has wheel scrolling
         * direction inverted.
         */
        private var _inverted:Boolean;

        /**
         * @private
         *
         * Orientation of this scrollbar, i.e. vertical or horizontal.
         */
        private var _orientation:String;

        /**
         * @private
         *
         * Scroll knob skin, must be a VSButton.
         */
        private var _knobSkin:Class;

        /**
         * @private
         *
         * Scroll track skin, must be a VSButton.
         */
        private var _trackSkin:Class;

        /**
         * @private
         *
         * Mask of the scroll knob.
         */
        private var _knobMask:Shape;

        /**
         * @private
         *
         * Scroll knob of the VSScrollbar.
         */
        private var _knob:VSInteractiveObject;

        /**
         * @private
         *
         * Scroll track of the VSScrollbar.
         */
        private var _track:VSInteractiveObject;

        /**
         * Gets/sets the scroll target, which is a VSScrollView.
         */
        public function get target():VSScrollView { return _target; }
        public function set target($value:VSScrollView):void
        {
            if (_target != null)
            {
                _target.removeEventListener(VSEvent.RENDER, _onTargetRender);
                _target.removeEventListener(VSMouseEvent.ROLL_OVER, _onTargetRollOver);
                _target.removeEventListener(VSMouseEvent.ROLL_OUT, _onTargetRollOut);
            }

            _target = $value;

            if (_target != null)
            {
                _target.addEventListener(VSEvent.RENDER, _onTargetRender);
                _target.addEventListener(VSMouseEvent.ROLL_OVER, _onTargetRollOver);
                _target.addEventListener(VSMouseEvent.ROLL_OUT, _onTargetRollOut);
            }

            setDirty(VSDirtyType.DATA);
        }

        /**
         * Gets/sets the scroll edge buffer (the extra gap of space allowed at the edge of
         * the scroll track).
         */
        public function get bufferRatio():Number { return _bufferRatio; }
        public function set bufferRatio($value:Number):void { _bufferRatio = $value; }

        /**
         * Gets/sets the boolean value that indiciates whether this scrollbar auto hides.
         */
        public function get autoHide():Boolean { return _autoHide; }
        public function set autoHide($value:Boolean):void
        {
            _autoHide = $value;

            setDirty(VSDirtyType.DATA);
        }

        /**
         * Gets/sets the number of pixels each mouse wheel input scrolls on the target VSScrollView.
         */
        public function get step():Number { return _step; }
        public function set step($value:Number):void { _step = $value; }

        /**
         * Gets the current position of the knob, range 0-1.
         */
        public function get position():Number
        {
            return (((_orientation == HORIZONTAL) ? _knob.x : _knob.y) + _startPos) / (_endPos - _startPos);
        }

        /**
         * Gets/sets the boolean value that indicates whether mouse wheel is enabled when
         * hovering over the scrollbar or the scroll view.
         */
        public function get mouseWheelEnabled():Boolean { return _mouseWheelEnabled; }
        public function set mouseWheelEnabled($value:Boolean):void { _mouseWheelEnabled = $value; }

        /**
         * Gets/sets the boolean value that indicates whether mouse wheel is enabled at
         * any point on the stage.
         */
        public function get stageMouseWheelEnabled():Boolean { return _stageMouseWheelEnabled; }
        public function set stageMouseWheelEnabled($value:Boolean):void { _stageMouseWheelEnabled = $value; }

        /**
         * Gets/sets the boolean value that indicates whether scrolling direction is inverted.
         */
        public function get inverted():Boolean { return _inverted; }
        public function set inverted($value:Boolean):void { _inverted = $value; }

        /**
         * Gets/sets the orientation of the VSScrollbar, i.e. vertical or horizontal.
         */
        public function get orientation():String { return _orientation; }
        public function set orientation($value:String):void
        {
            VSAssert.assert(!initialized, 'VSScrollbar orientation is immutable and can only be set before it is initialized.');
            VSAssert.assert($value == VERTICAL || $value == HORIZONTAL, 'Unrecognized VSScrollbar orientation: ' + $value);

            _orientation = $value;
        }

        /**
         * Gets/sets the scroll knob class, must be set before VSScrollbar is initiallized.
         */
        public function get knobSkin():Class { return _knobSkin; }
        public function set knobSkin($value:Class):void
        {
            VSAssert.assert(!initialized, 'Scroll knob skin can only be set before the VSScrollbar is initialized.');

            _knobSkin = $value;
        }

        /**
         * Gets/sets the scroll track class, must be set before VSScrollbar is initiallized.
         */
        public function get trackSkin():Class { return _trackSkin; }
        public function set trackSkin($value:Class):void
        {
            VSAssert.assert(!initialized, 'Scroll track skin can only be set before the VSScrollbar is initialized.');

            _trackSkin = $value;
        }

        /**
         * Creates a new VSScrollbar instance.
         */
        public function VSScrollbar($orientation:String = VERTICAL):void
        {
            _target                 = null;
            _bufferRatio            = DEFAULT_EDGE_BUFFER_RATIO;
            _autoHide               = false;
            _step                   = DEFAULT_STEP;
            _mouseWheelEnabled      = true;
            _stageMouseWheelEnabled = false;
            _mouseWheelActivated    = false;
            _knobSkin               = VSVScrollbarKnob;
            _trackSkin              = VSVScrollbarTrack;

            orientation = $orientation;
            width       = (_orientation == VERTICAL) ? DEFAULT_THICKNESS : DEFAULT_LENGTH;
            height      = (_orientation == VERTICAL) ? DEFAULT_LENGTH : DEFAULT_THICKNESS;
        }

        /**
         * @inheritDoc
         */
        override protected function init():void
        {
            _knobMask = VSArtist.drawRect(1, 1);
            _track = new _trackSkin();
            _knob = new _knobSkin();
            _knob.mask = _knobMask;

            addEventListener(VSMouseEvent.ROLL_OVER, _onRollOver, false, 0, true);
            addEventListener(VSMouseEvent.ROLL_OUT, _onRollOut, false, 0, true);
            addEventListener(VSMouseEvent.MOUSE_WHEEL, _onMouseWheel, false, 0, true);

            _knob.addEventListener(VSMouseEvent.START_DRAG, _onKnobStartDrag, false, 0, true);
            _knob.addEventListener(VSMouseEvent.DRAG, _onKnobDrag, false, 0, true);
            _knob.addEventListener(VSMouseEvent.STOP_DRAG, _onKnobStopDrag, false, 0, true);

            _track.addEventListener(VSMouseEvent.CLICK, _onTrackClick, false, 0, true);

            addChild(_knobMask);
            addChild(_track);
            addChild(_knob);

            super.init();
        }

        /**
         * @inheritDoc
         */
        override protected function initComplete():void
        {
            if (_autoHide)
            {
                alpha = 0;
                visible = false;
            }

            super.initComplete();
        }

        /**
         * @inheritDoc
         */
        override protected function destroy():void
        {
            removeEventListener(VSMouseEvent.ROLL_OVER, _onRollOver);
            removeEventListener(VSMouseEvent.ROLL_OUT, _onRollOut);
            removeEventListener(VSMouseEvent.MOUSE_WHEEL, _onMouseWheel);

            _knob.removeEventListener(VSMouseEvent.START_DRAG, _onKnobStartDrag);
            _knob.removeEventListener(VSMouseEvent.DRAG, _onKnobDrag);
            _knob.removeEventListener(VSMouseEvent.STOP_DRAG, _onKnobStopDrag);

            _track.removeEventListener(VSMouseEvent.CLICK, _onTrackClick);

            target = null;

            super.destroy();
        }

        /**
         * @inheritDoc
         */
        override protected function render():void
        {
            if (getDirty(VSDirtyType.DIMENSION) || getDirty(VSDirtyType.DATA))
            {
                _knobMask.width = width;
                _knobMask.height = height;

                _track.width  = width;
                _track.height = height;

                _knob.width  = (_orientation == VERTICAL) ? width : ((_target == null) ? 0 : ((_target.displayWidth / _target.width) * width));
                _knob.height = (_orientation == VERTICAL) ? ((_target == null) ? 0 : ((_target.displayHeight / _target.height) * height)) : height;

                _startPos = 0;
                _endPos   = (_orientation == VERTICAL) ? (height - _knob.height) : (width - _knob.width);

                // no scrolling required if the display height of the target VSScrollView is already tall enough
                if (_target)
                {
                    if (((_orientation == VERTICAL) && (_target.displayHeight >= _target.height)) || ((_orientation == HORIZONTAL) && (_target.displayWidth >= _target.width)))
                    {
                        _knob.mouseEnabled  = _track.mouseEnabled  = false;
                        _knob.mouseChildren = _track.mouseChildren = false;
                    }
                    else
                    {
                        _knob.mouseEnabled  = _track.mouseEnabled  = true;
                        _knob.mouseChildren = _track.mouseChildren = true;
                    }
                }

                if (_autoHide)
                {
                    VSTween.to(this, DEFAULT_HIDE_DURATION, { autoAlpha: 0, ease: Quart.easeOut });
                }
                else
                {
                    VSTween.to(this, DEFAULT_HIDE_DURATION, { autoAlpha: 1, ease: Quart.easeOut });
                }
            }

            super.render();
        }

        /**
         * Scrolls to the specified position and updates the target scroll view.
         *
         * @param $pos
         * @param $duration
         * @param $ignoreBuffer
         * @param $autoNormalize
         */
        public function scrollTo($pos:Number, $duration:Number = NaN, $ignoreBuffer:Boolean = false, $autoNormalize:Boolean = true):void
        {
            VSDebug.logm(this, 'scrollTo(' + $pos + ', ' + $duration + ', ' + $ignoreBuffer + ', ' + $autoNormalize + ')');

            var targetPos:Number = $pos;
            var buffer:Number    = ($ignoreBuffer) ? 0 : ((_orientation == VERTICAL) ? (_knob.height * _bufferRatio) : (_knob.width * _bufferRatio));
            var duration:Number  = (isNaN($duration) || (((targetPos < _startPos) || (targetPos > _endPos)) && $autoNormalize)) ? DEFAULT_SCROLL_DURATION : $duration;

            // show the scrollbar if autohide is set to true
            if (_autoHide)
            {
                VSTween.to(this, DEFAULT_HIDE_DURATION, { autoAlpha: 1, ease: Quart.easeOut });
            }

            // limit target positions
            if (targetPos < _startPos - buffer)
            {
                targetPos = _startPos - buffer;
            }
            else if (targetPos > _endPos + buffer)
            {
                targetPos = _endPos + buffer;
            }

            if (_orientation == VERTICAL)
            {
                VSTween.to(_knob, duration, { y: targetPos, onComplete: _onScrollComplete, onCompleteParams: [$autoNormalize] });
                if (_target) _target.scrollTo(NaN, -targetPos * (_target.height / height), duration);
            }
            else
            {
                VSTween.to(_knob, duration, { x: targetPos, onComplete: _onScrollComplete, onCompleteParams: [$autoNormalize] });
                if (_target) _target.scrollTo(-targetPos * (_target.width / width), NaN, duration);
            }

            dispatchEvent(new VSEvent(VSEvent.SCROLL, { position: position }));
        }

        /**
         * @private
         *
         * Handler when scrolling is complete, normalizes the knob position if specified.
         *
         * @param $autoNormalize
         */
        private function _onScrollComplete($autoNormalize:Boolean = true):void
        {
            VSDebug.logm(this, '_onScrollComplete(' + $autoNormalize + ')');

            if ($autoNormalize)
            {
                if (((_orientation == VERTICAL) && (_knob.y < _startPos)) || ((_orientation == HORIZONTAL) && (_knob.x < _startPos)))
                {
                    scrollTo(_startPos, DEFAULT_SCROLL_NORMALIZE_DURATION, false, false);
                }
                else if (((_orientation == VERTICAL) && (_knob.y > _endPos)) || ((_orientation == HORIZONTAL) && (_knob.x > _endPos)))
                {
                    scrollTo(_endPos, DEFAULT_SCROLL_NORMALIZE_DURATION, false, false);
                }
            }

            if (_autoHide)
            {
                VSTween.to(this, DEFAULT_HIDE_DURATION, { delay: DEFAULT_HIDE_DELAY, autoAlpha: 0, ease: Quart.easeOut });
            }

            dispatchEvent(new VSEvent(VSEvent.SCROLL_COMPLETE, { position: position }));
        }

        /**
         * @private
         *
         * io.variante.events.VSMouseEvent.ROLL_OVER handler for this scrollbar.
         *
         * @param $event
         */
        private function _onRollOver($event:VSMouseEvent):void
        {
            _mouseWheelActivated = true;
        }

        /**
         * @private
         *
         * io.variante.events.VSMouseEvent.ROLL_OUT handler for this scrollbar.
         * @param $event
         */
        private function _onRollOut($event:VSMouseEvent):void
        {
            _mouseWheelActivated = false;
        }

        /**
         * @private
         *
         * io.variante.events.VSMouseEvent.MOUSE_WHEEL for this scrollbar.
         *
         * @param $event
         */
        private function _onMouseWheel($event:VSMouseEvent):void
        {
            // early return if mouse wheel functionality is not enabled
            if (!(_stageMouseWheelEnabled || (_mouseWheelEnabled && _mouseWheelActivated))) return;

            if (_autoHide && alpha < 1)
            {
                VSTween.to(this, DEFAULT_HIDE_DURATION, { autoAlpha: 1, ease: Quart.easeOut });
            }

            var targetScrollRangeRatio:Number = (_orientation == VERTICAL) ? (height / _target.height) : (width / _target.width);
            var delta:Number                  = (_inverted) ? $event.delta : -$event.delta;
            var displacement:Number           = ((delta > 0) ? -1 : 1) * _step * (2 ^ (-4 * Math.abs(delta) - 1)) *  targetScrollRangeRatio;
            var duration:Number               = Math.abs((2 ^ (-4 * Math.abs(delta) - 1))/15);
            var targetPos:Number              = displacement + ((_orientation == VERTICAL) ? _knob.y : _knob.x);

            scrollTo(targetPos, duration);
        }

        /**
         * @private
         *
         * io.variante.events.VSMouseEvent.START_DRAG handler for the scroll knob.
         *
         * @param $event
         */
        private function _onKnobStartDrag($event:VSMouseEvent):void
        {
            _dragOffset = (_orientation == VERTICAL) ? (mouseY - _knob.y) : (mouseX - _knob.x);

            // while dragging the knob, disable any mouse interactivity on the scroll track
            _track.mouseEnabled  = false;
            _track.mouseChildren = false;
        }

        /**
         * @private
         *
         * io.variante.events.VSMouseEvent.DRAG handler for the scroll knob.
         *
         * @param $event
         */
        private function _onKnobDrag($event:VSMouseEvent):void
        {
            scrollTo(((_orientation == VERTICAL) ? mouseY : mouseX) - _dragOffset, NaN, false, false);
        }

        /**
         * @private
         *
         * io.variante.events.VSMouseEvent.STOP_DRAG handler for the scroll knob.
         *
         * @param $event
         */
        private function _onKnobStopDrag($event:VSMouseEvent):void
        {
            // reset the drag offset
            _dragOffset = 0;

            scrollTo((_orientation == VERTICAL) ? _knob.y : _knob.x, NaN, true, false);

            // reenable mouse interactivity on the scroll track
            _track.mouseEnabled  = true;
            _track.mouseChildren = true;
        }

        /**
         * @private
         *
         * io.variante.events.VSMouseEvent.CLICK handler for the scroll track.
         *
         * @param $event
         */
        private function _onTrackClick($event:VSMouseEvent):void
        {
            if (_orientation == VERTICAL)
            {
                if (mouseY < _knob.y)
                {
                    scrollTo(mouseY, NaN, true);
                }
                else
                {
                    scrollTo(mouseY - _knob.height, NaN, true);
                }
            }
            else
            {
                if (mouseX < _knob.x)
                {
                    scrollTo(mouseX, NaN, true);
                }
                else
                {
                    scrollTo(mouseX - _knob.width, NaN, true);
                }
            }
        }

        /**
         * @private
         *
         * io.variante.events.VSEvent.RENDER handler.
         *
         * @param $event
         */
        private function _onTargetRender($event:VSEvent):void
        {
            var targetDirtyType:uint = uint($event.data);

            if (targetDirtyType == VSDirtyType.DIMENSION)
            {
                setDirty(VSDirtyType.DIMENSION);
            }
        }

        /**
         * @private
         *
         * io.variante.events.VSMouseEvent.ROLL_OVER handler for the scroll view.
         *
         * @param $event
         */
        private function _onTargetRollOver($event:VSMouseEvent):void
        {
            _mouseWheelActivated = true;
        }

        /**
         * @private
         *
         * io.variante.events.VSMouseEvent.ROLL_OUT handler for the scroll view.
         *
         * @param $event
         */
        private function _onTargetRollOut($event:VSMouseEvent):void
        {
            _mouseWheelActivated = false;
        }
    }
}

import io.variante.controls.VSButton;

/**
 * Default scroll knob for VSScrollbar.
 */
internal class VSVScrollbarKnob extends VSButton
{
    public function VSVScrollbarKnob()
    {
        selectable = false;

        defaultIdleSkinColor      = 0x333333;
        defaultHighlightSkinColor = 0xFFFFFF;
        defaultPressedSkinColor   = 0xFFFFFF;
    }
}

/**
 * Default scroll track for VSScrollbar.
 */
internal class VSVScrollbarTrack extends VSButton
{
    public function VSVScrollbarTrack()
    {
        selectable = false;

        defaultIdleSkinColor      = 0x111111;
        defaultHighlightSkinColor = 0x222222;

        pressedSkin = null;
    }
}
