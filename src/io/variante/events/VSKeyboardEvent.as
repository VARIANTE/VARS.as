/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.events
{
    import flash.events.Event;
    import flash.events.KeyboardEvent;

    /**
     * Extended flash.events.MouseEvent with the ability to store user data.
     */
    public class VSKeyboardEvent extends KeyboardEvent implements IVSInputEvent
    {
        /**
         * Key codes.
         */
        public static const KEY_BACKSPACE:uint = 8;
        public static const KEY_TAB:uint       = 9;
        public static const KEY_ENTER:uint     = 13;
        public static const KEY_RETURN:uint    = 13;
        public static const KEY_SHIFT:uint     = 16;
        public static const KEY_CTRL:uint      = 17;
        public static const KEY_CAPS_LK:uint   = 20;
        public static const KEY_ESC:uint       = 27;
        public static const KEY_SPACE:uint     = 32;

        public static const KEY_PG_UP:uint = 33;
        public static const KEY_PG_DN:uint = 34;
        public static const KEY_END:uint   = 35;
        public static const KEY_HOME:uint  = 36;

        public static const KEY_ARROW_LEFT:uint  = 37;
        public static const KEY_ARROW_UP:uint    = 38;
        public static const KEY_ARROW_RIGHT:uint = 39;
        public static const KEY_ARROW_DOWN:uint  = 40

        public static const KEY_INS:uint    = 45;
        public static const KEY_DEL:uint    = 46;
        public static const KEY_NUM_LK:uint = 144;
        public static const KEY_SCR_LK:uint = 145;
        public static const KEY_PAUSE:uint  = 19;
        public static const KEY_BREAK:uint  = 19;

        public static const KEY_A:uint = 65;
        public static const KEY_B:uint = 66;
        public static const KEY_C:uint = 67;
        public static const KEY_D:uint = 68;
        public static const KEY_E:uint = 69;
        public static const KEY_F:uint = 70;
        public static const KEY_G:uint = 71;
        public static const KEY_H:uint = 72;
        public static const KEY_I:uint = 73;
        public static const KEY_J:uint = 74;
        public static const KEY_K:uint = 75;
        public static const KEY_L:uint = 76;
        public static const KEY_M:uint = 77;
        public static const KEY_N:uint = 78;
        public static const KEY_O:uint = 79;
        public static const KEY_P:uint = 80;
        public static const KEY_Q:uint = 81;
        public static const KEY_R:uint = 82;
        public static const KEY_S:uint = 83;
        public static const KEY_T:uint = 84;
        public static const KEY_U:uint = 85;
        public static const KEY_V:uint = 86;
        public static const KEY_W:uint = 87;
        public static const KEY_X:uint = 88;
        public static const KEY_Y:uint = 89;
        public static const KEY_Z:uint = 90;

        public static const KEY_0:uint = 48;
        public static const KEY_1:uint = 49;
        public static const KEY_2:uint = 50;
        public static const KEY_3:uint = 51;
        public static const KEY_4:uint = 52;
        public static const KEY_5:uint = 53;
        public static const KEY_6:uint = 54;
        public static const KEY_7:uint = 55;
        public static const KEY_8:uint = 56;
        public static const KEY_9:uint = 57;

        public static const KEY_NUM_0:uint = 96;
        public static const KEY_NUM_1:uint = 97;
        public static const KEY_NUM_2:uint = 98;
        public static const KEY_NUM_3:uint = 99;
        public static const KEY_NUM_4:uint = 100;
        public static const KEY_NUM_5:uint = 101;
        public static const KEY_NUM_6:uint = 102;
        public static const KEY_NUM_7:uint = 103;
        public static const KEY_NUM_8:uint = 104;
        public static const KEY_NUM_9:uint = 105;

        public static const KEY_NUM_MUL:uint = 106;
        public static const KEY_NUM_ADD:uint = 107;
        public static const KEY_NUM_EQL:uint = 108;
        public static const KEY_NUM_SUB:uint = 109;
        public static const KEY_NUM_DEC:uint = 110;
        public static const KEY_NUM_DIV:uint = 111;

        public static const KEY_F1:uint  = 112;
        public static const KEY_F2:uint  = 113;
        public static const KEY_F3:uint  = 114;
        public static const KEY_F4:uint  = 115;
        public static const KEY_F5:uint  = 116;
        public static const KEY_F6:uint  = 117;
        public static const KEY_F7:uint  = 118;
        public static const KEY_F8:uint  = 119;
        public static const KEY_F9:uint  = 120;
        public static const KEY_F10:uint = 121;
        public static const KEY_F11:uint = 122;
        public static const KEY_F12:uint = 123;
        public static const KEY_F13:uint = 124;
        public static const KEY_F14:uint = 125;
        public static const KEY_F15:uint = 126;

        /**
         * VSKeyboardEvent types.
         */
        public static const KEY_DOWN:String = 'KEY_DOWN';
        public static const KEY_UP:String   = 'KEY_UP';
        public static const KEY_HOLD:String = 'KEY_HOLD';

        /**
         * Maps VSKeyboardEvent types to KeyboardEvent types.
         */
        public static var KEYBOARD_EVENT_MAP:Object;

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
            KEYBOARD_EVENT_MAP = new Object();

            KEYBOARD_EVENT_MAP[KeyboardEvent.KEY_DOWN] = KEY_DOWN;
            KEYBOARD_EVENT_MAP[KeyboardEvent.KEY_UP]   = KEY_UP;
            KEYBOARD_EVENT_MAP[KEY_HOLD]               = KEY_HOLD;
        }

        /**
         * Creates a new VSKeyboardEvent instance.
         *
         * @param $type
         * @param $data
         * @param $bubbles
         * @param $cancelable
         * @param $charCodeValue
         * @param $keyCodeValue
         * @param $keyLocationValue
         * @param $ctrlKeyValue
         * @param $altKeyValue
         * @param $shiftKeyValue
         *
         * @see flash.events.KeyboardEvent
         */
        public function VSKeyboardEvent($type:String, $data:Object = null, $bubbles:Boolean = true, $cancelable:Boolean = false, $charCodeValue:uint = 0, $keyCodeValue:uint = 0, $keyLocationValue:uint = 0, $ctrlKeyValue:Boolean = false, $altKeyValue:Boolean = false, $shiftKeyValue:Boolean = false)
        {
            data = $data;
            super($type, $bubbles, $cancelable, $charCodeValue, $keyCodeValue, $keyLocationValue, $ctrlKeyValue, $altKeyValue, $shiftKeyValue);
        }

        /**
         * @inheritDoc
         */
        override public function clone():Event
        {
            return new VSKeyboardEvent(type, data, bubbles, cancelable, charCode, keyCode, keyLocation, ctrlKey, altKey, shiftKey);
        }
    }
}
