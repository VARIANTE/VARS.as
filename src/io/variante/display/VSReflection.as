/**
 *  ©2013 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.display
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.GradientType;
    import flash.display.PixelSnapping;
    import flash.display.SpreadMethod;
    import flash.display.Sprite;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import io.variante.enums.VSDirtyType;
    import io.variante.events.VSEvent;
    import io.variante.utils.VSAssert;
    import io.variante.utils.VSEventTimer;

    /**
     * VSDisplayObject that casts a reflection on another VSDisplayObject.
     */
    public class VSReflection extends VSDisplayObject
    {
        /**
         * @private
         *
         * Target sprite to cast a reflection on.
         */
        private var _target:VSDisplayObject;

        /**
         * @private
         *
         * Alpha level of reflection.
         */
        private var _gradientAlpha:Number;

        /**
         * @private
         *
         * Color opacity ratio of gradient mask (0-1).
         */
        private var _ratio:Number;

        /**
         * @private
         *
         * Distance ratio relative to the target height from beginning of reflection of which the reflection starts to fade away (0-1).
         */
        private var _dropoff:Number;

        /**
         * @private
         *
         * Y-offset of reflection.
         */
        private var _distance:Number;

        /**
         * @private
         *
         * Update time interval in milliseconds.
         */
        private var _updateTime:Number;

        /**
         * @private
         *
         * Boolean value that indicates whether the reflection auto clips onto the target.
         */
        private var _autoClip:Boolean;

        /**
         * @private
         *
         * Gradient mask of reflected bitmap.
         */
        private var _mask:Sprite;

        /**
         * @private
         *
         * Bitmap clone of target.
         */
        private var _reflection:Bitmap;

        /**
         * @private
         *
         * Bitmap data of target.
         */
        private var _targetBitmapData:BitmapData;

        /**
         * Gets the gradient alpha level of the reflection.
         */
        public function get gradientAlpha():Number
        {
            return _gradientAlpha;
        }

        /**
         * Sets the gradient alpha level fo the reflection.
         */
        public function set gradientAlpha($value:Number):void
        {
            if (_gradientAlpha == $value) return;

            VSAssert.assert($value >= 0 && $value <= 1, 'VSReflection gradientAlpha must be between 0 to 1.');

            _gradientAlpha = $value;

            setDirty(VSDirtyType.DATA);
        }

        /**
         * Gets the color opacity ratio of the gradient mask, ranged 0-1.
         */
        public function get ratio():Number
        {
            return _ratio;
        }

        /**
         * Sets the color opacity ratio of the gradient mask, ranged 0-1.
         */
        public function set ratio($value:Number):void
        {
            if (_ratio == $value) return;

            VSAssert.assert($value >= 0 && $value <= 1, 'VSReflection ratio must be between 0 to 1.');

            _ratio = $value;

            setDirty(VSDirtyType.DATA);
        }

        /**
         * Gets the distance ratio relative to the target height from beginning of reflection of which the reflection starts to fade away, ranged (0-1).
         */
        public function get dropoff():Number
        {
            return _dropoff;
        }

        /**
         * Sets the distance ratio relative to the target height from beginning of reflection of which the reflection starts to fade away, ranged (0-1).
         */
        public function set dropoff($value:Number):void
        {
            if (_dropoff == $value) return;

            VSAssert.assert($value >= 0 && $value <= 1, 'VSReflection dropoff must be between 0 to 1.');

            _dropoff = $value;

            setDirty(VSDirtyType.DATA);
        }

        /**
         * Gets the y-offset of the reflection.
         */
        public function get distance():Number
        {
            return _distance;
        }

        /**
         * Sets the y-offset of the reflection.
         */
        public function set distance($value:Number):void
        {
            if (_distance == $value) return;

            _distance = $value;

            setDirty(VSDirtyType.DIMENSION);
        }

        /**
         * Gets the update time interval (ms).
         */
        public function get updateTime():Number
        {
            return _updateTime;
        }

        /**
         * Sets the update time interval (ms).
         */
        public function set updateTime($value:Number):void
        {
            if (_updateTime == $value) return;

            VSAssert.assert($value >= 0, 'VSReflection updateTime must be greater than or equal to 0.');

            _updateTime = $value;

            if (initialized)
            {
                VSEventTimer.removeEvent(_onUpdate);
                VSEventTimer.addEvent(_onUpdate, _updateTime);
            }
        }

        /**
         * Gets the boolean value that indicates whether the reflection auto clips onto the target.
         */
        public function get autoClip():Boolean
        {
            return _autoClip;
        }

        /**
         * Sets the boolean value that indicates whether the reflection auto clips onto the target.
         */
        public function set autoClip($value:Boolean):void
        {
            _autoClip = $value;

            setDirty(VSDirtyType.POSITION);
        }

        /**
         * Creates a new VSReflection instance.
         *
         * @param $target         Target VSDisplayObject to cast reflection on
         * @param $gradientAlpha  Inner alpha of gradient mask
         * @param $ratio          Gradient ratio (0-1)
         * @param $dropoff        Gradient dropoff (0-1)
         * @param $distance       Y-offset
         * @param $updateTime     Update interval in milliseconds
         */
        public function VSReflection($target:VSDisplayObject, $gradientAlpha:Number = 0.4, $ratio:Number = 0.4, $dropoff:Number = 1, $distance:Number = 0, $updateTime:Number = 0)
        {
            _target     = $target;

            gradientAlpha = $gradientAlpha;
            ratio         = $ratio;
            dropoff       = $dropoff;
            distance      = $distance;
            updateTime    = $updateTime;
            autoClip      = true;
        }

        /**
         * @inheritDoc
         */
        override protected function init():void
        {
            if (_target.initialized)
            {
                super.init();
            }
            else
            {
                _target.addEventListener(VSEvent.INIT_COMPLETE, _onTargetInitComplete);
            }
        }

        /**
         * @inheritDoc
         */
        override protected function initComplete():void
        {
            if (_updateTime > 0)
            {
                VSEventTimer.removeEvent(_onUpdate);
                VSEventTimer.addEvent(_onUpdate, _updateTime);
            }

            super.initComplete();
        }
        /**
         * @inheritDoc
         */
        override protected function destroy():void
        {
            VSEventTimer.removeEvent(_onUpdate);

            _killReflection();
            _killMask();

            super.destroy();
        }

        /**
         * @inheritDoc
         */
        override protected function render():void
        {
            var bounds:Rectangle = _target.getBounds(_target);

            if (getDirty(VSDirtyType.DATA))
            {
                _generateReflection();
                _generateMask();
            }

            if (getDirty(VSDirtyType.VIEW))
            {
                _targetBitmapData.dispose();
                _targetBitmapData = new BitmapData(bounds.width, bounds.height, true, 0x000000);
                _targetBitmapData.draw(_target, new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y));
                _reflection.bitmapData = _targetBitmapData;
            }

            if (getDirty(VSDirtyType.DIMENSION))
            {
                _reflection.y = bounds.y + height + _distance;
                _mask.y = _reflection.y - height;
            }

            if (getDirty(VSDirtyType.POSITION))
            {
                if (_autoClip)
                {
                    var globalPoint:Point = _target.localToGlobal(new Point(0, 0));
                    var localPoint:Point = parent.globalToLocal(globalPoint);

                    x = localPoint.x;
                    y = localPoint.y + height;
                }
            }

            super.render();
        }

        /**
         * @private
         *
         * Generates the reflection.
         */
        private function _generateReflection():void
        {
            _killReflection();

            var bounds:Rectangle = _target.getBounds(_target);

            width  = bounds.width;
            height = bounds.height;

            _targetBitmapData = new BitmapData(width, height, true, 0x000000);
            _targetBitmapData.draw(_target, new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y));

            _reflection = new Bitmap(_targetBitmapData, PixelSnapping.AUTO, true);
            _reflection.scaleY = -1;
            _reflection.x = bounds.x;
            _reflection.y = bounds.y + height;
            _reflection.cacheAsBitmap = true;

            addChild(_reflection);
        }

        /**
         * @private
         *
         * Kills the reflection.
         */
        private function _killReflection():void
        {
            if (_reflection == null) return;

            _reflection.mask = null;
            removeChild(_reflection);
            _reflection = null;

            _targetBitmapData.dispose();
            _targetBitmapData = null;
        }

        /**
         * @private
         *
         * Generates the gradient mask.
         */
        private function _generateMask():void
        {
            _killMask();

            var matrixWidth:Number  = width;
            var matrixHeight:Number = height * _dropoff;

            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(matrixWidth, matrixHeight, (90 / 180) * Math.PI, 0, 0);

            _mask = new Sprite();
            _mask.graphics.beginGradientFill(GradientType.LINEAR, [0xFFFFFF, 0xFFFFFF], [_gradientAlpha, 0], [0, _ratio * 255], matrix, SpreadMethod.PAD);
            _mask.graphics.drawRect(0, 0, width, height);
            _mask.cacheAsBitmap = true;
            _mask.x = _reflection.x;
            _mask.y = _reflection.y - height;
            addChild(_mask);

            _reflection.mask = _mask;
        }

        /**
         * @private
         *
         * Kills the gradient mask.
         */
        private function _killMask():void
        {
            if (_mask == null) return;

            if (_reflection != null)
            {
                _reflection.mask = null;
            }

            removeChild(_mask);
            _mask = null;
        }

        /**
         * @private
         *
         * Event handler triggered when target is initialize complete.
         *
         * @param $event
         */
        private function _onTargetInitComplete($event:VSEvent):void
        {
            _target.removeEventListener(VSEvent.INIT_COMPLETE, _onTargetInitComplete);

            super.init();
        }

        /**
         * @private
         *
         * Event handler triggered on each update interval.
         */
        private function _onUpdate():void
        {
            setDirty(VSDirtyType.VIEW);
            setDirty(VSDirtyType.DIMENSION);
            setDirty(VSDirtyType.POSITION);
        }
    }
}