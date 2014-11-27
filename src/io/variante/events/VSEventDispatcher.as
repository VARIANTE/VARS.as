/**
 *  (c) VARIANTE <http://variante.io>
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.events
{
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import io.variante.debug.VSDebug;

    /**
     * Extended flash.events.EventDispatcher to allow custom event handling.
     */
    public class VSEventDispatcher extends EventDispatcher implements IVSEventDispatcher
    {
        /**
         * @private
         *
         * Table containing all event type/handler pairs.
         */
        private var _eventListenerTable:Object;

        /**
         * Creates a new VSEventDispatcher instance.
         *
         * @param $target
         */
        public function VSEventDispatcher($target:IEventDispatcher = null)
        {
            super($target);
        }

        /**
         * @inheritDoc
         */
        override public function addEventListener($type:String, $listener:Function, $useCapture:Boolean = false, $priority:int = 0, $useWeakReference:Boolean = true):void
        {
            VSDebug.logh(this, 'addEventListener(' + $type + ')');

            // register listner in listener table
            if (_eventListenerTable == null)        { _eventListenerTable = new Object();                   }
            if (_eventListenerTable[$type] == null) { _eventListenerTable[$type] = new Vector.<Function>(); }

            Vector.<Function>(_eventListenerTable[$type]).push($listener);

            super.addEventListener($type, $listener, $useCapture, $priority, $useWeakReference);
        }

        /**
         * @inheritDoc
         */
        override public function removeEventListener($type:String, $listener:Function, $useCapture:Boolean = false):void
        {
            VSDebug.logh(this, 'removeEventListener(' + $type + ')');

            super.removeEventListener($type, $listener, $useCapture);

            if (hasEventHandler($type, $listener))
            {
                var index:int = Vector.<Function>(_eventListenerTable[$type]).indexOf($listener);

                Vector.<Function>(_eventListenerTable[$type]).splice(index, 1);

                if (Vector.<Function>(_eventListenerTable[$type]).length <= 0)
                {
                    _eventListenerTable[$type] = null;
                    delete _eventListenerTable[$type];
                }
            }
        }

        /**
         * @inheritDoc
         */
        public function hasEventHandler($type:String, $listener:Function):Boolean
        {
            if (_eventListenerTable == null || _eventListenerTable[$type] == null)
            {
                return false;
            }

            if (Vector.<Function>(_eventListenerTable[$type]).indexOf($listener) == -1)
            {
                return false;
            }
            else
            {
                return true;
            }
        }
    }
}
