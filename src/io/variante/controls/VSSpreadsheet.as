/**
 *  (c) VARIANTE <http://variante.io>
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.controls
{
    import io.variante.debug.VSDebug;
    import io.variante.display.VSDisplayObject;
    import io.variante.enums.VSDirtyType;
    import io.variante.events.VSEvent;
    import io.variante.utils.VSObjectUtil;

    /**
     * Generic spreadsheet component.
     */
    public class VSSpreadsheet extends VSDisplayObject
    {
        /**
         * @private
         *
         * Default padding of scrollbars.
         */
        private static const SCROLLBAR_PADDING:Number = 4;

        /**
         * @private
         *
         * Data providers.
         */
        private var _dataProviders:Object;

        /**
         * @private
         *
         * Number of rows.
         */
        private var _rows:int;

        /**
         * @private
         *
         * Number of columns.
         */
        private var _cols:int;

        /**
         * @private
         *
         * Size of this VSSpreadsheet instance.
         */
        private var _size:int;

        /**
         * @private
         *
         * Width of each cell.
         */
        private var _cellWidth:Number;

        /**
         * @private
         *
         * Height of each cell.
         */
        private var _cellHeight:Number;

        /**
         * @private
         *
         * Vector of all cells in this VSSpreadsheet instance.
         */
        private var _cells:Vector.<VSSpreadsheetCell>;

        /**
         * @private
         *
         * Vector of each cell data.
         */
        private var _cellDataProviders:Vector.<Vector.<Object>>;

        /**
         * @private
         *
         * Cell class, defaults to io.variante.controls.VSSpreadsheetCell.
         */
        private var _cellClass:Class;

        /**
         * @private
         *
         * Gap of each cell.
         */
        private var _cellGap:Number;

        /**
         * @private
         *
         * Boolean value that indicates whether this VSSpreadsheet instance requires a horizontal scrollbar.
         */
        private var _hasHScrollbar:Boolean;

        /**
         * @private
         *
         * Boolean value that indicates whether this VSSpreadsheet instance requires a vertical scrollbar.
         */
        private var _hasVScrollbar:Boolean;

        /**
         * @private
         *
         * VSScrollView instance to contain all cells.
         */
        private var _scrollView:VSScrollView;

        /**
         * @private
         *
         * Horizontal scrollbar component.
         */
        private var _hScrollbar:VSScrollbar;

        /**
         * @private
         *
         * Vertical scrollbar component.
         */
        private var _vScrollbar:VSScrollbar;

        /**
         * Gets the data providers of this VSSpreadsheet instance.
         */
        public function get dataProviders():Object { return _dataProviders; }

        /**
         * Sets the data providers of this VSSpreadsheet instance.
         */
        public function set dataProviders($value:Object):void
        {
            if (VSObjectUtil.isEqual(_dataProviders, $value)) return;

            _dataProviders     = $value;
            _cellDataProviders = (_dataProviders['data'] == null) ? null : _dataProviders['data'] as Vector.<Vector.<Object>>;

            if (_rows == -1) rows = _cellDataProviders[0].length;
            if (_cols == -1) cols = _cellDataProviders.length;

            if (_dataProviders == null)
            {
                _disposeCells();
            }
            else
            {
                _generateCells();
            }

            setDirty(VSDirtyType.DATA);
            setDirty(VSDirtyType.DIMENSION);
            setDirty(VSDirtyType.VIEW);
        }

        /**
         * Gets the number of rows of this VSSpreadsheet instance.
         */
        public function get rows():int { return (_rows < 0) ? 0 : _rows; }

        /**
         * Sets the number of rows of this VSSpreadsheet instance.
         */
        public function set rows($value:int):void
        {
            if (_rows == $value) return;

            _rows = $value;
            _size = _rows * _cols;

            setDirty(VSDirtyType.DIMENSION);
        }

        /**
         * Gets the number of columns of this VSSpreadsheet instance.
         */
        public function get cols():int { return (_cols < 0) ? 0 : _cols; }

        /**
         * Sets the number of columns of this VSSpreadsheet instance.
         */
        public function set cols($value:int):void
        {
            if (_cols == $value) return;

            _cols = $value;
            _size = _rows * _cols;

            setDirty(VSDirtyType.DIMENSION);
        }

        /**
         * Gets the size of this VSSpreadsheet instance.
         */
        public function get size():int { return (_size < 0) ? 0 : _size; }

        /**
         * Creates a new VSSpreadsheet instance.
         */
        public function VSSpreadsheet()
        {
            _dataProviders = null;
            _rows          = -1;
            _cols          = -1;
            _cellWidth     = NaN;
            _cellHeight    = NaN;
            _size          = -1;
            _cellGap       = 1;
            _cellClass     = null;
            _hasHScrollbar = false;
            _hasVScrollbar = false;
        }

        /**
         * @inheritDoc
         */
        override protected function init():void
        {
            _scrollView = new VSScrollView();
            addChild(_scrollView);

            _hScrollbar = new VSScrollbar(VSScrollbar.HORIZONTAL);
            _hScrollbar.target = _scrollView;
            _hScrollbar.mouseWheelEnabled = false;
            addChild(_hScrollbar);

            _vScrollbar = new VSScrollbar(VSScrollbar.VERTICAL);
            _vScrollbar.target = _scrollView;
            _vScrollbar.mouseWheelEnabled = true;
            _vScrollbar.stageMouseWheelEnabled = true;
            addChild(_vScrollbar);

            _hScrollbar.addEventListener(VSEvent.SCROLL, _onScroll, false, 0, true);
            _hScrollbar.addEventListener(VSEvent.SCROLL_COMPLETE, _onScrollComplete, false, 0, true);
            _vScrollbar.addEventListener(VSEvent.SCROLL, _onScroll, false, 0, true);
            _vScrollbar.addEventListener(VSEvent.SCROLL_COMPLETE, _onScrollComplete, false, 0, true);

            super.init();
        }

        /**
         * @inheritDoc
         */
        override protected function destroy():void
        {
            _hScrollbar.removeEventListener(VSEvent.SCROLL, _onScroll);
            _hScrollbar.removeEventListener(VSEvent.SCROLL_COMPLETE, _onScrollComplete);
            _vScrollbar.removeEventListener(VSEvent.SCROLL, _onScroll);
            _vScrollbar.removeEventListener(VSEvent.SCROLL_COMPLETE, _onScrollComplete);

            _disposeCells();

            super.destroy();
        }

        /**
         * @inheritDoc
         */
        override protected function render():void
        {
            if (getDirty(VSDirtyType.DATA))
            {
                for (var col:uint = 0; col < cols; col++)
                {
                    for (var row:uint = 0; row < rows; row++)
                    {
                        var currIdx:int = _getCellIndex(row, col);
                        var upIdx:int   = _getCellIndex(row - 1, col);
                        var leftIdx:int = _getCellIndex(row, col - 1);

                        _cells[currIdx].x = (leftIdx != -1) ? (_cells[leftIdx].x + _cells[leftIdx].width + _cellGap) : 0;
                        _cells[currIdx].y = (upIdx != -1) ? (_cells[upIdx].y + _cells[upIdx].height + _cellGap) : 0;
                    }
                }
            }

            if (getDirty(VSDirtyType.DIMENSION))
            {
                _scrollView.width += _cellGap * (cols - 1);
                _scrollView.height += _cellGap * (rows - 1);

                if (width > _scrollView.width) width = _scrollView.width + ((_scrollView.height > height) ? (_vScrollbar.width + SCROLLBAR_PADDING*2) : 0);
                if (height > _scrollView.height) height = _scrollView.height + ((_scrollView.width > width) ? (_hScrollbar.height + SCROLLBAR_PADDING*2) : 0);

                _hasHScrollbar = (_scrollView.width > width);
                _hasVScrollbar = (_scrollView.height > height);

                _scrollView.displayWidth = width - ((_hasVScrollbar) ? (_vScrollbar.width + SCROLLBAR_PADDING * 2) : 0);
                _scrollView.displayHeight = height - ((_hasHScrollbar) ? (_hScrollbar.height + SCROLLBAR_PADDING * 2) : 0);

                _hScrollbar.width = width - SCROLLBAR_PADDING * 2 - ((_hasHScrollbar) ? SCROLLBAR_PADDING * 2 : 0);
                _hScrollbar.x = SCROLLBAR_PADDING;
                _hScrollbar.y = height - _hScrollbar.height - SCROLLBAR_PADDING;
                _hScrollbar.alpha = (_hasHScrollbar) ? 1 : 0;
                _hScrollbar.visible = _hasHScrollbar;
                _hScrollbar.autoHide = !_hasHScrollbar;

                _vScrollbar.height = height - SCROLLBAR_PADDING * 2 - ((_hasHScrollbar) ? SCROLLBAR_PADDING * 2 : 0);
                _vScrollbar.x = width - _vScrollbar.width - SCROLLBAR_PADDING;
                _vScrollbar.y = SCROLLBAR_PADDING;
                _vScrollbar.alpha = (_hasVScrollbar) ? 1 : 0;
                _vScrollbar.visible = _hasVScrollbar;
                _vScrollbar.autoHide = !_hasVScrollbar;
            }

            if (getDirty(VSDirtyType.VIEW))
            {
                _drawCells();
            }

            super.render();
        }

        /**
         * @private
         *
         * Generates all the cells of this VSSpreadsheet instance.
         */
        private function _generateCells():void
        {
            if (_cells != null)
            {
                _disposeCells();
            }

            VSDebug.logm(this, '_generateCells(' + size + ')');

            var totalWidth:Number = 0;
            var totalHeight:Number = 0;

            _cells = new Vector.<VSSpreadsheetCell>(size);

            for (var col:uint = 0; col < cols; col++)
            {
                var tmpWidth:Number = 0;
                var tmpHeight:Number = 0;

                for (var row:uint = 0; row < rows; row++)
                {
                    var cell:VSSpreadsheetCell = VSSpreadsheetCell.generateCell((_cellClass) ? _cellClass : VSSpreadsheetGenericCell, _cellDataProviders[col][row]);

                    if (!isNaN(_cellWidth))
                    {
                        cell.width = _cellWidth;
                    }

                    if (!isNaN(_cellHeight))
                    {
                        cell.height = _cellHeight;
                    }

                    if (cell.width > tmpWidth) tmpWidth = cell.width;
                    tmpHeight += cell.height;

                    _cells[_getCellIndex(row, col)] = cell;
                }

                totalWidth += tmpWidth;
                if (tmpHeight > totalHeight) totalHeight = tmpHeight;
            }

            _scrollView.width = totalWidth;
            _scrollView.height = totalHeight;
        }

        /**
         * @private
         *
         * Disposes all the cells of this VSSpreadsheet instance and rids them from the display list.
         */
        private function _disposeCells():void
        {
            if (_cells == null)
            {
                return;
            }

            VSDebug.logm(this, '_disposeCells(' + size + ')');

            for (var i:uint = 0; i < size; i++)
            {
                var cell:VSSpreadsheetCell = _cells[i];

                if (initialized && _scrollView.contains(cell))
                {
                    _scrollView.removeChild(cell);
                }

                _cells[i] = null;
            }

            _cells = null;
        }

        /**
         * @private
         *
         * Draws the cells in the current FOV.
         */
        private function _drawCells():void
        {
            if (_cells == null) return;

            var nRows:int       = Math.floor((_scrollView.displayHeight / _scrollView.height) * rows);
            var rowBuffer:int   = nRows*2;
            var startRowIdx:int = ((Math.floor(_vScrollbar.position * rows) - rowBuffer) < 0) ? 0 : (Math.floor(_vScrollbar.position * rows) - rowBuffer);
            var endRowIdx:int   = ((startRowIdx + nRows + rowBuffer) > rows) ? rows : (startRowIdx + nRows + rowBuffer);
            var nCols:int       = Math.floor((_scrollView.displayWidth / _scrollView.width) * cols);
            var colBuffer:int   = nCols*2;
            var startColIdx:int = ((Math.floor(_hScrollbar.position * cols) - colBuffer) < 0) ? 0 : (Math.floor(_hScrollbar.position * cols) - colBuffer);
            var endColIdx:int   = ((startColIdx + nCols + colBuffer) > cols) ? cols : (startColIdx + nCols + colBuffer);

            VSDebug.logm(this, '_drawCells(startRowIdx = ' + startRowIdx + ', endRowIdx = ' + endRowIdx + ', startColIdx = ' + startColIdx + ', endColIdx = ' + endColIdx + ', hPos = ' + _hScrollbar.position + ', yPos = ' + _vScrollbar.position + ')');

            for (var col:uint = startColIdx; col < endColIdx; col++)
            {
                for (var row:uint = startRowIdx; row < endRowIdx; row++)
                {
                    var i:int = _getCellIndex(row, col);

                    if (!_scrollView.contains(_cells[i]))
                    {
                        _scrollView.addChild(_cells[i]);
                    }
                }
            }
        }

        /**
         * @private
         *
         * Gets the corresponding 1-dimensional cell index based on the specified row and column.
         *
         * @param $row
         * @param $col
         *
         * @return  The corresponding 1-dimensional cell index.
         */
        private function _getCellIndex($row:uint, $col:uint):int
        {
            if ($row < 0 || $row >= rows || $col < 0 || $col >= cols)
            {
                return -1;
            }

            return rows * $col + $row;
        }

        /**
         * @private
         *
         * Handler triggered when either scrollbars are scrolling.
         *
         * @param $event
         */
        private function _onScroll($event:VSEvent):void
        {
            setDirty(VSDirtyType.VIEW);

            _scrollView.mouseEnabled = false;
            _scrollView.mouseChildren = false;
        }

        /**
         * @private
         *
         * Handler triggered when either scrollbars are done scrolling.
         *
         * @param $event
         */
        private function _onScrollComplete($event:VSEvent):void
        {
            setDirty(VSDirtyType.VIEW);

            _scrollView.mouseEnabled = true;
            _scrollView.mouseChildren = true;
        }
    }
}

