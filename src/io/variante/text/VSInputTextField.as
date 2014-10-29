/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.text
{
    import flash.events.Event;
    import flash.events.TextEvent;
    import flash.text.TextFieldType;
    import io.variante.events.VSEvent;
    import io.variante.events.VSTextEvent;

    /**
     * Dispatched by a TextField object after the user scrolls.
     *
     * @eventType io.variante.events.VSEvent.SCROLL
     */
    [Event(name = 'SCROLL', type = 'io.variante.events.VSEvent')]

    /**
     * Dispatched after a control value is modified, unlike
     * the textInput event, which is dispatched before the value is modified.
     *
     * @eventType io.variante.events.VSEvent.CHANGE
     */
    [Event(name = 'CHANGE', type = 'io.variante.events.VSEvent')]

    /**
     * Dispatched when a user clicks a hyperlink in an
     * HTML-enabled text field, where the URL begins with 'event:'.
     *
     * @eventType io.variante.events.VSTextEvent.LINK
     */
    [Event(name = 'LINK', type = 'io.variante.events.VSTextEvent')]

    /**
     * Flash Player dispatches the textInput event when a user enters one or more
     * characters of text.
     *
     * @eventType io.variante.events.VSTextEvent.TEXT_INPUT
     */
    [Event(name = 'TEXT_INPUT', type = 'io.variante.events.VSTextEvent')]

    /**
     * Input TextField base class.
     */
    public class VSInputTextField extends VSTextField
    {
        /**
         * @private
         *
         * Inherited flash.text.TextFieldAutoSize properties.
         */
        public static const AUTOSIZE_NONE:String   = VSTextField.AUTOSIZE_NONE;
        public static const AUTOSIZE_LEFT:String   = VSTextField.AUTOSIZE_LEFT;
        public static const AUTOSIZE_RIGHT:String  = VSTextField.AUTOSIZE_RIGHT;
        public static const AUTOSIZE_CENTER:String = VSTextField.AUTOSIZE_CENTER;

        /**
         * @private
         *
         * Inherited flash.text.AntiAliasType properties.
         */
        public static const ANTIALIAS_TYPE_NORMAL:String   = VSTextField.ANTIALIAS_TYPE_NORMAL;
        public static const ANTIALIAS_TYPE_ADVANCED:String = VSTextField.ANTIALIAS_TYPE_ADVANCED;

        /**
         * Creates a new VSInputTextField instance.
         */
        public function VSInputTextField()
        {
            textField.type = TextFieldType.INPUT;
            selectable = true;
        }

        /**
         * @inheritDoc
         */
        override protected function init():void
        {
            textField.addEventListener(Event.CHANGE, _onTextFieldChange, false, 0, true);
            textField.addEventListener(Event.SCROLL, _onTextFieldScroll, false, 0, true);
            textField.addEventListener(TextEvent.LINK, _onTextFieldLink, false, 0, true);
            textField.addEventListener(TextEvent.TEXT_INPUT, _onTextFieldTextInput, false, 0, true);

            super.init();
        }

        /**
         * @inheritDoc
         */
        override protected function destroy():void
        {
            textField.removeEventListener(Event.CHANGE, _onTextFieldChange);
            textField.removeEventListener(Event.SCROLL, _onTextFieldScroll);
            textField.removeEventListener(TextEvent.LINK, _onTextFieldLink);
            textField.removeEventListener(TextEvent.TEXT_INPUT, _onTextFieldTextInput);

            super.destroy();
        }

        /**
         * @private
         *
         * flash.events.Event.CHANGE handler for TextField.
         *
         * @param  $event
         */
        private function _onTextFieldChange($event:Event):void
        {
            dispatchEvent(new VSEvent(VSEvent.CHANGE, null, $event.bubbles, $event.cancelable));
        }

        /**
         * @private
         *
         * flash.events.Event.SCROLL handler for TextField.
         *
         * @param  $event
         */
        private function _onTextFieldScroll($event:Event):void
        {
            dispatchEvent(new VSEvent(VSEvent.SCROLL, null, $event.bubbles, $event.cancelable));
        }

        /**
         * @private
         *
         * flash.events.TextEvent.LINK handler for TextField.
         *
         * @param  $event
         */
        private function _onTextFieldLink($event:TextEvent):void
        {
            dispatchEvent(new VSTextEvent(VSTextEvent.TEXT_INPUT, null, $event.bubbles, $event.cancelable, $event.text));
        }

        /**
         * @private
         *
         * flash.events.TextEvent.TEXT_INPUT handler for TextField.
         *
         * @param  $event
         */
        private function _onTextFieldTextInput($event:TextEvent):void
        {
            dispatchEvent(new VSTextEvent(VSTextEvent.LINK, null, $event.bubbles, $event.cancelable, $event.text));
        }
    }
}
