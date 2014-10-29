/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.helpers
{
    import flash.display.DisplayObject;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.geom.PerspectiveProjection;
    import flash.geom.Point;
    import flash.utils.Dictionary;
    import io.variante.display.VSDisplayObject;
    import io.variante.display.VSInteractiveObject;
    import io.variante.events.VSEvent;
    import io.variante.transitions.easing.Quart;
    import io.variante.transitions.VSTween;

    /**
     * A static class used for 'staging' VSInteractiveObject instances on the stage.
     * Essentially it creates the auto mouse panning effect with respect to the dimensions
     * of the specified reference display object or stage.
     *
     * Stager carries 3 types of staging for display objects: CENTER, HORIZONTAL,
     * and VERTICAL. CENTER pans objects with the reference point at the absolute
     * center of the stage/reference display object. HORIZONTAL and VERTICAL panning only sets the x center
     * and y center respectively.
     */
    public final class VSStager
    {
        /**
         * Specifies that the target pans in both x and y-axis.
         */
        public static const CENTER:String = 'center';

        /**
         * Specifies that the target pans in the x-axis only.
         */
        public static const HORIZONTAL:String = 'horizontal';

        /**
         * Specifies that the target pans in the y-axis only.
         */
        public static const VERTICAL:String = 'vertical';

        /**
         * @private
         *
         * Default properties.
         */
        private static const DEFAULT_TOP_PADDING:Number    = 0;
        private static const DEFAULT_RIGHT_PADDING:Number  = 0;
        private static const DEFAULT_BOTTOM_PADDING:Number = 0;
        private static const DEFAULT_LEFT_PADDING:Number   = 0;
        private static const DEFAULT_DURATION:Number       = 0.5;
        private static const DEFAULT_DELAY:Number          = 0;
        private static const DEFAULT_TYPE:String           = CENTER;

        /**
         * @private
         *
         * VSInteractiveObject vector of registrants.
         */
        private static var _registrants:Vector.<VSInteractiveObject>;

        /**
         * @private
         *
         * Maps staging settings to registrants.
         */
        private static var _settingsMap:Dictionary;

        /**
         * Sets the padding of the VSInteractive instance to be staged.
         *
         * @param $target         The target VSInteractiveObject instance.
         * @param $topPadding     Top padding.
         * @param $rightPadding   Right padding.
         * @param $bottomPadding  Bottom padding.
         * @param $leftPadding    Left padding.
         */
        public static function setPadding($target:VSInteractiveObject, $topPadding:Number = 0, $rightPadding:Number = 0, $bottomPadding:Number = 0, $leftPadding:Number = 0):void
        {
            _registerObject($target);

            _settingsMap[$target]['topPadding']    = $topPadding;
            _settingsMap[$target]['rightPadding']  = $rightPadding;
            _settingsMap[$target]['bottomPadding'] = $bottomPadding;
            _settingsMap[$target]['leftPadding']   = $leftPadding;
        }

        /**
         * Sets the staging settings of the VSInteractiveObject instance.
         *
         * @param $target         The target VSInteractiveObject instance.
         * @param $type           The type of panning: HORIZONTAL, VERTICAL, or CENTER.
         * @param $pseudo         Pseudo means the object pans progressively using the distance between
         *                          the mouse pointer and the midpoint rather than with respect to the
         *                          position of the mouse relative to the reference.
         * @param $pivotWidth     Pivot width specifies a fixed reference width to be used when panning
         *                          the object. This should be used if the object changes width during
         *                          runtime.
         * @param $pivotHeight    This serves the same purpose as $pivotWidth, for height.
         * @param $reference      Panning reference of the object (i.e. the parent) and is defaulted
         *                          to the stage if null.
         * @param $duration       Duration of each pan tween.
         * @param $delay          Delay of each pan tween.
         * @param $ease           Ease method of each pan tween.
        */
        public static function setPanSettings($target:VSInteractiveObject, $type:String = 'center', $followMouse:Boolean = false, $pivotWidth:Number = NaN, $pivotHeight:Number = NaN, $reference:Object = null, $duration:Number = NaN, $delay:Number = NaN, $ease:Function = null):void
        {
            _registerObject($target);

            var target:Object = _settingsMap[$target];

            if ($ease != null)        { target['ease']       = $ease;        }
            if (!isNaN($delay))       { target['delay']      = $delay;       }
            if (!isNaN($duration))    { target['duration']   = $duration;    }
            if (!isNaN($pivotWidth))  { target['pivotWidth'] = $pivotWidth;  }
            if (!isNaN($pivotHeight)) { target['pivotHeight']= $pivotHeight; }
            if ($reference != null)   { target['reference']  = $reference;   }
            if ($type != null)        { target['type']       = $type;        }

            target['followMouse'] = $followMouse;
        }

        /**
         * Sets the target VSInteractiveObject instance to auto pan using the specified settings.
         *
         * @param $target         The target VSInteractiveObject instance.
         * @param $type           The type of panning: HORIZONTAL, VERTICAL, or CENTER.
         * @param $pseudo         Pseudo means the object pans progressively using the distance between
         *                          the mouse pointer and the midpoint rather than with respect to the
         *                          position of the mouse relative to the reference.
         * @param $pivotWidth     Pivot width specifies a fixed reference width to be used when panning
         *                          the object. This should be used if the object changes width during
         *                          runtime.
         * @param $pivotHeight    This serves the same purpose as $pivotWidth, for height.
         * @param $reference      Panning reference of the object (i.e. the parent) and is defaulted
         *                          to the stage if null.
         * @param $duration       Duration of each pan tween.
         * @param $delay          Delay of each pan tween.
         * @param $ease           Ease method of each pan tween.
         */
        public static function setAutoPan($target:VSInteractiveObject, $type:String = 'center', $followMouse:Boolean = false, $pivotWidth:Number = NaN, $pivotHeight:Number = NaN, $reference:Object = null, $duration:Number = NaN, $delay:Number = NaN, $ease:Function = null):void
        {
            _registerObject($target);

            setPanSettings($target, $type, $followMouse, $pivotWidth, $pivotHeight, $reference, $duration, $delay, $ease);

            if (!$target.hasEventHandler(VSEvent.ENTER_FRAME, _onRegistrantEnterFrame))
            {
                $target.addEventListener(VSEvent.ENTER_FRAME, _onRegistrantEnterFrame, false, 0, true);
            }
        }

        /**
         * Stops the target VSInteractive instance from auto panning.
         *
         * @param $target
         */
        public static function stopAutoPan($target:VSInteractiveObject):void
        {
            if (_registrants == null || _registrants.indexOf($target) == -1) return;

            if ($target.hasEventHandler(VSEvent.ENTER_FRAME, _onRegistrantEnterFrame))
            {
                $target.removeEventListener(VSEvent.ENTER_FRAME, _onRegistrantEnterFrame);
            }

            VSTween.killTweensOf($target);
        }

        /**
         * Updates the perspective projection of the specified target VSDisplayObject instance.
         *
         * @param $target
         * @param $x
         * @param $y
         * @param $fov
         */
        public static function setPerspectiveProjection($target:VSDisplayObject, $x:Number = NaN, $y:Number = NaN, $fov:Number = 66):void
        {
            var x:Number = (isNaN($x)) ? ($target.stage.stageWidth / 2) : $x;
            var y:Number = (isNaN($y)) ? ($target.stage.stageHeight / 2) : $y;

            var pp:PerspectiveProjection = new PerspectiveProjection();
            pp.projectionCenter = new Point(x, y);
            pp.fieldOfView = $fov;
            $target.transform.perspectiveProjection = pp;
        }

        /**
         * @private
         *
         * Registers the target VSInteractiveObject instance in the registrant dictionary. This will define the staging properties
         * of the target object as well as adding an Event.REMOVED_FROM_STAGE event listener to it.
         *
         * @param $target
         */
        private static function _registerObject($target:VSInteractiveObject):void
        {
            if (_registrants == null)
            {
                _registrants = new Vector.<VSInteractiveObject>();
            }

            if (_registrants.indexOf($target) != -1) return;

            _registrants.push($target);

            if (_settingsMap == null)
            {
                _settingsMap = new Dictionary(true);
            }

            _settingsMap[$target] = new Object();

            _resetSettings($target);

            $target.addEventListener(VSEvent.REMOVED_FROM_STAGE, _onRegistrantRemovedFromStage, false, 0, true);
        }

        /**
         * @private
         *
         * Deregisters the target object from the registrant dictionary, hence removing attached event handlers such as
         * Event.REMOVED_FROM_STAGE and auto panning handlers.
         *
         * @param $target
         */
        private static function _deregisterObject($target:VSInteractiveObject):void
        {
            if (_registrants == null || _registrants.indexOf($target) == -1) return;

            stopAutoPan($target);

            _registrants.splice(_registrants.indexOf($target), 1);
            delete _settingsMap[$target];

            if (_registrants.length == 0)
            {
                _registrants = null;
                _settingsMap = null;
            }

            $target.removeEventListener(Event.REMOVED_FROM_STAGE, _onRegistrantRemovedFromStage);
        }

        /**
         * @private
         *
         * Pans the VSInteractiveObject instance according to specified type: HORIZONTAL, VERTICAL, or CENTER.
         *
         * @param $target         The target VSInteractiveObject instance.
         * @param $type           The type of panning: HORIZONTAL, VERTICAL, or CENTER.
         * @param $pseudo         Pseudo means the object pans progressively using the distance between
         *                          the mouse pointer and the midpoint rather than with respect to the
         *                          position of the mouse relative to the reference.
         * @param $pivotWidth     Pivot width specifies a fixed reference width to be used when panning
         *                          the object. This should be used if the object changes width during
         *                          runtime.
         * @param $pivotHeight    This serves the same purpose as $pivotWidth, for height.
         * @param $reference      Panning reference of the object (i.e. the parent) and is defaulted
         *                          to the stage if null.
         * @param $duration       Duration of each pan tween.
         * @param $delay          Delay of each pan tween.
         * @param $ease           Ease method of each pan tween.
         */
        private static function _pan($target:VSInteractiveObject, $type:String, $followMouse:Boolean, $pivotWidth:Number, $pivotHeight:Number, $reference:DisplayObject, $duration:Number, $delay:Number, $ease:Function):void
        {
            var setting:Object          = _settingsMap[$target];
            var reference:DisplayObject = ($reference) ? $reference : $target.stage;

            // define target and reference width and height
            var refWidth:Number     = (reference is Stage) ? Stage(reference).stageWidth : reference.width;
            var refHeight:Number    = (reference is Stage) ? Stage(reference).stageHeight : reference.height;
            var targetWidth:Number  = (isNaN($pivotWidth)) ? $target.width : $pivotWidth;
            var targetHeight:Number = (isNaN($pivotHeight)) ? $target.height : $pivotHeight;

            // calculate boundaries
            var midpointX:Number    = (refWidth * 0.5) + setting['leftPadding'] - setting['rightPadding'];
            var midpointY:Number    = (refHeight * 0.5) + setting['topPadding'] - setting['bottomPadding'];
            var topOffset:Number    = midpointY - setting['topPadding'];
            var topBound:Number     = setting['topPadding'];
            var rightOffset:Number  = midpointX - setting['rightPadding'];
            var rightBound:Number   = refWidth - setting['rightPadding'];
            var bottomOffset:Number = midpointY - setting['bottomPadding'];
            var bottomBound:Number  = refHeight - setting['bottomPadding'];
            var leftOffset:Number   = midpointX - setting['leftPadding'];
            var leftBound:Number    = setting['leftPadding'];

            // calculate accelerations used when 'pseudo' is true
            var accelerationX:Number  = ((reference.mouseX - midpointX) >= 0) ? ((reference.mouseX - midpointX) / rightOffset): ((reference.mouseX - midpointX) / leftOffset);
            var accelerationY:Number  = ((reference.mouseY - midpointY) >= 0) ? ((reference.mouseY - midpointY) / bottomOffset): ((reference.mouseY - midpointY) / topOffset);

            setting['accelerationX'] = accelerationX;
            setting['accelerationY'] = accelerationY;

            // Condition #1: no panning is needed i.e. target width and height is smaller than pan area
            if (((refWidth - setting['leftPadding'] - setting['rightPadding']) > targetWidth) && ((refHeight - setting['topPadding'] - setting['bottomPadding']) > targetHeight))
            {
                if ((refWidth - setting['leftPadding'] - setting['rightPadding']) > targetWidth)
                {
                    switch ($type)
                    {
                        case CENTER:
                            $target.x = reference.x + setting['leftPadding'] - setting['rightPadding'] + ((refWidth - targetWidth) * 0.5);
                            break;
                        case HORIZONTAL:
                            $target.x = reference.x + setting['leftPadding'] - setting['rightPadding'] + ((refWidth - targetWidth) * 0.5);
                            break;
                        case VERTICAL:
                            // do nothing
                            break;
                    }
                }

                if ((refHeight - setting['topPadding'] - setting['bottomPadding']) > targetHeight)
                {
                    switch ($type)
                    {
                        case CENTER:
                            $target.y = reference.y + setting['topPadding'] - setting['bottomPadding'] + ((refHeight - targetHeight) * 0.5);
                            break;
                        case HORIZONTAL:
                            // do nothing
                            break;
                        case VERTICAL:
                            $target.y = reference.y + setting['topPadding'] - setting['bottomPadding'] + ((refHeight - targetHeight) * 0.5);
                            break;
                    }
                }
            }
            // Condition #2: panning is needed i.e. target width and height is larger than pan area
            else
            {
                if ((reference.mouseX >= reference.x) && (reference.mouseX <= refWidth) && (reference.mouseY >= reference.y) && (reference.mouseY <= refHeight))
                {
                    if ($followMouse)
                    {
                        switch ($type)
                        {
                            case CENTER:
                                VSTween.to($target, $duration,
                                             {
                                                     x: ((rightBound - leftBound) - targetWidth) * ((reference.mouseX - setting['leftPadding']) / (rightBound - leftBound)),
                                                     y: ((bottomBound - topBound) - targetHeight) * ((reference.mouseY - setting['topPadding']) / (bottomBound - topBound)),
                                                 delay: $delay,
                                                  ease: $ease
                                             });
                                break;
                            case HORIZONTAL:
                                VSTween.to($target, $duration,
                                             {
                                                     x: ((rightBound - leftBound) - targetWidth) * ((reference.mouseX - setting['leftPadding']) / (rightBound - leftBound)),
                                                 delay: $delay,
                                                  ease: $ease
                                             });
                                break;
                            case VERTICAL:
                                VSTween.to($target, $duration,
                                             {
                                                     y: ((bottomBound - topBound) - targetHeight) * ((reference.mouseY - setting['topPadding']) / (bottomBound - topBound)),
                                                 delay: $delay,
                                                  ease: $ease
                                             });
                                break;
                        }
                    }
                    else
                    {
                        switch ($type)
                        {
                            case CENTER:
                                var xTarget:Number = $target.x;
                                var yTarget:Number = $target.y;

                                if ((reference.mouseX < (midpointX - 50)) || (reference.mouseX > (midpointX + 50)))
                                {
                                    if (accelerationX >= 0)
                                    {
                                        xTarget = ($target.x > ((rightBound - leftBound) - targetWidth)) ? ($target.x - accelerationX * 60) : ((rightBound - leftBound) - targetWidth);
                                    }
                                    else
                                    {
                                        xTarget = ($target.x < 0) ? ($target.x - accelerationX * 60) : 0;
                                    }
                                }

                                if ((reference.mouseY < (midpointY - 50)) || (reference.mouseY > (midpointY + 50)))
                                {
                                    if (accelerationY >= 0)
                                    {
                                        yTarget = ($target.y > ((bottomBound - topBound) - targetHeight)) ? ($target.y - accelerationY * 60) : yTarget = ((bottomBound - topBound) - targetHeight);
                                    }
                                    else
                                    {
                                        yTarget = ($target.y < 0) ? ($target.y - accelerationY * 60) : 0;
                                    }
                                }

                                VSTween.to($target, $duration, {x:xTarget, y:yTarget, ease:Quart.easeOut});

                                break;
                            case HORIZONTAL:
                                if ((reference.mouseX < (midpointX - 50)) || (reference.mouseX > (midpointX + 50)))
                                {
                                    if (accelerationX >= 0)
                                    {
                                        if ($target.x > ((rightBound - leftBound) - targetWidth))
                                        {
                                            VSTween.to($target, $duration, {x:$target.x - accelerationX * 60, ease:Quart.easeOut});
                                        }
                                        else
                                        {
                                            VSTween.to($target, $duration, {x:(rightBound - leftBound) - targetWidth, ease:Quart.easeOut});
                                        }
                                    }
                                    else
                                    {
                                        if ($target.x < 0)
                                        {
                                            VSTween.to($target, $duration, {x:$target.x - accelerationX * 60, ease:Quart.easeOut});
                                        }
                                        else
                                        {
                                            VSTween.to($target, $duration, {x:0, ease:Quart.easeOut});
                                        }
                                    }
                                }
                                break;
                            case VERTICAL:
                                if ((reference.mouseY < (midpointY - 50)) || (reference.mouseY > (midpointY + 50)))
                                {
                                    if (accelerationY >= 0)
                                    {
                                        if ($target.y > ((bottomBound - topBound) - targetHeight))
                                        {
                                            VSTween.to($target, $duration, {y:$target.y - accelerationY * 60, ease:Quart.easeOut});
                                        }
                                        else
                                        {
                                            VSTween.to($target, $duration, {y:(bottomBound - topBound) - targetHeight, ease:Quart.easeOut});
                                        }
                                    }
                                    else
                                    {
                                        if ($target.y < 0)
                                        {
                                            VSTween.to($target, $duration, {y:$target.y - accelerationY * 60, ease:Quart.easeOut});
                                        }
                                        else
                                        {
                                            VSTween.to($target, $duration, {y:0, ease:Quart.easeOut});
                                        }
                                    }
                                }

                                break;
                        }
                    }
                }
            }
        }

        /**
         * @private
         *
         * Resets panning properties of target VSInteractiveObject instance to default values.
         *
         * @param $target
         */
        private static function _resetSettings($target:VSInteractiveObject):void
        {
            _settingsMap[$target]['topPadding']    = DEFAULT_TOP_PADDING;
            _settingsMap[$target]['rightPadding']  = DEFAULT_RIGHT_PADDING;
            _settingsMap[$target]['bottomPadding'] = DEFAULT_BOTTOM_PADDING;
            _settingsMap[$target]['leftPadding']   = DEFAULT_LEFT_PADDING;
            _settingsMap[$target]['type']          = DEFAULT_TYPE;
            _settingsMap[$target]['pivotWidth']    = NaN;
            _settingsMap[$target]['pivotHeight']   = NaN;
            _settingsMap[$target]['reference']     = null;
            _settingsMap[$target]['followMouse']   = false;
            _settingsMap[$target]['duration']      = DEFAULT_DURATION;
            _settingsMap[$target]['delay']         = DEFAULT_DELAY;
            _settingsMap[$target]['ease']          = null;
            _settingsMap[$target]['accelerationX'] = 0;
            _settingsMap[$target]['accelerationY'] = 0;
        }

        /**
         * @private
         *
         * VSEvent.ENTER_FRAME handler for staged registrants.
         *
         * @param $event
         */
        private static function _onRegistrantEnterFrame($event:VSEvent):void
        {
            for (var i:uint = 0; i < _registrants.length; i++)
            {
                var target:Object = _settingsMap[_registrants[i]];

                _pan(_registrants[i], target['type'], target['followMouse'], target['pivotWidth'], target['pivotHeight'], target['reference'], target['duration'], target['delay'], target['ease']);
            }
        }

        /**
         * @private
         *
         * VSEvent.REMOVED_FROM_STAGE handler for staged registrants.
         *
         * @param $event
         */
        private static function _onRegistrantRemovedFromStage($event:Event):void
        {
            var target:VSInteractiveObject = $event.target as VSInteractiveObject;

            _deregisterObject(target);
        }
    }
}