import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import io.variante.controls.VSSpreadsheetCell;
import io.variante.enums.VSDirtyType;
import io.variante.text.VSTextField;

/**
 * Default cell class for VSSpreadsheet.
 */
class VSSpreadsheetGenericCell extends VSSpreadsheetCell
{
    /**
     * @private
     *
     * VSTextField instance.
     */
    private var _textfield:VSTextField;

    /**
     * Creates a new VSSpreadsheetGenericCell instance.
     */
    public function VSSpreadsheetGenericCell()
    {
        style = new TextFormat('Arial', 12, 0xFFFFFF, null, null, null, null, null, TextFormatAlign.CENTER);
    }

    /**
     * @inheritDoc
     */
    override protected function init():void
    {
        _textfield = new VSTextField();
        addChild(_textfield);

        super.init();
    }

    /**
     * @inheritDoc
     */
    override protected function render():void
    {
        if (getDirty(VSDirtyType.DIMENSION))
        {
            _textfield.width = width;
            _textfield.height = height;
        }

        super.render();
    }

    /**
     * @inheritDoc
     */
    override protected function refreshData():void
    {
        _textfield.text = String(data);

        super.refreshData();
    }

    /**
     * @inheritDoc
     */
    override protected function refreshStyle():void
    {
        _textfield.textFormat = style as TextFormat;

        super.refreshStyle();
    }
}
