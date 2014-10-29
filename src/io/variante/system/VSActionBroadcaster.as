/**
 *  ©2013 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.system
{
    import io.variante.utils.VSAssert;

    /**
     * Static class that handles broadcasting of global actions.
     */
    public class VSActionBroadcaster
    {
        /**
         * @private
         *
         * Object that maps actions to their registered handlers.
         */
        private static var _sActionMap:Object;

        /**
         * Registers a handler with an action.
         *
         * @param $action
         * @param $handler
         * @param $params
         */
        public static function register($action:String, $handler:Function, $params:Array = null):void
        {
            VSAssert.assert(!isActionRegistered($action, $handler), 'Action: ' + $action + ' with handler: ' + $handler + ' is already registered.');

            if (_sActionMap == null)
            {
                _sActionMap = new Object();
            }

            if (_sActionMap[$action] == null)
            {
                _sActionMap[$action] = new Vector.<Object>();
            }

            Vector.<Object>(_sActionMap[$action]).push({ handler: $handler, params: $params });
        }

        /**
         * Deregisters a handler registered with an action, or the entire action.
         *
         * @param $action
         * @param $handler
         */
        public static function deregister($action:String, $handler:Function = null):void
        {
            VSAssert.assert(isActionRegistered($action, $handler), 'Action: ' + $action + ' with handler: ' + $handler + ' is never registered.');

            var idx:uint;

            for (var i:uint = 0; i < Vector.<Object>(_sActionMap[$action]).length; i++)
            {
                if ((Vector.<Object>(_sActionMap[$action])[i]['handler'] as Function) == $handler)
                {
                    idx = i;
                }
            }

            Vector.<Object>(_sActionMap[$action])[idx] = null;
            Vector.<Object>(_sActionMap[$action]).splice(idx, 1);

            if (Vector.<Object>(_sActionMap[$action]).length == 0)
            {
                _sActionMap[$action] = null;
                delete _sActionMap[$action];
            }
        }

        /**
         * Broadcasts the action so its handlers can be called.
         *
         * @param $action
         * @param $params
         */
        public static function broadcast($action:String, $params:Array = null):void
        {
            VSAssert.assert(isActionRegistered($action), 'Action: ' + $action + ' is never registered.');

            for (var i:uint = 0; i < Vector.<Object>(_sActionMap[$action]).length; i++)
            {
                var handler:Function = Vector.<Object>(_sActionMap[$action])[i]['handler'] as Function;
                var params:Array     = $params || (Vector.<Object>(_sActionMap[$action])[i]['params'] as Array);

                handler.apply(null, params);
            }
        }

        /**
         * Checks to see if a handler is registered with an action.
         *
         * @param $action
         * @param $handler
         *
         * @return <code>true</code> if handler is registered, <code>false</code> otherwise.
         */
        public static function isActionRegistered($action:String, $handler:Function = null):Boolean
        {
            if (_sActionMap == null)
            {
                return false;
            }

            if (_sActionMap[$action] == null)
            {
                return false;
            }

            if ($handler == null)
            {
                return true;
            }
            else
            {
                for (var i:uint = 0; i < Vector.<Object>(_sActionMap[$action]).length; i++)
                {
                    if ((Vector.<Object>(_sActionMap[$action])[i]['handler'] as Function) == $handler)
                    {
                        return true;
                    }
                }

                return false;
            }
        }
    }
}
