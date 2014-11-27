/**
 *  (c) VARIANTE <http://variante.io>
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.utils
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.utils.Dictionary;
    import io.variante.events.VSEvent;
    import io.variante.events.VSEventDispatcher;

    /**
     * Dispatched after the EventQueue is activated, when all queued events are dispatched.
     *
     * @eventType io.variante.events.VSEvent.COMPLETE
     */
    [Event(name = 'COMPLETE', type = 'io.variante.events.VSEvent')]

    /**
     * Utility for listening for multiple events and notifies complete after all queued events are dispatched.
     */
    public class VSEventQueue extends VSEventDispatcher
    {
        /**
         * @private
         *
         * Internal queue.
         */
        private var _queue:Dictionary;

        /**
         * Creates a new EventQueue instance.
         */
        public function VSEventQueue() {}

        /**
         * Adds an EventDispatcher instance and its will-trigger event type to the queue.
         *
         * @param $eventDispatcher
         * @param $eventType
         */
        public function enqueue($eventDispatcher:EventDispatcher, $eventType:String):void
        {
            if (!_queue)
            {
                _queue = new Dictionary(true);
            }

            _queue[$eventDispatcher] = new Vector.<String>();
            (_queue[$eventDispatcher] as Vector.<String>).push($eventType);

            $eventDispatcher.addEventListener($eventType, _onQueuedEventDispatched, false, 0, true);
        }

        /**
         * Removes an EventDispatcher instance and its will-trigger event type from the queue.
         *
         * @param $eventDispatcher
         * @param $eventType
         */
        public function dequeue($eventDispatcher:EventDispatcher, $eventType:String):void
        {
            VSAssert.assert(_queue[$eventDispatcher] && Vector.<String>(_queue[$eventDispatcher]).indexOf($eventType) >= 0, 'Invalid dequeue of ' + $eventDispatcher + ' for event type [' + $eventType + '].');

            var index:int = Vector.<String>(_queue[$eventDispatcher]).indexOf($eventType);

            Vector.<String>(_queue[$eventDispatcher]).splice(index, 1);

            if (Vector.<String>(_queue[$eventDispatcher]).length == 0)
            {
                delete _queue[$eventDispatcher];
            }

            if (VSDictionaryUtil.sizeOf(_queue) == 0)
            {
                _queue = null;
            }
        }

        /**
         * Activates the EventQueue to start listening for events in the queue.
         */
        public function activate():void
        {
            VSAssert.assert(_queue != null, 'Queue is null.');

            for (var key:Object in _queue)
            {
                for (var i:uint = 0; i < Vector.<String>(_queue[key]).length; i++)
                {
                    (key as EventDispatcher).addEventListener(Vector.<String>(_queue[key])[i], _onQueuedEventDispatched, false, 0, true);
                }
            }
        }

        /**
         * Terminates the current EventQueue.
         */
        public function kill():void
        {
            if (!_queue) return;

            for (var key:Object in _queue)
            {
                for (var i:uint = 0; i < Vector.<String>(_queue[key]).length; i++)
                {
                    (key as EventDispatcher).removeEventListener(Vector.<String>(_queue[key])[i], _onQueuedEventDispatched);
                }

                delete _queue[key];
            }

            _queue = null;
        }

        /**
         * @private
         *
         * Event handler for each will-trigger event types of each EventDispatcher in the queue.
         *
         * @param $event
         */
        private function _onQueuedEventDispatched($event:Event):void
        {
            var target:EventDispatcher = $event.currentTarget as EventDispatcher;

            target.removeEventListener($event.type, _onQueuedEventDispatched);

            dequeue(target, $event.type);

            if (!_queue)
            {
                dispatchEvent(new VSEvent(VSEvent.COMPLETE));
            }
        }
    }
}
