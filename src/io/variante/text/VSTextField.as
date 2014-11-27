/**
 *  (c) VARIANTE <http://variante.io>
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.text
{
    import flash.text.AntiAliasType;
    import flash.text.GridFitType;
    import flash.text.StyleSheet;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;
    import io.variante.display.VSDisplayObject;
    import io.variante.enums.VSDirtyType;

    /**
     * TextField base class.
     */
    public class VSTextField extends VSDisplayObject
    {
        /**
         * @see flash.text.TextFieldAutoSize
         */
        public static const AUTOSIZE_NONE:String = TextFieldAutoSize.NONE;

        /**
         * @see flash.text.TextFieldAutoSize
         */
        public static const AUTOSIZE_LEFT:String = TextFieldAutoSize.LEFT;

        /**
         * @see flash.text.TextFieldAutoSize
         */
        public static const AUTOSIZE_RIGHT:String = TextFieldAutoSize.RIGHT;

        /**
         * @see flash.text.TextFieldAutoSize
         */
        public static const AUTOSIZE_CENTER:String = TextFieldAutoSize.CENTER;

        /**
         * @see flash.text.GridFitType
         */
        public static const GRID_FIT_TYPE_NONE:String = GridFitType.NONE;

        /**
         * @see flash.text.GridFitType
         */
        public static const GRID_FIT_TYPE_PIXEL:String = GridFitType.PIXEL;

        /**
         * @see flash.text.GridFitType
         */
        public static const GRID_FIT_TYPE_SUBPIXEL:String = GridFitType.SUBPIXEL;

        /**
         * @see flash.text.AntiAliasType
         */
        public static const ANTIALIAS_TYPE_NORMAL:String = AntiAliasType.NORMAL;

        /**
         * @see flash.text.AntiAliasType
         */
        public static const ANTIALIAS_TYPE_ADVANCED:String = AntiAliasType.ADVANCED;

        /**
         * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextLineMetrics.html
         */
        private static const TEXT_GUTTER:Number = 2;

        /**
         * @private
         *
         * Private properties.
         */
        private var _width:Number;
        private var _height:Number;
        private var _text:String;
        private var _multiline:Boolean;
        private var _selectable:Boolean;
        private var _wordWrap:Boolean;
        private var _antiAliasType:String;
        private var _gridFitType:String;
        private var _alwaysShowSelection:Boolean;
        private var _autoSize:String;
        private var _textFormat:TextFormat;
        private var _styleSheet:StyleSheet;
        private var _embedFonts:Boolean;

        /**
         * @private
         *
         * TextField instance.
         */
        private var _textField:TextField;

        /**
         * @inheritDoc
         */
        override public function set width($value:Number):void
        {
            if (_width == $value) return;

            _width = $value;
            autoSize = AUTOSIZE_NONE;

            super.width = $value;
        }

        /**
         * @inheritDoc
         */
        override public function set height($value:Number):void
        {
            if (_height == $value) return;

            _height = $value;
            autoSize = AUTOSIZE_NONE;

            super.height = $value;
        }

        /**
         * @copy flash.display.TextField#text
         */
        public function get text():Object
        {
            return _text;
        }

        /**
         * @copy flash.display.TextField#text
         */
        public function set text($value:Object):void
        {
            if ((_text == $value) ||
                ($value is String && $value == null && _text == '') ||
                ($value is Number && isNaN(Number($value)) && _text == ''))
            {
                return;
            }

            if ($value is String)
            {
                switch (String($value))
                {
                    case null:
                        _text = '';
                        break;
                    default:
                        _text = String($value);
                        break;
                }
            }
            else if ($value is Number)
            {
                switch (Number($value))
                {
                    case NaN:
                        _text = '';
                        break;
                    default:
                        _text = Number($value).toString();
                        break;
                }
            }

            setDirty(VSDirtyType.DATA, true);
        }

        /**
         * @copy flash.display.TextField#multiline
         */
        public function get multiline():Boolean
        {
            return _multiline;
        }

        /**
         * @copy flash.display.TextField#multiline
         */
        public function set multiline($value:Boolean):void
        {
            if (_multiline == $value) return;
            _multiline = $value;
            setDirty(VSDirtyType.VIEW, true);
        }

        /**
         * @copy flash.display.TextField#selectable
         */
        public function get selectable():Boolean
        {
            return _selectable;
        }

        /**
         * @copy flash.display.TextField#selectable
         */
        public function set selectable($value:Boolean):void
        {
            if (_selectable == $value) return;
            _selectable = $value;
            mouseEnabled  = $value;
            mouseChildren = $value;
            setDirty(VSDirtyType.CUSTOM);
        }

        /**
         * @copy flash.display.TextField#selectedText
         */
        public function get selectedText():String
        {
            return (_textField) ? _textField.selectedText : '';
        }

        /**
         * @copy flash.display.TextField#selectionBeginIndex
         */
        public function get selectionBeginIndex():int
        {
            return (_textField) ? _textField.selectionBeginIndex : -1;
        }

        /**
         * @copy flash.display.TextField#selectionEndIndex
         */
        public function get selectionEndIndex():int
        {
            return (_textField) ? _textField.selectionEndIndex : -1;
        }

        /**
         * @copy flash.display.TextField#alwaysShowSelection
         */
        public function get alwaysShowSelection():Boolean
        {
            return _alwaysShowSelection;
        }

        /**
         * @copy flash.display.TextField#alwaysShowSelection
         */
        public function set alwaysShowSelection($value:Boolean):void
        {
            if (_alwaysShowSelection == $value) return;
            _alwaysShowSelection = $value;
            setDirty(VSDirtyType.CUSTOM);
        }

        /**
         * @copy flash.display.TextField#wordWrap
         */
        public function get wordWrap():Boolean
        {
            return _wordWrap;
        }

        /**
         * @copy flash.display.TextField#wordWrap
         */
        public function set wordWrap($value:Boolean):void
        {
            if (_wordWrap == $value) return;
            _wordWrap = $value;
            setDirty(VSDirtyType.VIEW, true);
        }

        /**
         * @copy flash.display.TextField#antiAliasType
         */
        public function get antiAliasType():String
        {
            return _antiAliasType;
        }

        /**
         * @copy flash.display.TextField#antiAliasType
         */
        public function set antiAliasType($value:String):void
        {
            if (_antiAliasType == $value) return;
            _antiAliasType = $value;
            setDirty(VSDirtyType.VIEW);
        }

        /**
         * @copy flash.display.TextField#gridFitType
         */
        public function get gridFitType():String
        {
            return _gridFitType;
        }

        /**
         * @copy flash.display.TextField#gridFitType
         */
        public function set gridFitType($value:String):void
        {
            if (_gridFitType == $value) return;
            _gridFitType = $value;
            setDirty(VSDirtyType.VIEW);
        }

        /**
         * @copy flash.display.TextField#autoSize
         */
        public function get autoSize():String
        {
            return _autoSize;
        }

        /**
         * @copy flash.display.TextField#autoSize
         */
        public function set autoSize($value:String):void
        {
            if (_autoSize == $value) return;
            _autoSize = $value;
            setDirty(VSDirtyType.DIMENSION, true);
        }

        /**
         * @copy flash.display.TextField#embedFonts
         */
        public function get embedFonts():Boolean
        {
            return _embedFonts;
        }

        /**
         * @copy flash.display.TextField#embedFonts
         */
        public function set embedFonts($value:Boolean):void
        {
            if (_embedFonts == $value) return;
            _embedFonts = $value;
            setDirty(VSDirtyType.CUSTOM);
        }

        /**
         * @copy flash.display.TextField#textWidth
         */
        public function get textWidth():Number
        {
            return (_textField) ? _textField.textWidth : 0;
        }

        /**
         * @copy flash.display.TextField#textHeight
         */
        public function get textHeight():Number
        {
            return (_textField) ? _textField.textHeight : 0;
        }

        /**
         * @copy flash.display.TextField#length
         */
        public function get length():Number
        {
            return (_textField) ? _textField.length : 0;
        }

        /**
         * @copy flash.display.TextField@exception
         */
        public function get numLines():Number
        {
            return (_textField) ? _textField.numLines : 0;
        }

        /**
         * Gets the TextFormat of the TextField.
         */
        public function get textFormat():TextFormat
        {
            return _textFormat;
        }

        /**
         * Sets the TextFormat of the TextField.
         */
        public function set textFormat($value:TextFormat):void
        {
            if (_textFormat == $value) return;
            _textFormat = $value;
            setDirty(VSDirtyType.VIEW, true);
        }

        /**
         * Gets the StyleSheet of the TextField.
         */
        public function get styleSheet():StyleSheet
        {
            return _styleSheet;
        }

        /**
         * Sets the StyleSheet of the TextField.
         */
        public function set styleSheet($value:StyleSheet):void
        {
            if (_styleSheet == $value) return;
            _styleSheet = $value;
            setDirty(VSDirtyType.VIEW, true);
        }

        /**
         * @copy flash.text.TextFormat#font
         */
        public function get font():String
        {
            return _textFormat.font;
        }

        /**
         * @copy flash.text.TextFormat#font
         */
        public function set font($value:String):void
        {
            if (_textFormat.font == $value) return;
            _textFormat.font = $value;
            setDirty(VSDirtyType.VIEW, true);
        }

        /**
         * @copy flash.text.TextFormat#size
         */
        public function get size():Object
        {
            return _textFormat.size;
        }

        /**
         * @copy flash.text.TextFormat#size
         */
        public function set size($value:Object):void
        {
            if (_textFormat.size == $value) return;
            _textFormat.size = $value;
            setDirty(VSDirtyType.VIEW, true);
        }

        /**
         * @copy flash.text.TextFormat#color
         */
        public function get color():Object
        {
            return _textFormat.color;
        }

        /**
         * @copy flash.text.TextFormat#color
         */
        public function set color($value:Object):void
        {
            if (_textFormat.color == $value) return;
            _textFormat.color = $value;
            setDirty(VSDirtyType.VIEW);
        }

        /**
         * @copy flash.text.TextFormat#bold
         */
        public function get bold():Object
        {
            return _textFormat.bold;
        }

        /**
         * @copy flash.text.TextFormat#bold
         */
        public function set bold($value:Object):void
        {
            if (_textFormat.bold == $value) return;
            _textFormat.bold = $value;
            setDirty(VSDirtyType.VIEW, true);
        }

        /**
         * @copy flash.text.TextFormat#italic
         */
        public function get italic():Object
        {
            return _textFormat.italic;
        }

        /**
         * @copy flash.text.TextFormat#italic
         */
        public function set italic($value:Object):void
        {
            if (_textFormat.italic == $value) return;
            _textFormat.italic = $value;
            setDirty(VSDirtyType.VIEW, true);
        }

        /**
         * @copy flash.text.TextFormat#underline
         */
        public function get underline():Object
        {
            return _textFormat.underline;
        }

        /**
         * @copy flash.text.TextFormat#underline
         */
        public function set underline($value:Object):void
        {
            if (_textFormat.underline == $value) return;
            _textFormat.underline = $value;
            setDirty(VSDirtyType.VIEW);
        }

        /**
         * @copy flash.text.TextFormat#url
         */
        public function get url():String
        {
            return _textFormat.url;
        }

        /**
         * @copy flash.text.TextFormat#url
         */
        public function set url($value:String):void
        {
            if (_textFormat.url == $value) return;
            _textFormat.url = $value;
            setDirty(VSDirtyType.VIEW);
        }

        /**
         * @copy flash.text.TextFormat#target
         */
        public function get target():String
        {
            return _textFormat.target;
        }

        /**
         * @copy flash.text.TextFormat#target
         */
        public function set target($value:String):void
        {
            if (_textFormat.target == $value) return;
            _textFormat.target = $value;
            setDirty(VSDirtyType.DATA);
        }

        /**
         * @copy flash.text.TextFormat#align
         */
        public function get align():String
        {
            return _textFormat.align;
        }

        /**
         * @copy flash.text.TextFormat#align
         */
        public function set align($value:String):void
        {
            if (_textFormat.align == $value) return;
            _textFormat.align = $value;
            setDirty(VSDirtyType.VIEW, true);
        }

        /**
         * @copy flash.text.TextFormat#leftMargin
         */
        public function get leftMargin():Object
        {
            return _textFormat.leftMargin;
        }

        /**
         * @copy flash.text.TextFormat#leftMargin
         */
        public function set leftMargin($value:Object):void
        {
            if (_textFormat.leftMargin == $value) return;
            _textFormat.leftMargin = $value;
            setDirty(VSDirtyType.VIEW, true);
        }

        /**
         * @copy flash.text.TextFormat#rightMargin
         */
        public function get rightMargin():Object
        {
            return _textFormat.rightMargin;
        }

        /**
         * @copy flash.text.TextFormat#rightMargin
         */
        public function set rightMargin($value:Object):void
        {
            if (_textFormat.rightMargin == $value) return;
            _textFormat.rightMargin = $value;
            setDirty(VSDirtyType.VIEW, true);
        }

        /**
         * @copy flash.text.TextFormat#indent
         */
        public function get indent():Object
        {
            return _textFormat.indent;
        }

        /**
         * @copy flash.text.TextFormat#indent
         */
        public function set indent($value:Object):void
        {
            if (_textFormat.indent == $value) return;
            _textFormat.indent = $value;
            setDirty(VSDirtyType.VIEW, true);
        }

        /**
         * @copy flash.text.TextFormat#leading
         */
        public function get leading():Object
        {
            return _textFormat.leading;
        }

        /**
         * @copy flash.text.TextFormat#leading
         */
        public function set leading($value:Object):void
        {
            if (_textFormat.leading == $value) return;
            _textFormat.leading = $value;
            setDirty(VSDirtyType.VIEW, true);
        }

        /**
         * Gets the internal TextField instance.
         */
        protected function get textField():TextField { return _textField; }

        /**
         * Creates a new VSTextField instance.
         */
        public function VSTextField()
        {
            _width               = NaN;
            _height              = NaN;
            _multiline           = false;
            _selectable          = false;
            _wordWrap            = false;
            _alwaysShowSelection = false;
            _text                = '';
            _textFormat          = new TextFormat();
            _antiAliasType       = ANTIALIAS_TYPE_ADVANCED;
            _gridFitType         = GRID_FIT_TYPE_NONE;
            _autoSize            = AUTOSIZE_NONE;
            _embedFonts          = true;

            _textField = new TextField();
            _textField.type = TextFieldType.DYNAMIC;
            _textField.mouseWheelEnabled = false;

            mouseEnabled  = false;
            mouseChildren = false;
        }

        /**
         * @inheritDoc
         */
        override protected function init():void
        {
            addChild(_textField);

            super.init();
        }

        /**
         * @inheritDoc
         */
        override protected function destroy():void
        {
            super.destroy();
        }

        /**
         * @inheritDoc
         */
        override protected function render():void
        {
            if (getDirty(VSDirtyType.CUSTOM))
            {
                _textField.selectable          = _selectable;
                _textField.embedFonts          = _embedFonts;
                _textField.alwaysShowSelection = _alwaysShowSelection;
            }

            if (getDirty(VSDirtyType.VIEW))
            {
                // set default TextFormat before setting the text so it will take effect
                _textField.defaultTextFormat = _textFormat;
                _textField.multiline         = _multiline;
                _textField.wordWrap          = _wordWrap;
                _textField.antiAliasType     = _antiAliasType;
                _textField.gridFitType       = _gridFitType;
                _textField.autoSize          = _autoSize;
            }

            if (getDirty(VSDirtyType.DATA))
            {
                _textField.htmlText = _text;

                if (_autoSize == AUTOSIZE_NONE)
                {
                    if (isNaN(_width))
                    {
                        _textField.width = _textField.textWidth + TEXT_GUTTER * 2;
                    }

                    if (isNaN(_height))
                    {
                        _textField.height = _textField.textHeight + TEXT_GUTTER * 2;
                    }
                }
            }

            if (getDirty(VSDirtyType.DIMENSION))
            {
                if (_autoSize == AUTOSIZE_NONE)
                {
                    if (!isNaN(_width))
                    {
                        _textField.width  = width;
                    }

                    if (!isNaN(_height))
                    {
                        _textField.height = height;
                    }
                }
            }

            super.render();
        }
    }
}
