/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.debug
{
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.utils.getQualifiedClassName;
    import io.variante.display.VSDisplayObject;
    import io.variante.helpers.VSArtist;
    import io.variante.text.VSTextField;
    import io.variante.utils.VSAssert;
    import io.variante.utils.VSNumberUtil;

    /**
     * Status helpers class mainly containing debugging features.
     */
    public final class VSDebug
    {
        /**
         * Default debug level. At this level no debug traces are active.
         */
        public static const DEBUG_LEVEL_NONE:uint   = 0;

        /**
         * Enables debug traces at low level.
         */
        public static const DEBUG_LEVEL_LOW:uint    = 1;

        /**
         * Enables debug traces at medium level.
         */
        public static const DEBUG_LEVEL_MEDIUM:uint = 2;

        /**
         * Enables debug traces at high level.
         */
        public static const DEBUG_LEVEL_HIGH:uint   = 3;

        /**
         * @private
         *
         * Current debug level, defaults to DEBUG_LEVEL_NONE.
         */
        private static var _debugLevel:uint = DEBUG_LEVEL_NONE;

        /**
         * @private
         *
         * Output panel on the screen when using VSDebug::logs.
         */
        private static var _outputPanel:Sprite;

        /**
         * Gets the current debug level.
         */
        public static function get debugLevel():uint
        {
            return _debugLevel;
        }

        /**
         * Sets the current debug level.
         */
        public static function set debugLevel($value:uint):void
        {
            VSAssert.assert($value <= DEBUG_LEVEL_HIGH, 'Invalid debug level.');

            _debugLevel = $value;
        }

        /**
         * Traces message into debug console at debug level low.
         *
         * @param $classSource
         * @param ...$messages
         */
        public static function logl($classSource:Object, ...$messages):void
        {
            if (_debugLevel < DEBUG_LEVEL_LOW) return;

            var params:Array = $messages;
            params.unshift($classSource);
            _trace.apply(null,  params);
        }

        /**
         * Traces message into debug console at debug level medium.
         *
         * @param $classSource
         * @param ...$messages
         */
        public static function logm($classSource:Object, ...$messages):void
        {
            if (_debugLevel < DEBUG_LEVEL_MEDIUM) return;

            var params:Array = $messages;
            params.unshift($classSource);
            _trace.apply(null,  params);
        }

        /**
         * Traces message into debug console at debug level high.
         *
         * @param $classSource
         * @param ...$messages
         */
        public static function logh($classSource:Object, ...$messages):void
        {
            if (_debugLevel < DEBUG_LEVEL_HIGH) return;

            var params:Array = $messages;
            params.unshift($classSource);
            _trace.apply(null,  params);
        }

        /**
         * @private
         *
         * Traces message into debug console.
         *
         * @param $classSource
         * @param ...$messages
         */
        private static function _trace($classSource:Object, ...$messages):void
        {
            var tag:String;

            if ($classSource is VSDisplayObject)
            {
                tag = VSDisplayObject($classSource).toString();
            }
            else
            {
                tag = '[' + getQualifiedClassName($classSource) + ']';
            }

            trace(tag + ' ' + $messages);
        }

        /**
         * Prints the debug message on the screen, inside the specified container.
         *
         * @param $classSource
         * @param $message
         * @param $stage
         */
        public static function logs($classSource:Object, $message:String, $stage:Stage = null):void
        {
            if (_debugLevel < DEBUG_LEVEL_LOW) return;

            var stage:Stage = (!$stage) ? ($classSource as DisplayObject).stage : $stage;

            VSAssert.assert(stage != null, 'Invalid reference to stage.');

            if (!_outputPanel)
            {
                _outputPanel = new Sprite();

                var shape:Shape = VSArtist.drawRect(1, 5, 1, 0xCCCCCC);

                _outputPanel.addChild(shape);

                var textfield:VSTextField = new VSTextField();
                textfield.color      = 0x000000;
                textfield.autoSize   = VSTextField.AUTOSIZE_LEFT;
                textfield.font       = 'Consolas';
                textfield.size       = 12;
                textfield.selectable = true;
                textfield.multiline  = true;

                _outputPanel.addChild(textfield);
            }

            stage.addChild(_outputPanel);

            var background:Shape = _outputPanel.getChildAt(0) as Shape;
            var outputs:VSTextField = _outputPanel.getChildAt(1) as VSTextField;

            outputs.text += '[' + getQualifiedClassName($classSource) + ']: ' + $message + '\r';

            if (outputs.textWidth + 6 > background.width) { background.width = outputs.textWidth + 6; }
            background.height = outputs.textHeight + 6;
        }

        /**
         * Traces out all the DisplayObjects in the display list of the given DisplayObjectContainer.
         *
         * @param $displayObjectContainer
         */
        public static function traceDisplayList($displayObjectContainer:DisplayObjectContainer):void
        {
            if (_debugLevel < DEBUG_LEVEL_LOW) return;

            logl(VSDebug, 'traceDisplayList(' + '[' + getQualifiedClassName($displayObjectContainer) + ']: ' + $displayObjectContainer.name + ')');
            trace('----------------');
            _traceDisplayList($displayObjectContainer);
            trace('----------------');
        }

        /**
         * @private
         *
         * Traces recursively the DisplayObjects in the display list of the given DisplayobjectContainer.
         *
         * @param $displayObjectContainer
         * @param $depth
         */
        private static function _traceDisplayList($displayObjectContainer:DisplayObjectContainer, $depth:int = 0):void
        {
            var count:uint = 0;

            for (var i:uint = 0; i < $displayObjectContainer.numChildren; i++)
            {
                count++;

                var tabs:String = '  ';

                for (var j:uint = 0; j < $depth; j++)
                {
                    tabs += '  ';
                }

                trace(tabs + VSNumberUtil.formatPositiveIntegerAppendZero(count) + '| ' + '[' + getQualifiedClassName($displayObjectContainer.getChildAt(i)) + ']: ' + $displayObjectContainer.getChildAt(i).name);

                if ($displayObjectContainer.getChildAt(i) is DisplayObjectContainer)
                {
                    _traceDisplayList($displayObjectContainer.getChildAt(i) as DisplayObjectContainer, $depth + 1);
                }
            }
        }

        /**
         * Traces all properties of the passed in object.
         *
         * @param $object
         */
        public static function traceObject($object:Object):void
        {
            if (debugLevel < DEBUG_LEVEL_LOW) return;

            logl(VSDebug, 'traceObject(' + $object + ')');
            trace('----------------');
            _traceObject($object);
            trace('----------------');
        }

        /**
         * @private
         *
         * Traces recursively all properties of the passed in object.
         *
         * @param $object
         * @param $depth
         */
        private static function _traceObject($object:Object, $depth:int = 0):void
        {
            var count:uint = 0;

            for (var k:String in $object)
            {
                count++;

                var tabs:String = '  ';

                for (var i:uint = 0; i < $depth; i++)
                {
                    tabs += '  ';
                }

                trace(tabs + VSNumberUtil.formatPositiveIntegerAppendZero(count) + '| ' + k + ': ' + $object[k]);

                if ($object[k] is Object)
                {
                    _traceObject($object[k], $depth + 1);
                }
            }
        }

        /**
         * Flushes the on-screen debug prints.
         */
        public static function flush():void
        {
            if (_outputPanel)
            {
                _outputPanel.parent.removeChild(_outputPanel);
                _outputPanel = null;
            }
        }
    }
}
