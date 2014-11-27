/**
 *  (c) VARIANTE <http://variante.io>
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.display
{
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import io.variante.enums.VSDirtyType;
    import io.variante.events.VSEvent;
    import io.variante.events.VSKeyboardEvent;
    import io.variante.events.VSMouseEvent;
    import io.variante.system.VSPrioritizedInputBroadcaster;

    /**
     * Dispatched when the mouse clicks the VSInteractiveObject.
     *
     * @eventType io.variante.events.VSMouseEvent.CLICK
     */
    [Event(name = 'CLICK', type = 'io.variante.events.VSMouseEvent')]

    /**
     * Dispatched when the mouse double clicks the VSInteractiveObject.
     *
     * @eventType io.variante.events.VSMouseEvent.DOUBLE_CLICK
     */
    [Event(name = 'DOUBLE_CLICK', type = 'io.variante.events.VSMouseEvent')]

    /**
     * Dispatched when the mouse clicks outside of the VSInteractiveObject.
     *
     * @eventType io.variante.events.VSMouseEvent.CLICK_OUTSIDE
     */
    [Event(name = 'CLICK_OUTSIDE', type = 'io.variante.events.VSMouseEvent')]

    /**
     * Dispatched when the mouse button is down on the VSinteractiveObject.
     *
     * @eventType io.variante.events.VSMouseEvent.MOUSE_DOWN
     */
    [Event(name = 'MOUSE_DOWN', type = 'io.variante.events.VSMouseEvent')]

    /**
     * Dispatched when the mouse moves on the VSinteractiveObject.
     *
     * @eventType io.variante.events.VSMouseEvent.MOUSE_MOVE
     */
    [Event(name = 'MOUSE_MOVE', type = 'io.variante.events.VSMouseEvent')]

    /**
     * Dispatched when the mouse is moved out of the VSInteractiveObject.
     *
     * @eventType io.variante.events.VSMouseEvent.MOUSE_OUT
     */
    [Event(name = 'MOUSE_OUT', type = 'io.variante.events.VSMouseEvent')]

    /**
     * Dispatched when the mouse moves over the VSInteractiveObject.
     *
     * @eventType io.variante.events.VSMouseEvent.MOUSE_OVER
     */
    [Event(name = 'MOUSE_OVER', type = 'io.variante.events.VSMouseEvent')]

    /**
     * Dispatched when the mouse button is up on the VSInteractiveObject.
     *
     * @eventType io.variante.events.VSMouseEvent.CLICK_OUTSIDE
     */
    [Event(name = 'MOUSE_UP', type = 'io.variante.events.VSMouseEvent')]

    /**
     * Dispatched when the mouse button is up outside of the VSInteractiveObject, after a mouse down.
     */
    [Event(name = 'MOUSE_UP_OUTSIDE', type = 'io.variante.events.VSMouseEvent')]

    /**
     * Dispatched when the mouse wheel is rolled on the VSInteractiveObject.
     *
     * @eventType io.variante.events.VSMouseEvent.CLICK_OUTSIDE
     */
    [Event(name = 'MOUSE_WHEEL', type = 'io.variante.events.VSMouseEvent')]

    /**
     * Dispatched when the left mouse button is held down on the VSInteractiveObject.
     *
     * @eventType io.variante.events.VSMouseEvent.MOUSE_HOLD
     */
    [Event(name = 'MOUSE_HOLD', type = 'io.variante.events.VSMouseEvent')]

    /**
     * Dispatched when the mouse is rolled out of the VSInteractiveObject.
     *
     * @eventType io.variante.events.VSMouseEvent.CLICK_OUTSIDE
     */
    [Event(name = 'ROLL_OUT', type = 'io.variante.events.VSMouseEvent')]

    /**
     * Dispatched when the mouse is rolled over the VSInteractiveObject.
     *
     * @eventType io.variante.events.VSMouseEvent.CLICK_OUTSIDE
     */
    [Event(name = 'ROLL_OVER', type = 'io.variante.events.VSMouseEvent')]

    /**
     * Dispatched when the VSInteractiveObject starts dragging.
     *
     * @eventType io.variante.events.VSMouseEvent.START_DRAG
     */
    [Event(name = 'START_DRAG', type = 'io.variante.events.VSMouseEvent')]

    /**
     * Dispatched when the VSInteractiveObject is dragging.
     *
     * @eventType io.variante.events.VSMouseEvent.DRAG
     */
    [Event(name = 'DRAG', type = 'io.variante.events.VSMouseEvent')]

    /**
     * Dispatched when the VSInteractiveObject stops dragging.
     *
     * @eventType io.variante.events.VSMouseEvent.STOP_DRAG
     */
    [Event(name = 'STOP_DRAG', type = 'io.variante.events.VSMouseEvent')]

    /**
     * Dispatched when the VSInteractiveObject picks up a key down event.
     *
     * @eventType io.variante.events.VSKeyboardEvent.KEY_DOWN
     */
    [Event(name = 'KEY_DOWN', type = 'io.variante.events.VSKeyboardEvent')]

    /**
     * Dispatched when the VSInteractiveObject picks up a key up event.
     *
     * @eventType io.variante.events.VSKeyboardEvent.KEY_UP
     */
    [Event(name = 'KEY_UP', type = 'io.variante.events.VSKeyboardEvent')]

    /**
     * Dispatched when the VSInteractiveObject picks up a key hold event.
     *
     * @eventType io.variante.events.VSKeyboardEvent.KEY_HOLD
     */
    [Event(name = 'KEY_HOLD', type = 'io.variante.events.VSKeyboardEvent')]

    /**
     * Dispatched when the VSInteractiveObject picks up an enter frame event.
     *
     * @eventType io.variante.events.VSEvent.ENTER_FRAME
     */
    [Event(name = 'ENTER_FRAME', type = 'io.variante.events.VSEvent')]

    /**
     * Abstract class for DisplayObject with extended mouse interactions, including
     * drag n' drop and click outside.
     */
    public class VSInteractiveObject extends VSDisplayObject
    {
        /**
         * @private
         *
         * Boolean value that indicates whether this VSInteractiveObject is mouse interactive.
         */
        private var _interactive:Boolean;

        /**
         * @private
         *
         * Mouse input channel of this VSInteractiveObject instance.
         */
        private var _inputChannel:uint;

        /**
         * @private
         *
         * Boolean value that indicates whether this VSInteractiveObject inherits the input channel
         * from its parent VSInteractiveObject.
         */
        private var _inheritInteractivity:Boolean;

        /**
         * Gets the boolean value that indicates whether this VSInteractiveObject is mouse interactive.
         */
        public function get interactive():Boolean
        {
            return _interactive;
        }

        /**
         * Sets the boolean value that indicates whether this VSInteractiveObject is mouse interactive.
         * This property is refreshed every time VSPrioritizedInputBroadcaster invalidates its registrants.
         */
        public function set interactive($value:Boolean):void
        {
            if (_interactive == $value) return;

            _interactive = $value;

            if (_interactive)
            {
                if (initialized)
                {
                    _initInteractions();
                }
            }
            else
            {
                if (initialized)
                {
                    _destroyInteractions();
                }
            }

            setDirty(VSDirtyType.STATE);
        }

        /**
         * Gets the input channel of this VSInteractiveObject.
         */
        public function get inputChannel():uint
        {
            return _inputChannel;
        }

        /**
         * Creates a new VSInteractiveObject instance.
         */
        public function VSInteractiveObject()
        {
            _interactive = true;
        }

        /**
         * @inheritDoc
         */
        override protected function init():void
        {
            // immutable input channel is set at the contructor
            _inputChannel = VSPrioritizedInputBroadcaster.inputChannel;

            VSPrioritizedInputBroadcaster.register(this);

            super.init();
        }

        /**
         * @inheritDoc
         */
        override protected function destroy():void
        {
            VSPrioritizedInputBroadcaster.deregister(this);

            super.destroy();
        }

        /**
         * @inheritDoc
         */
        override protected function initComplete():void
        {
            if (_interactive)
            {
                _initInteractions();
            }

            super.initComplete();
        }

        /**
         * @inheritDoc
         */
        override protected function transitionOut():void
        {
            if (_interactive)
            {
                _destroyInteractions();
            }

            super.transitionOut();
        }

        /**
         * @private
         *
         * Initializes all mouse interactions.
         */
        private function _initInteractions():void
        {
            // set up click outside event
            stage.addEventListener(MouseEvent.MOUSE_DOWN, _onClickOutside, true);

            // set up mouse wheel event
            stage.addEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);

            // set up events followed by a mouse down event
            addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown, false, 0, true);

            // set up enter frame event
            addEventListener(Event.ENTER_FRAME, _onEnterFrame, false, 0, true);

            // set up the rest of the native mouse events
            for (var mouseEventType:String in VSMouseEvent.MOUSE_EVENT_MAP)
            {
                if (mouseEventType != VSMouseEvent.MOUSE_EVENT_MAP[mouseEventType])
                {
                    addEventListener(mouseEventType, _onNativeMouseEvent, false, 0, true);
                }
            }

            // set up events followed by a key down event
            stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown, false, 0, true);

            // set up the native keyboard events
            for (var keyboardEventType:String in VSKeyboardEvent.KEYBOARD_EVENT_MAP)
            {
                if (keyboardEventType != VSKeyboardEvent.KEYBOARD_EVENT_MAP[keyboardEventType])
                {
                    stage.addEventListener(keyboardEventType, _onNativeKeyboardEvent, false, 0, true);
                }
            }
        }

        /**
         * @private
         *
         * Destroys all mouse interactions.
         */
        private function _destroyInteractions():void
        {
            stage.removeEventListener(MouseEvent.MOUSE_DOWN, _onClickOutside, true);
            stage.removeEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
            removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
            removeEventListener(Event.ENTER_FRAME, _onEnterFrame);

            for (var mouseEventType:String in VSMouseEvent.MOUSE_EVENT_MAP)
            {
                if ((mouseEventType != VSMouseEvent.MOUSE_WHEEL) && (mouseEventType != VSMouseEvent.MOUSE_EVENT_MAP[mouseEventType]))
                {
                    removeEventListener(mouseEventType, _onNativeMouseEvent);
                }
            }

            stage.removeEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
            if (stage.hasEventListener(KeyboardEvent.KEY_UP)) stage.removeEventListener(KeyboardEvent.KEY_UP, _onKeyUp);
            if (hasEventHandler(Event.ENTER_FRAME, _onKeyHold)) removeEventListener(Event.ENTER_FRAME, _onKeyHold);

            for (var keyboardEventType:String in VSKeyboardEvent.KEYBOARD_EVENT_MAP)
            {
                if (keyboardEventType != VSKeyboardEvent.KEYBOARD_EVENT_MAP[keyboardEventType])
                {
                    stage.removeEventListener(keyboardEventType, _onNativeKeyboardEvent);
                }
            }
        }

        /**
         * @private
         *
         * MouseEvent handler for all MouseEvent types, to dispatch the VSMouseEvent equivalent.
         *
         * @param $event
         */
        private function _onNativeMouseEvent($event:MouseEvent):void
        {
            if (!VSPrioritizedInputBroadcaster.validateInputChannel(_inputChannel) || VSPrioritizedInputBroadcaster.asleep) return;

            dispatchEvent(new VSMouseEvent(VSMouseEvent.MOUSE_EVENT_MAP[$event.type], null, $event.bubbles, $event.cancelable, $event.localX, $event.localY, $event.relatedObject, $event.ctrlKey, $event.altKey, $event.shiftKey, $event.buttonDown, $event.delta));
        }

        /**
         * @private
         *
         * KeyboardEvent handler for all KeyboardEvent types, to dispatch the VSKeyboardEvent equivalent.
         *
         * @param $event
         */
        private function _onNativeKeyboardEvent($event:KeyboardEvent):void
        {
            if (!VSPrioritizedInputBroadcaster.validateInputChannel(_inputChannel) || VSPrioritizedInputBroadcaster.asleep) return;

            dispatchEvent(new VSKeyboardEvent(VSKeyboardEvent.KEYBOARD_EVENT_MAP[$event.type], null, false, $event.cancelable, $event.charCode, $event.keyCode, $event.keyLocation, $event.ctrlKey, $event.altKey, $event.shiftKey));
        }

        /**
         * @private
         *
         * VSMouseEvent.CLICK_OUTSIDE handler triggered when mouse clicks outside of this VSInteractiveObject instance.
         *
         * @param $event
         */
        private function _onClickOutside($event:MouseEvent):void
        {
            if (!VSPrioritizedInputBroadcaster.validateInputChannel(_inputChannel) || VSPrioritizedInputBroadcaster.asleep) return;

            if (!contains($event.target as DisplayObject))
            {
                dispatchEvent(new VSMouseEvent(VSMouseEvent.CLICK_OUTSIDE, null, $event.bubbles, $event.cancelable, $event.localX, $event.localY, $event.relatedObject, $event.ctrlKey, $event.altKey, $event.shiftKey, $event.buttonDown, $event.delta));
            }
        }

        /**
         * @private
         *
         * MouseEvent.MOUSE_WHEEL handler triggered when MouseEvent.MOUSE_WHEEL event is dispatched during the scope of this VSInteractiveObject instance.
         *
         * @param $event
         */
        private function _onMouseWheel($event:MouseEvent):void
        {
            if (!VSPrioritizedInputBroadcaster.validateInputChannel(_inputChannel) || VSPrioritizedInputBroadcaster.asleep) return;

            dispatchEvent(new VSMouseEvent(VSMouseEvent.MOUSE_WHEEL, null, $event.bubbles, $event.cancelable, $event.localX, $event.localY, $event.relatedObject, $event.ctrlKey, $event.altKey, $event.shiftKey, $event.buttonDown, $event.delta));
        }

        /**
         * @private
         *
         * Event.ENTER_FRAME handler triggered when left mouse button is held during the scope of this VSInteractiveObject instance.
         *
         * @param $event
         */
        private function _onMouseHold($event:Event):void
        {
            if (!VSPrioritizedInputBroadcaster.validateInputChannel(_inputChannel) || VSPrioritizedInputBroadcaster.asleep) return;

            dispatchEvent(new VSMouseEvent(VSMouseEvent.MOUSE_HOLD, null, true));
        }

        /**
         * @private
         *
         * MouseEvent.MOUSE_DOWN handler triggered on mouse down on this VSInteractiveObject instance, to prepare for drag
         * if the mouse moves and to prepare for mouse hold detection.
         *
         * @param $event
         */
        private function _onMouseDown($event:MouseEvent):void
        {
            stage.addEventListener(MouseEvent.MOUSE_MOVE, _onStartDrag);
            stage.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
            stage.addEventListener(MouseEvent.MOUSE_UP, _onMouseUpOutside);
            stage.addEventListener(Event.ENTER_FRAME, _onMouseHold);
        }

        /**
         * @private
         *
         * MouseEvent.MOUSE_UP handler for the stage triggered to cancel preparation for drag if
         * the mouse never moves and is released.
         *
         * @param $event
         */
        private function _onMouseUp($event:MouseEvent):void
        {
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, _onStartDrag);
            stage.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
            stage.removeEventListener(Event.ENTER_FRAME, _onMouseHold);
        }

        /**
         * @private
         *
         * MouseEvent.MOUSE_UP handler for the stage, to notify that the mouse is released
         * outside of the target VSInteractiveObject instance.
         *
         * @param $event
         */
        private function _onMouseUpOutside($event:MouseEvent):void
        {
            stage.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUpOutside);

            if (!VSPrioritizedInputBroadcaster.validateInputChannel(_inputChannel) || VSPrioritizedInputBroadcaster.asleep) return;

            dispatchEvent(new VSMouseEvent(VSMouseEvent.MOUSE_UP_OUTSIDE, null, true, $event.cancelable, $event.localX, $event.localY, $event.relatedObject, $event.ctrlKey, $event.altKey, $event.shiftKey, $event.buttonDown, $event.delta));
        }

        /**
         * @private
         *
         * VSMouseEvent.START_DRAG handler triggered when this VSInteractiveObject instance begins to drag.
         *
         * @param $event
         */
        private function _onStartDrag($event:MouseEvent):void
        {
            stage.addEventListener(MouseEvent.MOUSE_MOVE, _onDrag);
            stage.addEventListener(MouseEvent.MOUSE_UP, _onStopDrag);

            stage.removeEventListener(MouseEvent.MOUSE_MOVE, _onStartDrag);
            stage.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
            stage.removeEventListener(Event.ENTER_FRAME, _onMouseHold);

            if (!VSPrioritizedInputBroadcaster.validateInputChannel(_inputChannel) || VSPrioritizedInputBroadcaster.asleep) return;

            dispatchEvent(new VSMouseEvent(VSMouseEvent.START_DRAG, null, $event.bubbles, $event.cancelable, $event.localX, $event.localY, $event.relatedObject, $event.ctrlKey, $event.altKey, $event.shiftKey, $event.buttonDown, $event.delta));
        }

        /**
         * @private
         *
         * VSMouseEvent.DRAG handler triggered when this VSInteractiveObject instance is dragging.
         *
         * @param $event
         */
        private function _onDrag($event:MouseEvent):void
        {
            if (!VSPrioritizedInputBroadcaster.validateInputChannel(_inputChannel) || VSPrioritizedInputBroadcaster.asleep) return;

            dispatchEvent(new VSMouseEvent(VSMouseEvent.DRAG, null, $event.bubbles, $event.cancelable, $event.localX, $event.localY, $event.relatedObject, $event.ctrlKey, $event.altKey, $event.shiftKey, $event.buttonDown, $event.delta));
        }

        /**
         * @private
         *
         * VSMouseEvent.STOP_DRAG handler triggered when this VSInteractiveObject instance stops dragging.
         *
         * @param $event
         */
        private function _onStopDrag($event:MouseEvent):void
        {
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, _onDrag);
            stage.removeEventListener(MouseEvent.MOUSE_UP, _onStopDrag);

            if (!VSPrioritizedInputBroadcaster.validateInputChannel(_inputChannel) || VSPrioritizedInputBroadcaster.asleep) return;

            dispatchEvent(new VSMouseEvent(VSMouseEvent.STOP_DRAG, null, $event.bubbles, $event.cancelable, $event.localX, $event.localY, $event.relatedObject, $event.ctrlKey, $event.altKey, $event.shiftKey, $event.buttonDown, $event.delta));
        }

        /**
         * @private
         *
         * KeyboardEvent.KEY_DOWN handler triggered to prepare for key hold.
         *
         * @param $event
         */
        private function _onKeyDown($event:KeyboardEvent):void
        {
            stage.addEventListener(KeyboardEvent.KEY_UP, _onKeyUp, false, 1, true);
            addEventListener(Event.ENTER_FRAME, _onKeyHold, false, 1, true);
        }

        /**
         * @private
         *
         * MouseEvent.MOUSE_UP handler triggered to cancel preparation for drag if the mouse never moves and is released.
         *
         * @param $event
         */
        private function _onKeyUp($event:KeyboardEvent):void
        {
            stage.removeEventListener(KeyboardEvent.KEY_UP, _onKeyUp);
            removeEventListener(Event.ENTER_FRAME, _onKeyHold);
        }

        /**
         * @private
         *
         * Event.ENTER_FRAME handler triggered to set up and dispatch KEY_HOLD event.
         *
         * @param $event
         */
        private function _onKeyHold($event:Event):void
        {
            if (!VSPrioritizedInputBroadcaster.validateInputChannel(_inputChannel) || VSPrioritizedInputBroadcaster.asleep) return;

            dispatchEvent(new VSKeyboardEvent(VSKeyboardEvent.KEY_HOLD, null, false));
        }

        /**
         * @private
         *
         * Event.ENTER_FRAME handler triggered on each frame during the scope of this VSInteractiveObject instance..
         *
         * @param $event
         */
        private function _onEnterFrame($event:Event):void
        {
            if (!VSPrioritizedInputBroadcaster.validateInputChannel(_inputChannel) || VSPrioritizedInputBroadcaster.asleep) return;

            dispatchEvent(new VSEvent(VSEvent.ENTER_FRAME));
        }
    }
}
