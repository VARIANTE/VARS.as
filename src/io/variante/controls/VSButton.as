/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.controls
{
    import flash.display.Sprite;
    import io.variante.display.VSInteractiveObject;
    import io.variante.enums.VSDirtyType;
    import io.variante.events.VSEvent;
    import io.variante.events.VSMouseEvent;
    import io.variante.system.VSPrioritizedInputBroadcaster;
    import io.variante.transitions.VSTween;
    import io.variante.utils.VSAssert;

    /**
     * Dispatched when this VSButton is enabled.
     *
     * @eventType io.variante.events.VSEvent.ENABLE
     */
    [Event(name = 'ENABLE', type = 'io.variante.events.VSEvent')]

    /**
     * Dispatched when this VSButton is disabled.
     *
     * @eventType io.variante.events.VSEvent.DISABLE
     */
    [Event(name = 'DISABLE', type = 'io.variante.events.VSEvent')]

    /**
     * Dispatched when this VSButton is highlighted.
     *
     * @eventType io.variante.events.VSEvent.HIGHLIGHT
     */
    [Event(name = 'HIGHLIGHT', type = 'io.variante.events.VSEvent')]

    /**
     * Dispatched when this VSBUtton is unhighlighted.
     *
     * @eventType io.variante.events.VSEvent.UNHIGHLIGHT
     */
    [Event(name = 'UNHIGHLIGHT', type = 'io.variante.events.VSEvent')]

    /**
     * Dispatched when this VSButton is selected.
     *
     * @eventType io.variante.events.VSEvent.SELECT
     */
    [Event(name = 'SELECT', type = 'io.variante.events.VSEvent')]

    /**
     * Dispatched when this VSButton is deselected.
     *
     * @eventType io.variante.events.VSEvent.DESELECT
     */
    [Event(name = 'DESELECT', type = 'io.variante.events.VSEvent')]

    /**
     * Base class for buttons.
     */
    public class VSButton extends VSInteractiveObject
    {
        /**
         * @private
         *
         * Default width and height of the button.
         */
        private static const DEFAULT_WIDTH:Number  = 100;
        private static const DEFAULT_HEIGHT:Number = 30;

        /**
         * @private
         *
         * Default skin colors.
         */
        private static const DEFAULT_IDLE_SKIN_COLOR:uint      = 0x000000;
        private static const DEFAULT_HIGHLIGHT_SKIN_COLOR:uint = 0x333333;
        private static const DEFAULT_PRESSED_SKIN_COLOR:uint   = 0xFFFFFF;
        private static const DEFAULT_SELECTED_SKIN_COLOR:uint  = 0xFFFFFF;

        /**
         * @private
         *
         * Boolean value that indicates whether this VSButton instance has native buttonMode property enabled.
         */
        private var _buttonMode:Boolean;

        /**
         * @private
         *
         * Boolean value that indicates whether this VSButton is enabled.
         */
        private var _enabled:Boolean;

        /**
         * @private
         *
         * Boolean value that indicates whether this VSButton is highlightable.
         */
        private var _highlightable:Boolean;

        /**
         * @private
         *
         * Boolean value that indicates whether this VSButton will auto highlight itself on roll over/out.
         */
        private var _autoHighlight:Boolean;

        /**
         * @private
         *
         * Boolean value that indicates whether this VSButton is highlighted.
         */
        private var _highlighted:Boolean;

        /**
         * @private
         *
         * Boolean value that indicates whether this VSButton has a selected state.
         */
        private var _selectable:Boolean;

        /**
         * @private
         *
         * Boolean value that indicates whether this VSButton will auto select itself on click.
         */
        private var _autoSelect:Boolean;

        /**
         * @private
         *
         * Boolean value that indicates whether this VSButton will auto toggle its selected state on click.
         */
        private var _autoToggle:Boolean;

        /**
         * @private
         *
         * Boolean value that indicates whether this VSButton is pressed.
         */
        private var _pressed:Boolean;

        /**
         * @private
         *
         * Boolean value that indicates whether this VSButton is selected.
         */
        private var _selected:Boolean;

        /**
         * @private
         *
         * Class reference of idle skin.
         */
        private var _idleSkinClass:Class;

        /**
         * @private
         *
         * Class reference of highlighted skin.
         */
        private var _highlightSkinClass:Class;

        /**
         * @private
         *
         * Class reference of pressed skin.
         */
        private var _pressedSkinClass:Class;

        /**
         * @private
         *
         * Class reference of selected skin.
         */
        private var _selectedSkinClass:Class;

        /**
         * @private
         *
         * Idle skin.
         */
        private var _idleSkin:Sprite;

        /**
         * @private
         *
         * Highlight skin.
         */
        private var _highlightSkin:Sprite;

        /**
         * @private
         *
         * Pressed skin.
         */
        private var _pressedSkin:Sprite;

        /**
         * @private
         *
         * Selected skin.
         */
        private var _selectedSkin:Sprite;

        /**
         * @private
         *
         * Color of the default idle skin.
         */
        private var _defaultIdleSkinColor:uint;

        /**
         * @private
         *
         * Color of the default highlight skin.
         */
        private var _defaultHighlightSkinColor:uint;

        /**
         * @private
         *
         * Color of the default pressed skin.
         */
        private var _defaultPressedSkinColor:uint;

        /**
         * @private
         *
         * Color of the default selected skin.
         */
        private var _defaultSelectedSkinColor:uint;

        /**
         * @inheritDoc
         */
        override public function set buttonMode($value:Boolean):void
        {
            _buttonMode = $value;
            super.buttonMode = $value;
        }

        /**
         * @inheritDoc
         */
        override public function set interactive($value:Boolean):void
        {
            if (_buttonMode)
            {
                super.buttonMode = $value;
            }

            super.interactive = $value;
        }

        /**
         * Gets the boolean value that indicates whether this VSButton is enabled.
         */
        public function get enabled():Boolean
        {
            return _enabled;
        }

        /**
         * Sets the boolean value that indicates whether this VSButton is enabled.
         */
        public function set enabled($value:Boolean):void
        {
            if (_enabled == $value) return;

            _enabled = $value;
            mouseEnabled = $value;
            mouseChildren = $value;

            if (initialized)
            {
                if (_enabled)
                {
                    dispatchEvent(new VSEvent(VSEvent.ENABLE, null, true));
                }
                else
                {
                    dispatchEvent(new VSEvent(VSEvent.DISABLE, null, true));
                }
            }

            setDirty(VSDirtyType.STATE);
        }

        /**
         * Gets the boolean value that indicates whether this VSButton is highlightable.
         */
        public function get highlightable():Boolean
        {
            return _highlightable;
        }

        /**
         * Sets the boolean value that indicates whether this VSButton is highlightable.
         */
        public function set highlightable($value:Boolean):void
        {
            _highlightable = $value;
        }

        /**
         * Gets the boolean value that indicates whether this VSButton will auto highlight itself on roll over/out.
         */
        public function get autoHighlight():Boolean
        {
            return _autoHighlight;
        }

        /**
         * Sets the boolean value that indicates whether this VSButton will auto highlight itself on roll over/out.
         */
        public function set autoHighlight($value:Boolean):void { _autoHighlight = $value; }

        /**
         * Gets the boolean value that indicates whether this VSButton is highlighted.
         */
        public function get highlighted():Boolean
        {
            return _highlighted;
        }

        /**
         * Sets the boolean value that indicates whether this VSButton is highlighted.
         */
        public function set highlighted($value:Boolean):void
        {
            if (_highlighted == $value || !_highlightable || _selected) return;

            _highlighted = $value;

            if (initialized)
            {
                if (_highlighted)
                {
                    dispatchEvent(new VSEvent(VSEvent.HIGHLIGHT, null, true));
                }
                else
                {
                    dispatchEvent(new VSEvent(VSEvent.UNHIGHLIGHT, null, true));
                }
            }

            setDirty(VSDirtyType.STATE);
        }

        /**
         * Gets the boolean value that indicates whether this VSButton is pressed.
         */
        public function get pressed():Boolean
        {
            return _pressed;
        }

        /**
         * Sets the boolean value that indicates whether this VSButton is pressed.
         */
        public function set pressed($value:Boolean):void
        {
            if (_pressed == $value || _selected) return;

            _pressed = $value;

            if (initialized)
            {
                if (_pressed)
                {
                    dispatchEvent(new VSMouseEvent(VSMouseEvent.PRESS, null, true));
                }
                else
                {
                    dispatchEvent(new VSMouseEvent(VSMouseEvent.RELEASE, null, true));
                }
            }

            setDirty(VSDirtyType.STATE);
        }

        /**
         * Gets the boolean value that indicates whether this VSButton is selectable.
         */
        public function get selectable():Boolean
        {
            return _selectable;
        }

        /**
         * Sets the boolean value that indicates whether this VSButton is selectable.
         */
        public function set selectable($value:Boolean):void
        {
            _selectable = $value;
        }

        /**
         * Gets the boolean value that indicates whether this VSButton will auto select itself on click.
         */
        public function get autoSelect():Boolean
        {
            return _autoSelect;
        }

        /**
         * Sets the boolean value that indicates whether this VSButton will auto select itself on click.
         */
        public function set autoSelect($value:Boolean):void
        {
            _autoSelect = $value;
        }

        /**
         * Gets the boolean value that indicates whether this VSButton will auto toggle its selected state on click.
         */
        public function get autoToggle():Boolean
        {
            return _autoToggle;
        }

        /**
         * Sets the boolean value that indicates whether this VSButton will auto toggle its selected state on click.
         */
        public function set autoToggle($value:Boolean):void
        {
            _autoToggle = $value;
        }

        /**
         * Gets the boolean value that indicates whether this VSButton is selected.
         */
        public function get selected():Boolean
        {
            return _selected;
        }

        /**
         * Sets the boolean value that indicates whether this VSButton is selected.
         */
        public function set selected($value:Boolean):void
        {
            if (_selected == $value || !_selectable) return;

            if ($value && _highlighted)
            {
                highlighted = false;
            }

            _selected = $value;

            if (initialized)
            {
                if (_selected)
                {
                    if (!_autoToggle)
                    {
                        mouseEnabled = false;
                        mouseChildren = false;
                    }

                    dispatchEvent(new VSEvent(VSEvent.SELECT, null, true));
                }
                else
                {
                    if (!_autoToggle)
                    {
                        mouseEnabled = _enabled;
                        mouseChildren = _enabled;
                    }

                    dispatchEvent(new VSEvent(VSEvent.DESELECT, null, true));

                    // if the mouse is still hovering over the button's hit area, simulate a roll over
                    if (hitArea.hitTestPoint(mouseX, mouseY, true))
                    {
                        dispatchEvent(new VSMouseEvent(VSMouseEvent.ROLL_OVER, null));
                    }
                }
            }

            setDirty(VSDirtyType.STATE);
        }

        /**
         * Gets the idle skin class.
         */
        public function get idleSkin():Class
        {
            return _idleSkinClass;
        }

        /**
         * Sets the idle skin class.
         */
        public function set idleSkin($value:Class):void
        {
            if (_idleSkinClass == $value) return;

            _idleSkinClass = $value;

            setDirty(VSDirtyType.VIEW);
        }

        /**
         * Gets the highlight skin class.
         */
        public function get highlightSkin():Class
        {
            return _highlightSkinClass;
        }

        /**
         * Sets the highlight skin class.
         */
        public function set highlightSkin($value:Class):void
        {
            if (_highlightSkinClass == $value) return;

            _highlightSkinClass = $value;

            setDirty(VSDirtyType.VIEW);
        }

        /**
         * Gets the pressed skin class.
         */
        public function get pressedSkin():Class
        {
            return _pressedSkinClass;
        }

        /**
         * Sets the pressed skin class.
         */
        public function set pressedSkin($value:Class):void
        {
            if (_pressedSkinClass == $value) return;

            _pressedSkinClass = $value;

            setDirty(VSDirtyType.VIEW);
        }

        /**
         * Gets the selected skin class.
         */
        public function get selectedSkin():Class
        {
            return _selectedSkinClass;
        }

        /**
         * Sets the selected skin class.
         */
        public function set selectedSkin($value:Class):void
        {
            if (_selectedSkinClass == $value) return;

            _selectedSkinClass = $value;

            setDirty(VSDirtyType.VIEW);
        }

        /**
         * Gets the color of the default idle skin.
         */
        public function get defaultIdleSkinColor():uint
        {
            return _defaultIdleSkinColor;
        }

        /**
         * Gets the color of the default idle skin.
         */
        public function set defaultIdleSkinColor($value:uint):void
        {
            if (_defaultIdleSkinColor == $value) return;

            _defaultIdleSkinColor = $value;

            setDirty(VSDirtyType.VIEW);
        }

        /**
         * Gets the color of the default highlight skin.
         */
        public function get defaultHighlightSkinColor():uint
        {
            return _defaultHighlightSkinColor;
        }

        /**
         * Sets the color of the default highlight skin.
         */
        public function set defaultHighlightSkinColor($value:uint):void
        {
            if (_defaultHighlightSkinColor == $value) return;

            _defaultHighlightSkinColor = $value;

            setDirty(VSDirtyType.VIEW);
        }

        /**
         * Gets the color of the default pressed skin.
         */
        public function get defaultPressedSkinColor():uint
        {
            return _defaultPressedSkinColor;
        }

        /**
         * Sets the color of the default pressed skin.
         */
        public function set defaultPressedSkinColor($value:uint):void
        {
            if (_defaultPressedSkinColor == $value) return;

            _defaultPressedSkinColor = $value;

            setDirty(VSDirtyType.VIEW);
        }

        /**
         * Gets the color of the default selected skin.
         */
        public function get defaultSelectedSkinColor():uint
        {
            return _defaultSelectedSkinColor;
        }

        /**
         * Sets the color of the default selected skin.
         */
        public function set defaultSelectedSkinColor($value:uint):void
        {
            if (_defaultSelectedSkinColor == $value) return;

            _defaultSelectedSkinColor = $value;

            setDirty(VSDirtyType.VIEW);
        }

        /**
         * Creates a new VSButton instance.
         */
        public function VSButton()
        {
            _enabled       = true;
            _highlightable = true;
            _autoHighlight = true;
            _highlighted   = false;
            _pressed       = false;
            _selectable    = false;
            _autoSelect    = false;
            _autoToggle    = false;
            _selected      = false;

            _idleSkinClass      = VSButtonSkin;
            _highlightSkinClass = VSButtonSkin;
            _pressedSkinClass   = VSButtonSkin;
            _selectedSkinClass  = VSButtonSkin;

            _defaultIdleSkinColor      = DEFAULT_IDLE_SKIN_COLOR;
            _defaultHighlightSkinColor = DEFAULT_HIGHLIGHT_SKIN_COLOR;
            _defaultPressedSkinColor   = DEFAULT_PRESSED_SKIN_COLOR;
            _defaultSelectedSkinColor  = DEFAULT_SELECTED_SKIN_COLOR;

            width      = DEFAULT_WIDTH;
            height     = DEFAULT_HEIGHT;
            hitArea    = this;
            buttonMode = true;
        }

        /**
         * @inheritDoc
         */
        override protected function init():void
        {
            VSAssert.assert(hitArea is VSInteractiveObject, 'The hitArea of a VSButton must be a VSInteractiveObject.');

            VSInteractiveObject(hitArea).addEventListener(VSMouseEvent.ROLL_OVER, onRollOver, false, 0, true);
            VSInteractiveObject(hitArea).addEventListener(VSMouseEvent.ROLL_OUT, onRollOut, false, 0, true);
            VSInteractiveObject(hitArea).addEventListener(VSMouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
            VSInteractiveObject(hitArea).addEventListener(VSMouseEvent.MOUSE_UP_OUTSIDE, onMouseUp, false, 0, true);
            VSInteractiveObject(hitArea).addEventListener(VSMouseEvent.CLICK, onClick, false, 0, true);

            VSPrioritizedInputBroadcaster.addEventListener(VSEvent.CHANGE, _onInputChannelChange, false, 0, true);

            super.init();
        }

        /**
         * @inheritDoc
         */
        override protected function destroy():void
        {
            VSPrioritizedInputBroadcaster.removeEventListener(VSEvent.CHANGE, _onInputChannelChange);

            VSInteractiveObject(hitArea).removeEventListener(VSMouseEvent.ROLL_OVER, onRollOver);
            VSInteractiveObject(hitArea).removeEventListener(VSMouseEvent.ROLL_OUT, onRollOut);
            VSInteractiveObject(hitArea).removeEventListener(VSMouseEvent.MOUSE_DOWN, onMouseDown);
            VSInteractiveObject(hitArea).removeEventListener(VSMouseEvent.MOUSE_UP_OUTSIDE, onMouseUp);
            VSInteractiveObject(hitArea).removeEventListener(VSMouseEvent.CLICK, onClick);

            super.destroy();
        }

        /**
         * @inheritDoc
         */
        override protected function render():void
        {
            if (getDirty(VSDirtyType.VIEW))
            {
                _applySkins();
            }

            if (getDirty(VSDirtyType.DIMENSION) || getDirty(VSDirtyType.VIEW))
            {
                if (_idleSkin != null)
                {
                    _idleSkin.width = width;
                    _idleSkin.height = height;
                }

                if (_highlightSkin != null)
                {
                    _highlightSkin.width = width;
                    _highlightSkin.height = height;
                }

                if (_pressedSkin != null)
                {
                    _pressedSkin.width = width;
                    _pressedSkin.height = height;
                }

                if (_selectedSkin != null)
                {
                    _selectedSkin.width = width;
                    _selectedSkin.height = height;
                }
            }

            if (getDirty(VSDirtyType.STATE))
            {
                if (_highlightSkin != null)
                {
                    if (_highlighted)
                    {
                        VSTween.to(_highlightSkin, 0.4, { alpha: 1 });
                    }
                    else
                    {
                        VSTween.to(_highlightSkin, 0.4, { alpha: 0 });
                    }
                }

                if (_pressedSkin != null)
                {
                    if (_pressed)
                    {
                        VSTween.to(_pressedSkin, 0.4, { alpha: 1 });
                    }
                    else
                    {
                        VSTween.to(_pressedSkin, 0.4, { alpha: 0 });
                    }
                }

                if (_selectedSkin != null)
                {
                    if (_selected)
                    {
                        VSTween.to(_selectedSkin, 0.4, { alpha: 1 });
                    }
                    else
                    {
                        VSTween.to(_selectedSkin, 0.4, { alpha: 0 });
                    }
                }
            }

            super.render();
        }

        /**
         * Applies the skins.
         */
        private function _applySkins():void
        {
            if (_idleSkin != null)
            {
                removeChild(_idleSkin);
                _idleSkin = null;
            }

            if (_idleSkinClass != null)
            {
                if (_idleSkinClass == VSButtonSkin)
                {
                    _idleSkin = new VSButtonSkin(_defaultIdleSkinColor);
                }
                else
                {
                    _idleSkin = new _idleSkinClass();
                }

                addChildAt(_idleSkin, 0);
            }

            if (_highlightSkin != null)
            {
                removeChild(_highlightSkin);
                _highlightSkin = null;
            }

            if (_highlightable && _highlightSkinClass != null)
            {
                if (_highlightSkinClass == VSButtonSkin)
                {
                    _highlightSkin = new VSButtonSkin(_defaultHighlightSkinColor);
                }
                else
                {
                    _highlightSkin = new _highlightSkinClass();
                }

                _highlightSkin.alpha = 0;
                addChildAt(_highlightSkin, 1);
            }

            if (_pressedSkin != null)
            {
                removeChild(_pressedSkin);
                _pressedSkin = null;
            }

            if (_pressedSkinClass != null)
            {
                if (_pressedSkinClass == VSButtonSkin)
                {
                    _pressedSkin = new VSButtonSkin(_defaultPressedSkinColor);
                }
                else
                {
                    _pressedSkin = new _pressedSkinClass();
                }

                _pressedSkin.alpha = 0;
                addChildAt(_pressedSkin, 2);
            }

            if (_selectedSkin != null)
            {
                removeChild(_selectedSkin);
                _selectedSkin = null;
            }

            if (_selectable && _selectedSkinClass != null)
            {
                if (_selectedSkinClass == VSButtonSkin)
                {
                    _selectedSkin = new VSButtonSkin(_defaultSelectedSkinColor);
                }
                else
                {
                    _selectedSkin = new _selectedSkinClass();
                }

                _selectedSkin.alpha = 0;
                addChildAt(_selectedSkin, 3);
            }
        }

        /**
         * io.variante.events.VSMouseEvent.ROLL_OVER handler.
         *
         * @param $event
         */
        protected function onRollOver($event:VSMouseEvent):void
        {
            if (_highlightable && _autoHighlight)
            {
                highlighted = true;
            }
        }

        /**
         * io.variante.events.VSMouseEvent.ROLL_OUT handler.
         *
         * @param $event
         */
        protected function onRollOut($event:VSMouseEvent):void
        {
            if (_highlightable && _autoHighlight)
            {
                highlighted = false;
            }
        }

        /**
         * io.variante.events.VSMouseEvent.MOUSE_DOWN handler.
         *
         * @param $event
         */
        protected function onMouseDown($event:VSMouseEvent):void
        {
            pressed = true;
        }

        /**
         * io.variante.events.VSMouseEvent.MOUSE_UP_OUTSIDE handler.
         *
         * @param $event
         */
        protected function onMouseUp($event:VSMouseEvent):void
        {
            pressed = false;
        }

        /**
         * io.variante.events.VSMouseEvent.CLICK handler.
         *
         * @param $event
         */
        protected function onClick($event:VSMouseEvent):void
        {
            if (_selectable && _autoSelect)
            {
                selected = !_selected || !_autoToggle;
            }
        }

        /**
         * @private
         *
         * Event handler triggered when VSPrioritizedInputBroadcaster's input channel changes.
         *
         * @param $event
         */
        private function _onInputChannelChange($event:VSEvent):void
        {
            if (_buttonMode)
            {
                if (VSPrioritizedInputBroadcaster.validateInputChannel(inputChannel))
                {
                    super.buttonMode = true;
                }
                else
                {
                    super.buttonMode = false;
                }
            }
        }
    }
}

import flash.display.Sprite;

/**
 * Default skin for VSButton.
 */
class VSButtonSkin extends Sprite
{
    public function VSButtonSkin($color:uint)
    {
        graphics.beginFill($color, 1);
        graphics.drawRect(0, 0, 1, 1);
        graphics.endFill();
    }
}
