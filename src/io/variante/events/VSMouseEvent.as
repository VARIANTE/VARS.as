/**
 *  (c) VARIANTE <http://variante.io>
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.events
{
    import flash.display.InteractiveObject;
    import flash.events.Event;
    import flash.events.MouseEvent;

    /**
     * Extended flash.events.MouseEvent with the ability to store user data.
     */
    public class VSMouseEvent extends MouseEvent implements IVSInputEvent
    {
        /**
         * VSMouseEvent types.
         */
        public static const CLICK:String            = 'CLICK';
        public static const DOUBLE_CLICK:String     = 'DOUBLE_CLICK';
        public static const CLICK_OUTSIDE:String    = 'CLICK_OUTSIDE';
        public static const MOUSE_DOWN:String       = 'MOUSE_DOWN';
        public static const MOUSE_MOVE:String       = 'MOUSE_MOVE';
        public static const MOUSE_OUT:String        = 'MOUSE_OUT';
        public static const MOUSE_OVER:String       = 'MOUSE_OVER';
        public static const MOUSE_UP:String         = 'MOUSE_UP';
        public static const MOUSE_UP_OUTSIDE:String = 'MOUSE_UP_OUTSIDE';
        public static const MOUSE_WHEEL:String      = 'MOUSE_WHEEL';
        public static const MOUSE_HOLD:String       = 'MOUSE_HOLD';
        public static const ROLL_OUT:String         = 'ROLL_OUT';
        public static const ROLL_OVER:String        = 'ROLL_OVER';
        public static const START_DRAG:String       = 'START_DRAG';
        public static const DRAG:String             = 'DRAG';
        public static const STOP_DRAG:String        = 'STOP_DRAG';
        public static const PRESS:String            = 'PRESS';
        public static const RELEASE:String          = 'RELEASE';

        /**
         * Constants.
         */
        public static var DEFAULT_MIN_MOUSE_WHEEL_DELTA:Number = 3;

        /**
         * Maps VSMouseEvent types to MouseEvent types.
         */
        public static var MOUSE_EVENT_MAP:Object;

        /**
         * User data.
         */
        private var _data:Object;

        /**
         * @inheritDoc
         */
        public function get data():Object { return _data; }

        /**
         * @inheritDoc
         */
        public function set data(value:Object):void { _data = value; }

        /**
         * Static initializer.
         */
        {
            MOUSE_EVENT_MAP = new Object();

            MOUSE_EVENT_MAP[MouseEvent.CLICK]        = CLICK;
            MOUSE_EVENT_MAP[MouseEvent.DOUBLE_CLICK] = DOUBLE_CLICK;
            MOUSE_EVENT_MAP[CLICK_OUTSIDE]           = CLICK_OUTSIDE;
            MOUSE_EVENT_MAP[MouseEvent.MOUSE_DOWN]   = MOUSE_DOWN;
            MOUSE_EVENT_MAP[MouseEvent.MOUSE_MOVE]   = MOUSE_MOVE;
            MOUSE_EVENT_MAP[MouseEvent.MOUSE_OUT]    = MOUSE_OUT;
            MOUSE_EVENT_MAP[MouseEvent.MOUSE_OVER]   = MOUSE_OVER;
            MOUSE_EVENT_MAP[MouseEvent.MOUSE_UP]     = MOUSE_UP;
            MOUSE_EVENT_MAP[MOUSE_UP_OUTSIDE]        = MOUSE_UP_OUTSIDE;
            MOUSE_EVENT_MAP[MouseEvent.MOUSE_WHEEL]  = MOUSE_WHEEL;
            MOUSE_EVENT_MAP[MOUSE_HOLD]              = MOUSE_HOLD;
            MOUSE_EVENT_MAP[MouseEvent.ROLL_OUT]     = ROLL_OUT;
            MOUSE_EVENT_MAP[MouseEvent.ROLL_OVER]    = ROLL_OVER;
            MOUSE_EVENT_MAP[START_DRAG]              = START_DRAG;
            MOUSE_EVENT_MAP[DRAG]                    = DRAG;
            MOUSE_EVENT_MAP[STOP_DRAG]               = STOP_DRAG;
            MOUSE_EVENT_MAP[PRESS]                   = PRESS;
            MOUSE_EVENT_MAP[RELEASE]                 = RELEASE;
        }

        /**
         * Creates a new VSMouseEvent instance.
         *
         * @param $type
         * @param $data
         * @param $bubbles
         * @param $cancelable
         * @param $localX
         * @param $localY
         * @param $relatedObject
         * @param $ctrlKey
         * @param $altKey
         * @param $shiftKey
         * @param $buttonDown
         * @param $delta
         *
         * @see flash.events.MouseEvent
         */
        public function VSMouseEvent($type:String, $data:Object = null, $bubbles:Boolean = true, $cancelable:Boolean = false, $localX:Number = undefined, $localY:Number = undefined, $relatedObject:InteractiveObject = null, $ctrlKey:Boolean = false, $altKey:Boolean = false, $shiftKey:Boolean = false, $buttonDown:Boolean = false, $delta:int = 0):void
        {
            data = $data;
            super($type, $bubbles, $cancelable, $localX, $localY, $relatedObject, $ctrlKey, $altKey, $shiftKey, $buttonDown, $delta);
        }

        /**
         * @inheritDoc
         */
        override public function clone():Event
        {
            return new VSMouseEvent(type, data, bubbles, cancelable, localX, localY, relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta);
        }
    }
}
