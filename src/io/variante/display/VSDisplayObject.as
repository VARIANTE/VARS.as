/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.display
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.utils.getQualifiedClassName;
    import io.variante.enums.VSDirtyType;
    import io.variante.events.VSEvent;
    import io.variante.events.IVSEventDispatcher;
    import io.variante.transitions.VSTween;
    import io.variante.utils.VSAssert;
    import io.variante.utils.VSEventQueue;
    import io.variante.utils.VSObjectUtil;

    /**
     * Dispatched when initialization of this instance of VSDisplayObject is complete.
     *
     * @eventType io.variante.events.VSEvent.INIT_COMPLETE
     */
    [Event(name = 'INIT_COMPLETE', type = 'io.variante.events.VSEvent')]

    /**
     * Dispatched at the end of each render.
     *
     * @eventType io.variante.events.VSEvent.RENDER
     */
    [Event(name = 'RENDER', type = 'io.variante.events.VSEvent')]

    /**
     * Dispatched when this VSDisplayObject instance starts transitioning in.
     *
     * @eventType io.variante.events.VSEvent.TRANSITION_IN
     */
    [Event(name = 'TRANSITION_IN', type = 'io.variante.events.VSEvent')]

    /**
     * Dispatched when this VSDisplayObject instance finishes transitioning in.
     *
     * @eventType io.variante.events.VSEvent.TRANSITION_IN_COMPLETE
     */
    [Event(name = 'TRANSITION_IN_COMPLETE', type = 'io.variante.events.VSEvent')]

    /**
     * Dispatched when this VSDisplayObject instance starts transitioning out.
     *
     * @eventType io.variante.events.VSEvent.TRANSITION_OUT
     */
    [Event(name = 'TRANSITION_OUT', type = 'io.variante.events.VSEvent')]

    /**
     * Dispatched when this VSDisplayObject instance finishes transitioning out.
     *
     * @eventType io.variante.events.VSEvent.TRANSITION_OUT_COMPLETE
     */
    [Event(name = 'TRANSITION_OUT_COMPLETE', type = 'io.variante.events.VSEvent')]

    /**
     * Dispatched when this VSDisplayObject instance is added to stage and finishes transitioning in.
     *
     * @eventType io.variante.events.VSEvent.ADDED_TO_STAGE
     */
    [Event(name = 'ADDED_TO_STAGE', type = 'io.variante.events.VSEvent')]

    /**
     * Dispatched when this VSDisplayObject instance is scheduled to be removed from stage right before it starts transitioning out.
     *
     * @eventType io.variante.events.VSEvent.REMOVED_FROM_STAGE
     */
    [Event(name = 'REMOVED_FROM_STAGE', type = 'io.variante.events.VSEvent')]

    /**
     * Abstract class for all DisplayObjects.
     */
    public class VSDisplayObject extends Sprite implements IVSEventDispatcher
    {
        /**
         * Registration point constants.
         */
        public static const REGISTRATION_POINT_TOP_LEFT:String     = 'topLeft';
        public static const REGISTRATION_POINT_TOP:String          = 'top';
        public static const REGISTRATION_POINT_TOP_RIGHT:String    = 'topRight';
        public static const REGISTRATION_POINT_LEFT:String         = 'left';
        public static const REGISTRATION_POINT_MIDDLE:String       = 'middle';
        public static const REGISTRATION_POINT_RIGHT:String        = 'right';
        public static const REGISTRATION_POINT_BOTTOM_LEFT:String  = 'bottomLeft';
        public static const REGISTRATION_POINT_BOTTOM:String       = 'bottom';
        public static const REGISTRATION_POINT_BOTTOM_RIGHT:String = 'bottomRight';

        /**
         * @private
         *
         * Custom x reference.
         */
        private var _x:Number;

        /**
         * @private
         *
         * Custom y reference.
         */
        private var _y:Number;

        /**
         * @private
         *
         * Custom z reference.
         */
        private var _z:Number;

        /**
         * @private
         *
         * Custom width reference.
         */
        private var _width:Number;

        /**
         * @private
         *
         * Custom height reference.
         */
        private var _height:Number;

        /**
         * @private
         *
         * Custom visible boolean reference.
         */
        private var _visible:Boolean;

        /**
         * @private
         *
         * ID of this VSDisplayObject instance.
         */
        private var _id:int;

        /**
         * @private
         *
         * ID of the group that this VSDisplayObject belongs to.
         */
        private var _groupID:int;

        /**
         * @private
         *
         * Custom data.
         */
        private var _data:Object;

        /**
         * @private
         *
         * Boolean value that indicates whether this VSDisplayObject is initialized.
         */
        private var _initialized:Boolean;

        /**
         * @private
         *
         * Initial registration point of this VSDisplayObject instance.
         */
        private var _registrationPoint:String;

        /**
         * @private
         *
         * Object vector storing pending validations.
         */
        private var _validationTable:Vector.<Object>;

        /**
         * @private
         *
         * Object that stores all registered event listener types and handlers for this VSDisplayObject.
         */
        private var _eventListenerTable:Object;

        /**
         * @private
         *
         * Boolean vector storing current dirty flags.
         */
        private var _dirtyTable:Vector.<Boolean>;

        /**
         * @private
         *
         * VSEventQueue instance to execute queued callbacks on initialize.
         */
        private var _initEventQueue:VSEventQueue;

        /**
         * @private
         *
         * VSEventQueue instance to execute queued callbacks on transition in.
         */
        private var _transitionInEventQueue:VSEventQueue;

        /**
         * @private
         *
         * VSEventQueue instance to execute queued callbacks on transition out.
         */
        private var _transitionOutEventQueue:VSEventQueue;

        /**
         * @private
         *
         * Boolean value that indicates whether this VSDisplayObject instance auto transitions itself on initialize complete.
         */
        private var _autoTransition:Boolean;

        /**
         * @private
         *
         * Starting properties for transition in process.
         *
         * @see io.variante.transitions.VSTween
         */
        private var _transitionInStartProperties:Object;

        /**
         * @private
         *
         * Ending properties for transition in process.
         *
         * @see io.variante.transitions.VSTween
         */
        private var _transitionInEndProperties:Object;

        /**
         * @private
         *
         * Duration of the transition in process (in seconds).
         *
         * @see io.variante.transitions.VSTween
         */
        private var _transitionInDuration:Number;

        /**
         * @private
         *
         * Boolean value indicating whether transition in complete callback should be blocked.
         */
        private var _blockTransitionIn:Boolean;

        /**
         * @private
         *
         * Starting properties for transition out process.
         *
         * @see io.variante.transitions.VSTween
         */
        private var _transitionOutStartProperties:Object;

        /**
         * @private
         *
         * Ending properties for transition out process.
         *
         * @see io.variante.transitions.VSTween
         */
        private var _transitionOutEndProperties:Object;

        /**
         * @private
         *
         * Duration of the transition out proces (in seconds).
         *
         * @see io.variante.transitions.VSTween
         */
        private var _transitionOutDuration:Number;

        /**
         * @private
         *
         * Boolean value indicating whether transition out complete callback should be blocked.
         */
        private var _blockTransitionOut:Boolean;

        /**
         * @inheritDoc
         */
        override public function get x():Number
        {
            return (isNaN(_x)) ? super.x : _x;
        }

        /**
         * @inheritDoc
         */
        override public function set x($value:Number):void
        {
            if (_x == $value) return;

            _x = $value;
            super.x = $value;
        }

        /**
         * @inheritDoc
         */
        override public function get y():Number
        {
            return (isNaN(_y)) ? super.y : _y;
        }

        /**
         * @inheritDoc
         */
        override public function set y($value:Number):void
        {
            if (_y == $value) return;

            _y = $value;
            super.y = $value;
        }

        /**
         * @inheritDoc
         */
        override public function get z():Number
        {
            return (isNaN(_z)) ? super.z : _z;
        }

        /**
         * @inheritDoc
         */
        override public function set z($value:Number):void
        {
            if (_z == $value) return;

            _z = $value;
            super.z = $value;
        }

        /**
         * @inheritDoc
         */
        override public function get width():Number
        {
            return (isNaN(_width)) ? super.width : _width;
        }

        /**
         * @inheritDoc
         */
        override public function set width($value:Number):void
        {
            if (_width == $value) return;

            _width = $value;

            setDirty(VSDirtyType.DIMENSION, true);
        }

        /**
         * @inheritDoc
         */
        override public function get height():Number
        {
            return (isNaN(_height)) ? super.height : _height;
        }

        /**
         * @inheritDoc
         */
        override public function set height($value:Number):void
        {
            if (_height == $value) return;

            _height = $value;

            setDirty(VSDirtyType.DIMENSION, true);
        }

        /**
         * @inheritDoc
         */
        override public function get visible():Boolean
        {
            if (initialized)
            {
                return super.visible;
            }
            else
            {
                return _visible;
            }
        }

        /**
         * @inheritDoc
         */
        override public function set visible($value:Boolean):void
        {
            if (initialized)
            {
                super.visible = $value;
            }
            else
            {
                _visible = $value;
            }
        }

        /**
         * Gets the ID of the group this VSDisplayobject instance belongs to.
         */
        public function get groupID():int
        {
            if (parent != null && parent is VSDisplayObject)
            {
                return VSDisplayObject(parent).id;
            }
            else
            {
                return -1;
            }
        }

        /**
         * Gets the ID of this VSDisplayObject instance.
         */
        public function get id():int
        {
            return _id;
        }

        /**
         * Sets the ID of this VSDisplayObject instance.
         */
        public function set id($value:int):void
        {
            if (_id == $value) return;

            _id = $value;

            setDirty(VSDirtyType.DATA);
        }

        /**
         * Gets the custom data.
         */
        public function get data():Object
        {
            return _data;
        }

        /**
         * Sets the custom data.
         */
        public function set data($value:Object):void
        {
            if (VSObjectUtil.isEqual(_data, $value)) return;

            _data = $value;

            setDirty(VSDirtyType.DATA);
        }

        /**
         * @inheritDoc
         */
        override public function set scaleX($value:Number):void
        {
            if (super.scaleX == $value) return;

            super.scaleX = $value;

            setDirty(VSDirtyType.DIMENSION);
        }

        /**
         * @inheritDoc
         */
        override public function set scaleY($value:Number):void
        {
            if (super.scaleY == $value) return;

            super.scaleY = $value;

            setDirty(VSDirtyType.DIMENSION);
        }

        /**
         * @inheritDoc
         */
        override public function set scaleZ($value:Number):void
        {
            if (super.scaleZ == $value) return;

            super.scaleZ = $value;

            setDirty(VSDirtyType.DIMENSION);
        }

        /**
         * Gets the registration point.
         */
        public function get registrationPoint():String
        {
            return _registrationPoint;
        }

        /**
         * Sets the registration point.
         */
        public function set registrationPoint($value:String):void
        {
            VSAssert.assert(!initialized, 'Registration point must be set before this VSDisplayObject instance is initialized.');

            _registrationPoint = $value;
        }

        /**
         * Gets the boolean value that indicates whether this object is initialized.
         */
        public function get initialized():Boolean
        {
            return _initialized;
        }

        /**
         * Gets the boolean value that indicates whether this VSDisplayObject instance auto transitions on init.
         */
        public function get autoTransition():Boolean
        {
            return _autoTransition;
        }

        /**
         * Sets the boolean value that indicates whether this VSDisplayObject instance auto transitions on init.
         */
        public function set autoTransition($value:Boolean):void
        {
            VSAssert.assert(!initialized, 'autoTransition property must be set before this VSDisplayObject instance is initialized.');
            VSAssert.assert((parent == null) || !(parent is VSDisplayObject) || (parent is DisplayObject && VSDisplayObject(parent).initialized), 'Cannot change the autoTransition property of a VSDisplayObject instance whose parent is an uninitialized VSDisplayObject instance.');

            _autoTransition = $value;
        }

        /**
         * Creates a new VSDisplayObject instance.
         */
        public function VSDisplayObject()
        {
            super.visible = false;

            _id                           = -1;
            _data                         = null;
            _visible                      = true;
            _registrationPoint            = REGISTRATION_POINT_TOP_LEFT;
            _autoTransition               = true;
            _blockTransitionIn            = false;
            _blockTransitionOut           = false;
            _transitionInStartProperties  = null;
            _transitionInEndProperties    = null;
            _transitionInDuration         = 0;
            _transitionOutStartProperties = null;
            _transitionOutEndProperties   = null;
            _transitionOutDuration        = 0;
            _initEventQueue               = null;
            _transitionInEventQueue       = null;
            _transitionOutEventQueue      = null;
            _validationTable              = null;
            _eventListenerTable           = null;

            addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
            addEventListener(Event.REMOVED_FROM_STAGE, _onRemovedFromStage);
        }

        /**
         * Initializes the VSDisplayObject instance.
         */
        protected function init():void
        {
            stage.addEventListener(Event.RESIZE, _onStageResize);

            _dirtyTable = new Vector.<Boolean>(VSDirtyType.MAX_TYPES);

            // on init, all dirty types are marked as dirty
            for (var i:uint = 0; i < VSDirtyType.MAX_TYPES; i++)
            {
                _dirtyTable[i] = true;
            }

            for (var childIndex:uint = 0; childIndex < numChildren; childIndex++)
            {
                var child:DisplayObject = getChildAt(childIndex);

                if (child is VSDisplayObject && !VSDisplayObject(child).initialized)
                {
                    if (_initEventQueue == null)
                    {
                        _initEventQueue = new VSEventQueue();
                        _initEventQueue.addEventListener(VSEvent.COMPLETE, _onAllChildrenInitComplete, false, 0, true);
                    }

                    _initEventQueue.enqueue(child, VSEvent.INIT_COMPLETE);
                }
            }

            if (_initEventQueue)
            {
                _initEventQueue.activate();
            }
            else
            {
                initComplete();
            }
        }

        /**
         * Destroys the VSDisplayObject instance.
         */
        protected function destroy():void
        {
            stage.removeEventListener(Event.RESIZE, _onStageResize);

            if (_blockTransitionIn || _blockTransitionOut)
            {
                VSTween.killTweensOf(this);
            }

            if (hasEventHandler(Event.ADDED_TO_STAGE, _onAddedToStage)) { removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStage); }
            if (hasEventHandler(Event.REMOVED_FROM_STAGE, _onRemovedFromStage)) { removeEventListener(Event.REMOVED_FROM_STAGE, _onRemovedFromStage); }
            if (hasEventHandler(Event.ENTER_FRAME, _onValidation)) { removeEventListener(Event.ENTER_FRAME, _onValidation); }

            if (_initEventQueue)
            {
                _initEventQueue.removeEventListener(VSEvent.COMPLETE, _onAllChildrenInitComplete);
                _initEventQueue.kill();
                _initEventQueue = null;
            }

            if (_transitionInEventQueue)
            {
                _transitionInEventQueue.removeEventListener(VSEvent.COMPLETE, _onAllChildrenTransitionInComplete);
                _transitionInEventQueue.kill();
                _transitionInEventQueue = null;
            }

            if (_transitionOutEventQueue)
            {
                _transitionOutEventQueue.removeEventListener(VSEvent.COMPLETE, _onAllChildrenTransitionOutComplete);
                _transitionOutEventQueue.kill();
                _transitionOutEventQueue = null;
            }

            for (var childIndex:uint = 0; childIndex < numChildren; childIndex++)
            {
                var child:DisplayObject = getChildAt(childIndex);

                if (child is VSDisplayObject && VSDisplayObject(child).hasEventHandler(VSEvent.RENDER, _onChildRender))
                {
                    VSDisplayObject(child).removeEventListener(VSEvent.RENDER, _onChildRender);
                }
            }

            _transitionInStartProperties  = null;
            _transitionInEndProperties    = null;
            _transitionOutStartProperties = null;
            _transitionOutEndProperties   = null;
            _initEventQueue               = null;
            _validationTable              = null;
            _eventListenerTable           = null;
            _initialized                  = false;
        }

        /**
         * Completes the initialization process.
         */
        protected function initComplete():void
        {
            render();

            _initialized = true;

            // set registration point now
            if (isNaN(_x) && isNaN(_y))
            {
                switch (_registrationPoint)
                {
                    case REGISTRATION_POINT_TOP:
                        x = -width / 2;
                        y = 0;
                        break;

                    case REGISTRATION_POINT_TOP_RIGHT:
                        x = -width;
                        y = 0;
                        break;

                    case REGISTRATION_POINT_LEFT:
                        x = 0;
                        y = -height / 2;
                        break;

                    case REGISTRATION_POINT_MIDDLE:
                        x = -width / 2;
                        y = -height / 2;
                        break;

                    case REGISTRATION_POINT_RIGHT:
                        x = -width;
                        y = -height / 2;
                        break;

                    case REGISTRATION_POINT_BOTTOM_LEFT:
                        x = 0;
                        y = -height;
                        break;

                    case REGISTRATION_POINT_BOTTOM:
                        x = -width / 2;
                        y = -height;
                        break;

                    case REGISTRATION_POINT_BOTTOM_RIGHT:
                        x = -width;
                        y = -height;
                        break;

                    case REGISTRATION_POINT_TOP_LEFT:
                    default:
                        x = 0;
                        y = 0;
                        break;
                }
            }

            super.visible = _visible;

            if (_transitionInStartProperties)
            {
                VSTween.set(this, _transitionInStartProperties);
            }

            dispatchEvent(new VSEvent(VSEvent.INIT_COMPLETE));

            if (_autoTransition)
            {
                transitionIn();
            }
        }

        /**
         * Begins the transition in process.
         */
        protected function transitionIn():void
        {
            VSAssert.assert(initialized, 'This VSDisplayObject instance ' + toString() + ' must be initialized in order to perform transition in.');

            dispatchEvent(new VSEvent(VSEvent.TRANSITION_IN));

            _blockTransitionIn = true;

            for (var childIndex:uint = 0; childIndex < numChildren; childIndex++)
            {
                var child:DisplayObject = getChildAt(childIndex);

                if (child is VSDisplayObject)
                {
                    if (_transitionInEventQueue == null)
                    {
                        _transitionInEventQueue = new VSEventQueue();
                        _transitionInEventQueue.addEventListener(VSEvent.COMPLETE, _onAllChildrenTransitionInComplete, false, 0, true);
                    }

                    _transitionInEventQueue.enqueue(child, VSEvent.TRANSITION_IN_COMPLETE);

                    VSDisplayObject(child).transitionIn();
                }
            }

            if (_transitionInEventQueue)
            {
                _transitionInEventQueue.activate();
            }

            if (_transitionInStartProperties && _transitionInEndProperties)
            {
                VSTween.fromTo(this, _transitionInDuration, _transitionInStartProperties, _transitionInEndProperties);
            }
            else if (_transitionInStartProperties)
            {
                VSTween.from(this, _transitionInDuration, _transitionInStartProperties);
            }
            else if (_transitionInEndProperties)
            {
                VSTween.to(this, _transitionInDuration, _transitionInEndProperties);
            }
            else
            {
                _invalidateTransitionInComplete();
            }
        }

        /**
         * Completes the transition in process.
         */
        protected function transitionInComplete():void
        {
            dispatchEvent(new VSEvent(VSEvent.TRANSITION_IN_COMPLETE));
            dispatchEvent(new VSEvent(VSEvent.ADDED_TO_STAGE));
        }

        /**
         * Begins the transition out process.
         */
        protected function transitionOut():void
        {
            // if this VSDisplayObject is in the process of transitioning in
            if (_blockTransitionIn)
            {
                VSTween.killTweensOf(this);
            }

            dispatchEvent(new VSEvent(VSEvent.REMOVED_FROM_STAGE));
            dispatchEvent(new VSEvent(VSEvent.TRANSITION_OUT));

            // if this VSDisplayObject instance is not initialized yet, skip transition and proceed directly to transition out complete
            if (!initialized)
            {
                transitionOutComplete();
                return;
            }

            _blockTransitionOut = true;

            for (var childIndex:uint = 0; childIndex < numChildren; childIndex++)
            {
                var child:DisplayObject = getChildAt(childIndex);

                if (child is VSDisplayObject && VSDisplayObject(child).initialized)
                {
                    if (_transitionOutEventQueue == null)
                    {
                        _transitionOutEventQueue = new VSEventQueue();
                        _transitionOutEventQueue.addEventListener(VSEvent.COMPLETE, _onAllChildrenTransitionOutComplete, false, 0, true);
                    }

                    _transitionOutEventQueue.enqueue(child, VSEvent.TRANSITION_OUT_COMPLETE);

                    VSDisplayObject(child).transitionOut();
                }
            }

            if (_transitionOutStartProperties && _transitionOutEndProperties)
            {
                VSTween.fromTo(this, _transitionOutDuration, _transitionOutStartProperties, _transitionOutEndProperties);
            }
            else if (_transitionOutStartProperties)
            {
                VSTween.from(this, _transitionOutDuration, _transitionOutStartProperties);
            }
            else if (_transitionOutEndProperties)
            {
                VSTween.to(this, _transitionOutDuration, _transitionOutEndProperties);
            }
            else
            {
                _invalidateTransitionOutComplete();
            }
        }

        /**
         * Completes the transition out process.
         */
        protected function transitionOutComplete():void
        {
            dispatchEvent(new VSEvent(VSEvent.TRANSITION_OUT_COMPLETE));
        }

        /**
         * (Override) Redraw callback.
         */
        protected function render():void
        {
            if (_initialized)
            {
                for (var i:uint = 0; i < VSDirtyType.MAX_TYPES; i++)
                {
                    if (_dirtyTable[i] == true)
                    {
                        dispatchEvent(new VSEvent(VSEvent.RENDER, i));
                    }
                }
            }
            else
            {
                dispatchEvent(new VSEvent(VSEvent.RENDER, VSDirtyType.MAX_TYPES));
            }

            // reset all dirty property types
            _dirtyTable = new Vector.<Boolean>(VSDirtyType.MAX_TYPES);
        }

        /**
         * Checks to see if a given dirty type is dirty.
         *
         * @param $dirtyType
         *
         * @return <code>true</code> if dirty, <code>false</code> otherwise.
         */
        protected function getDirty($dirtyType:int = -1):Boolean
        {
            if ($dirtyType == -1)
            {
                for (var i:uint = 0; i < VSDirtyType.MAX_TYPES; i++)
                {
                    if (_dirtyTable[i])
                    {
                        return true;
                    }
                }

                return false;
            }
            else
            {
                return _dirtyTable[$dirtyType];
            }
        }

        /**
         * Sets a dirty type as dirty.
         *
         * @param $dirtyType
         */
        protected function setDirty($dirtyType:int, $validateNow:Boolean = false):void
        {
            if (!initialized) return;

            if ($dirtyType == VSDirtyType.MAX_TYPES)
            {
                for (var i:uint = 0; i < _dirtyTable.length; i++)
                {
                    setDirty(i);
                }
            }
            else
            {
                _dirtyTable[$dirtyType] = true;

                if ($validateNow)
                {
                    validateNow();
                }
                else
                {
                    invalidate();
                }
            }
        }

        /**
         * Validates whether instance is initialized and performs the specified callback
         * at the beginning of the next frame. If no callback is passed, instance will redraw
         * by default.
         *
         * @param $callback
         * @param ...$params
         *
         * @return Boolean value indicating validation success/failure.
         */
        public final function invalidate($callback:Function = null, ...$params):Boolean
        {
            if (_initialized)
            {
                var o:Object =
                {
                    callback: ($callback == null) ? render : $callback,
                    params:   ($callback == null) ? null : $params
                };

                if (_validationTable != null)
                {
                    for (var i:uint = 0; i < _validationTable.length; i++)
                    {
                        if (_validationTable[i]['callback'] == o['callback'] && _validationTable[i]['params'] == o['params'])
                        {
                            return false;
                        }
                    }
                }

                if (_validationTable == null)
                {
                    _validationTable = new Vector.<Object>;
                    addEventListener(Event.ENTER_FRAME, _onValidation, false, 0, true);
                }

                _validationTable.push(o);

                return true;
            }
            else
            {
                return false;
            }
        }

        /**
         * Validates whether instance is initialized and performs the specified callback.
         * If no callback is passed, instance will redraw by default. If validation fails,
         * nothing happens. The callback will be triggered in the same frame validateNow()
         * is called.
         *
         * @param $callback
         * @param ...$params
         *
         * @return Boolean value indicating validation success/failure.
         */
        public final function validateNow($callback:Function = null, ...$params):Boolean
        {
            if (_initialized)
            {
                if ($callback == null)
                {
                    render();
                }
                else
                {
                    $callback.apply(null, $params);
                }

                return true;
            }
            else
            {
                return false;
            }
        }

        /**
         * @inheritDoc
         *
         * Ensure that everytime a child is added to this VSDisplayObject, a VSEvent.RENDER
         * listener is added to the child.
         */
        override public function addChild($child:DisplayObject):DisplayObject
        {
            if ($child is VSDisplayObject)
            {
                VSDisplayObject($child).addEventListener(VSEvent.RENDER, _onChildRender, false, 0, true);

                if (!initialized)
                {
                    VSDisplayObject($child).autoTransition = false;
                }
            }

            return super.addChild($child);

        }

        /**
         * @inheritDoc
         *
         * Ensure that everytime a child is added to this VSDisplayObject, a VSEvent.RENDER
         * listener is added to the child.
         */
        override public function addChildAt($child:DisplayObject, $index:int):DisplayObject
        {
            if ($child is VSDisplayObject)
            {
                VSDisplayObject($child).addEventListener(VSEvent.RENDER, _onChildRender, false, 0, true);

                if (!initialized)
                {
                    VSDisplayObject($child).autoTransition = false;
                }
            }

            return super.addChildAt($child, $index);
        }

        /**
         * @inheritDoc
         *
         * Ensure that everytime a child is removed from this VSDisplayObject, the VSEvent.RENDER
         * listener is removed from the child.
         */
        override public function removeChild($child:DisplayObject):DisplayObject
        {
            if ($child is VSDisplayObject)
            {
                VSDisplayObject($child).removeEventListener(VSEvent.RENDER, _onChildRender);
                VSDisplayObject($child).addEventListener(VSEvent.TRANSITION_OUT_COMPLETE, _onChildTransitionOutComplete, false, 0, true);
                VSDisplayObject($child).transitionOut();

                return $child;
            }
            else
            {
                return super.removeChild($child);
            }
        }

        /**
         * @inheritDoc
         *
         * Ensure that everytime a child is removed from this VSDisplayObject, the VSEvent.RENDER
         * listener is removed from the child.
         */
        override public function removeChildAt($index:int):DisplayObject
        {
            var child:DisplayObject = getChildAt($index);

            if (child != null && child is VSDisplayObject)
            {
                VSDisplayObject(child).removeEventListener(VSEvent.RENDER, _onChildRender);
                VSDisplayObject(child).addEventListener(VSEvent.TRANSITION_OUT_COMPLETE, _onChildTransitionOutComplete, false, 0, true);
                VSDisplayObject(child).transitionOut();

                return child;
            }
            else
            {
                return super.removeChildAt($index);
            }
        }

        /**
         * @inheritDoc
         */
        override public function addEventListener($type:String, $listener:Function, $useCapture:Boolean = false, $priority:int = 0, $useWeakReference:Boolean = true):void
        {
            // register listner in listener table
            if (_eventListenerTable == null)        { _eventListenerTable = new Object(); }
            if (_eventListenerTable[$type] == null) { _eventListenerTable[$type] = new Vector.<Function>(); }

            Vector.<Function>(_eventListenerTable[$type]).push($listener);

            super.addEventListener($type, $listener, $useCapture, $priority, $useWeakReference);
        }

        /**
         * @inheritDoc
         */
        override public function removeEventListener($type:String, $listener:Function, $useCapture:Boolean = false):void
        {
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
         * Checks to see if this VSDisplayObject instance contains a listener of a certain
         * event type and event handler.
         *
         * @param $type
         * @param $listener
         *
         * @return <code>true</code> if listener exists, <code>false</code> otherwise.
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

        /**
         * Sets the transition in properties (either starting properties or ending properties are optional).
         *
         * @param $startProperties
         * @param $endProperties
         * @param $duration
         * @param $delay
         */
        public function setTransitionInProperties($startProperties:Object = null, $endProperties:Object = null, $duration:Number = 0, $delay:Number = 0):void
        {
            VSAssert.assert(!initialized, 'Transition in properties must be set before this VSDisplayObject instance is initialized.');
            VSAssert.assert($startProperties || $endProperties, 'Either starting or ending properties must not null.');

            _transitionInStartProperties = $startProperties;
            _transitionInEndProperties = $endProperties;
            _transitionInDuration = $duration;

            if (_transitionInEndProperties)
            {
                _transitionInEndProperties['onComplete'] = _invalidateTransitionInComplete;
                _transitionInEndProperties['delay'] = $delay;
            }
            else
            {
                _transitionInStartProperties['onComplete'] = _invalidateTransitionInComplete;
                _transitionInStartProperties['delay'] = $delay;
            }
        }

        /**
         * Sets the transition out properties (either starting properties or ending properties are optional).
         *
         * @param $startProperties
         * @param $endProperties
         * @param $duration
         * @param $delay
         */
        public function setTransitionOutProperties($startProperties:Object = null, $endProperties:Object = null, $duration:Number = 0, $delay:Number = 0):void
        {
            VSAssert.assert($startProperties || $endProperties, 'Either starting or ending properties must not null.');

            _transitionOutStartProperties = $startProperties;
            _transitionOutEndProperties = $endProperties;
            _transitionOutDuration = $duration;

            if (_transitionOutEndProperties)
            {
                _transitionOutEndProperties['onComplete'] = _invalidateTransitionOutComplete;
                _transitionOutEndProperties['delay'] = $delay;
            }
            else
            {
                _transitionOutStartProperties['onComplete'] = _invalidateTransitionOutComplete;
                _transitionOutStartProperties['delay'] = $delay;
            }
        }

        /**
         * @private
         *
         * Invalidates transition in complete callback when this VSDisplayObject instance completes its transition in process.
         * Checks to see if this instance is still waiting for any child VSDisplayObject instances to finish transitioning in.
         */
        private function _invalidateTransitionInComplete():void
        {
            _blockTransitionIn = false;

            if (_transitionInEventQueue == null)
            {
                transitionInComplete();
            }
        }

        /**
         * @private
         *
         * Invalidates transition out complete callback when this VSDisplayObject instance completes its transition out process.
         * Checks to see if this instance is still waiting for any child VSDisplayObject instances to finish transitioning out.
         */
        private function _invalidateTransitionOutComplete():void
        {
            _blockTransitionOut = false;

            if (_transitionOutEventQueue == null)
            {
                transitionOutComplete();
            }
        }

        /**
         * @private
         *
         * Event.ADDED_TO_STAGE handler triggered when VSDisplayObject instance
         * is added to the stage.
         *
         * @param $event
         */
        private function _onAddedToStage($event:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);

            init();
        }

        /**
         * @private
         *
         * Event.REMOVED_FROM_STAGE handler triggered when VSDisplayObject instance
         * is removed from the stage.
         *
         * @param $event
         */
        private function _onRemovedFromStage($event:Event):void
        {
            removeEventListener(Event.REMOVED_FROM_STAGE, _onRemovedFromStage);

            destroy();
        }

        /**
         * @private
         *
         * VSEvent.COMPLETE handler triggered when all children has finished initializing.
         *
         * @param $event
         */
        private function _onAllChildrenInitComplete($event:VSEvent):void
        {
            _initEventQueue.removeEventListener(VSEvent.COMPLETE, _onAllChildrenInitComplete);
            _initEventQueue.kill();
            _initEventQueue = null;

            initComplete();
        }

        /**
         * @private
         *
         * VSEvent.COMPLETE handler triggered when all children has finished transitioning in.
         *
         * @param $event
         */
        private function _onAllChildrenTransitionInComplete($event:VSEvent):void
        {
            _transitionInEventQueue.removeEventListener(VSEvent.COMPLETE, _onAllChildrenTransitionInComplete);
            _transitionInEventQueue.kill();
            _transitionInEventQueue = null;

            if (!_blockTransitionIn)
            {
                _invalidateTransitionInComplete();
            }
        }

        /**
         * @private
         *
         * VSEvent.COMPLETE handler triggered when all children has finished transitioning out.
         *
         * @param $event
         */
        private function _onAllChildrenTransitionOutComplete($event:VSEvent):void
        {
            _transitionOutEventQueue.removeEventListener(VSEvent.COMPLETE, _onAllChildrenTransitionOutComplete);
            _transitionOutEventQueue.kill();
            _transitionOutEventQueue = null;

            if (!_blockTransitionOut)
            {
                _invalidateTransitionOutComplete();
            }
        }

        /**
         * @private
         *
         * Event.ENTER_FRAME hander triggered when new callbacks are added to the validation pipeline.
         *
         * @param $event
         */
        private function _onValidation($event:Event):void
        {
            if (_validationTable != null)
            {
                while (_validationTable.length > 0)
                {
                    var callback:Function = _validationTable[0]['callback'] as Function;
                    var params:Array      = _validationTable[0]['params'] as Array;

                    callback.apply(null, params);

                    _validationTable.shift();
                }

                _validationTable = null;

                removeEventListener(Event.ENTER_FRAME, _onValidation);
            }
        }

        /**
         * @private
         *
         * VSEvent.RENDER handler triggered when child VSDisplayObjects are rendered.
         *
         * @param $event
         */
        private function _onChildRender($event:VSEvent):void
        {
            var childDirtyType:uint = uint($event.data);

            if (childDirtyType != VSDirtyType.MAX_TYPES)
            {
                setDirty(VSDirtyType.CHILDREN);
            }
        }

        /**
         * @private
         *
         * VSEvent.TRANSITION_OUT_COMPLETE handler triggered when child VSDisplayObject is done transitioning out.
         *
         * @param $event
         */
        private function _onChildTransitionOutComplete($event:VSEvent):void
        {
            var child:VSDisplayObject = VSDisplayObject($event.target);

            child.removeEventListener(VSEvent.TRANSITION_OUT_COMPLETE, _onChildTransitionOutComplete);

            super.removeChild(child);
        }

        /**
         * @private
         *
         * Event.RESIZE handler triggered when the stage resizes.
         *
         * @param $event
         */
        private function _onStageResize($event:Event):void
        {
            setDirty(VSDirtyType.STAGE);

            dispatchEvent(new VSEvent(VSEvent.RESIZE));
        }

        /**
         * @inheritDoc
         */
        override public function toString():String
        {
            return '{[' + getQualifiedClassName(this) + ']: ' + name + '}';
        }
    }
}
