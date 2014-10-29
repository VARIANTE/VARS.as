/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.helpers
{
    import flash.display.DisplayObject;
    import flash.display.Shape;
    import flash.filters.ColorMatrixFilter;

    /**
     * A static class containing a bunch of handy helpers functions for
     * creating/modifying DisplayObjects.
     */
    public final class VSArtist
    {
        /**
         * Caches the passed in DisplayObjects as Bitmaps.
         *
         * @param ...$params
         */
        public static function cacheAsBitmap(...$params):void
        {
            for each (var i:DisplayObject in $params)
            {
                i.cacheAsBitmap = true;
            }
        }

        /**
         * Uncaches the passed in DisplayObjects.
         *
         * @param ...$params
         */
        public static function uncacheAsBitmap(...$params):void
        {
            for each (var i:DisplayObject in $params)
            {
                i.cacheAsBitmap = false;
            }
        }

        /**
         * Hides the passed in DisplayObjects from stage.
         *
         * @param ...$params
         */
        public static function hide(...$params):void
        {
            for each (var i:DisplayObject in $params)
            {
                i.alpha = 0;
                i.visible = false;
            }
        }

        /**
         * Shows the passed in DisplayObjects on stage.
         *
         * @param ...$params
         */
        public static function show(...$params):void
        {
            for each (var i:DisplayObject in $params)
            {
                i.alpha = 1;
                i.visible = true;
            }
        }

        /**
         * Resizes specified target DisplayObject to specified width and height, maintaining proportion.
         *
         * @param $target     The target DisplayObject.
         * @param $width      The target width (may be adjusted to fit proportion.
         * @param $height     The target height (may be adjusted to fit proportion.
         */
        public static function resize($target:DisplayObject, $width:Number, $height:Number):void
        {
            var ratio:Number       = $target.width / $target.height;
            var finalWidth:Number  = ($width / ratio >= $height) ? $width : $height * ratio;
            var finalHeight:Number = ($height * ratio >= $width) ? $height : $width / ratio;

            $target.width  = finalWidth;
            $target.height = finalHeight;
        }

        /**
         * Draws a static colored background.
         *
         * @param $width
         * @param $height
         * @param $alpha
         * @param $color
         *
         * @return Sprite instance of the drawn background.
         */
        public static function drawRect($width:Number, $height:Number, $alpha:Number = 0, $color:uint = 0x000000):Shape
        {
            var s:Shape = new Shape();
            s.graphics.beginFill($color, $alpha);
            s.graphics.drawRect(0, 0, $width, $height);
            s.graphics.endFill();

            return s;
        }

        /**
         * Draws a frame.
         *
         * @param $width        Width of frame.
         * @param $height       Height of frame.
         * @param $alpha        Alpha level of frame.
         * @param $thickness    Thickness of frame.
         * @param $color        Color of frame.
         *
         * @return Sprite instance of the drawn frame.
         */
        public static function drawFrame($width:Number, $height:Number, $alpha:Number = 0, $thickness:int = 1, $color:uint = 0x000000):Shape
        {
            var s:Shape = new Shape();
            s.graphics.lineStyle($thickness, $color, $alpha);
            s.graphics.drawRect(0, 0, $width, $height);

            return s;
        }

        /**
         * Desaturates a display object instance.
         *
         * @param $target
         */
        public static function desaturate($target:DisplayObject):void
        {
            var rc:Number = 1 / 3;
            var gc:Number = 1 / 3;
            var bc:Number = 1 / 3;
            var cmf:ColorMatrixFilter = new ColorMatrixFilter([rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, 0, 0, 0, 1, 0]);

            if ($target.filters == null)
            {
                $target.filters = [cmf];
            }
            else
            {
                $target.filters.push(cmf);
            }
        }
    }
}
