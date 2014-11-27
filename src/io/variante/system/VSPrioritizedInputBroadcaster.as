/**
 *  (c) VARIANTE <http://variante.io>
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.system
{
    import flash.events.Event;
    import io.variante.debug.VSDebug;
    import io.variante.display.VSInteractiveObject;
    import io.variante.events.VSEvent;
    import io.variante.events.VSEventDispatcher;
    import io.variante.events.IVSInputEvent;

    /**
     * VSPrioritizedInputBroadcaster is a static class used to moderate the mouse/keyboard interactivity of all VSInteractiveObjects.
     * If the input channel of VSPrioritizedInputBroadcaster is greater than the input channel of the registrant,
     * the registrant will not dispatch any mouse/keyboard interaction events.
     */
    public class VSPrioritizedInputBroadcaster
    {
        /**
         * Default and lowest input channel for all VSInteractiveObjects.
         */
        public static const GLOBAL_LEVEL:uint = 0;

        /**
         * @private
         *
         * Current input channel.
         */
        private static var _inputChannel:uint;

        /**
         * @private
         *
         * Vector of registered VSInteractiveObjects.
         */
        private static var _registrants:Vector.<VSInteractiveObject>;

        /**
         * @private
         *
         * Internal static event dispatcher instance.
         */
        private static var _eventDispatcher:VSEventDispatcher;

        /**
         * @private
         *
         * Internal stack that keeps track of set input channels.
         */
        private static var _channelStack:Vector.<uint>;

        /**
         * @private
         *
         * Boolean flag that indicates whether the VSPrioritizedInputBroadcaster is asleep.
         */
        private static var _asleep:Boolean;

        /**
         * Gets the current input channel of the VSPrioritizedInputBroadcaster.
         */
        public static function get inputChannel():uint { return _inputChannel; }

        /**
         * Sets the current input channel of the VSPrioritizedInputBroadcaster.
         */
        public static function set inputChannel($value:uint):void
        {
            _inputChannel = $value;

            if (!_channelStack)
            {
                _channelStack = new Vector.<uint>();
            }

            _channelStack.push($value);

            dispatchEvent(new VSEvent(VSEvent.CHANGE));
        }

        /**
         * Gets the boolean value that indicates whether the VSPrioritizedInputBroadcaster is asleep.
         */
        public static function get asleep():Boolean
        {
            return _asleep;
        }

        /**
         * Static initializer.
         */
        {
            _inputChannel = GLOBAL_LEVEL;
            _eventDispatcher = new VSEventDispatcher();
        }

        /**
         * Tells the VSPrioritizedInputBroadcaster to sleep and not broadcast any events.
         */
        public static function sleep():void
        {
            _asleep = true;
        }

        /**
         * Tells theVSPrioritizedInputBroadcaster to wake up and resume broadcasting events.
         */
        public static function wake():void
        {
            _asleep = false;
        }

        /**
         * Validates the specified input channel.
         *
         * @param $inputChannel
         *
         * @return <code>true</code> if input channel is valid, <code>false</code> otherwise.
         */
        public static function validateInputChannel($inputChannel:uint):Boolean
        {
            return $inputChannel >= _inputChannel;
        }

        /**
         * Registers the target VSInteractiveObject with the VSPrioritizedInputBroadcaster.
         *
         * @param $target
         *
         * @return <code>true</code> if registration is successful, <code>false</code> otherwise.
         */
        public static function register($target:VSInteractiveObject):Boolean
        {
            VSDebug.logh(VSPrioritizedInputBroadcaster, 'register(' + $target + ')');

            if (_registrants == null)
            {
                _registrants = new Vector.<VSInteractiveObject>();
            }

            if (_registrants.indexOf($target) <= 0)
            {
                _registrants.push($target);

                return true;
            }
            else
            {
                VSDebug.logh(VSPrioritizedInputBroadcaster, 'Target: ' + $target + ' is already registered.');

                return false;
            }
        }

        /**
         * Deregisters the target VSInteractiveObject with the VSPrioritizedInputBroadcaster.
         *
         * @param $target
         *
         * @return <code>true</code> if deregistration is successful, <code>false</code> otherwise.
         */
        public static function deregister($target:VSInteractiveObject):Boolean
        {
            if (_registrants == null) return false;

            VSDebug.logh(VSPrioritizedInputBroadcaster, 'deregister(' + $target + ')');

            var index:int = _registrants.indexOf($target);

            if (index < 0)
            {
                VSDebug.logh(VSPrioritizedInputBroadcaster, 'Target is not a registrant.');

                return false;
            }
            else
            {
                VSDebug.logh(VSPrioritizedInputBroadcaster, 'Deregistering target.');

                _registrants[index].interactive = false;
                _registrants.splice(index, 1);

                if (_registrants.length <= 0)
                {
                    _registrants = null;
                }

                return true;
            }
        }

        /**
         * Broadcasts the target event to all registrants.
         *
         * @param $event
         */
        public static function broadcast($event:IVSInputEvent):void
        {
            if (_registrants == null) return;

            for (var i:uint; i < _registrants.length; i++)
            {
                _registrants[i].dispatchEvent($event as Event);
            }
        }

        /**
         * Pushes the specified input channel into the input channel stack and returns the new length of the stack.
         *
         * @param $value
         *
         * @return New length of the input channel stack.
         */
        public static function push($inputChannel:uint):uint
        {
            inputChannel = $inputChannel;

            return _channelStack.length;
        }

        /**
         * Pops the last input channel in the input channel stack and returns the new length of the stack.
         *
         * @return New length of the input channel stack.
         */
        public static function pop():uint
        {
            _channelStack.pop();

            if (_channelStack.length == 0)
            {
                _channelStack = null;
                _inputChannel = GLOBAL_LEVEL;
            }
            else
            {
                _inputChannel = _channelStack[_channelStack.length - 1];
            }

            return (_channelStack) ? _channelStack.length : 0;
        }

        /**
         * @see flash.events.EventDispatcher#addEventListener()
         */
        public static function addEventListener($type:String, $listener:Function, $useCapture:Boolean = false, $priority:int = 0, $useWeakReference:Boolean = false):void
        {
            _eventDispatcher.addEventListener($type, $listener, $useCapture, $priority, $useWeakReference);
        }

        /**
         * @see flash.events.EventDispatcher#removeEventListener()
         */
        public static function removeEventListener($type:String, $listener:Function, $useCapture:Boolean = false):void
        {
            _eventDispatcher.removeEventListener($type, $listener, $useCapture);
        }

        /**
         * @see flash.events.EventDispatcher#hasEventListener()
         */
        public static function hasEventListener($type:String):Boolean
        {
            return _eventDispatcher.hasEventListener($type);
        }

        /**
         * @see flash.events.EventDispatcher#dispatchEvent()
         */
        public static function dispatchEvent($event:Event):Boolean
        {
            return _eventDispatcher.dispatchEvent($event);
        }
    }
}
