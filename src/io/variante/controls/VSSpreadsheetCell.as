/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.controls
{
    import flash.events.Event;
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;
    import io.variante.enums.VSDirtyType;
    import io.variante.events.VSEvent;
    import io.variante.utils.VSObjectUtil;

    /**
     * Abstract spreadsheet cell class used for VSSpreadsheets.
     */
    public class VSSpreadsheetCell extends VSButton
    {
        /**
         * @private
         *
         * Data providers.
         */
        private var _dataProviders:Object;

        /**
         * @private
         *
         * Style struct.
         */
        private var _style:Object;
        
        /**
         * Generates a new VSSpreadsheetCell instance using the specified data providers and default cell class.
         *
         * @param $defaultCellClass
         * @param $dataProviders
         *
         * @return Generated VSSpreadsheetCell instance.
         */
        public static function generateCell($defaultCellClass:Class, $dataProviders:Object):VSSpreadsheetCell
        {
            var cellClass:Class = ($dataProviders['class']) ? $dataProviders['class'] as Class : $defaultCellClass;
            var cell:VSSpreadsheetCell = new cellClass();
            
            cell.dataProviders = $dataProviders;
            
            return cell;
        }
        
        /**
         * Clones a VSSpreadsheetCell instance.
         *
         * @param $cell
         * 
         * @return A new VSSpreadsheetCell instance that is a clone of the specified cell.
         */
        public static function cloneCell($cell:VSSpreadsheetCell):VSSpreadsheetCell
        {
            var cellClass:Class = getDefinitionByName(getQualifiedClassName($cell)) as Class;
            var cell:VSSpreadsheetCell = new cellClass();

            cell.dataProviders = $cell.dataProviders;
            cell.data = $cell.data;
            cell.style = $cell.style;

            return cell;
        }

        /**
         * Gets the data providers of this VSSpreadsheetCell instance.
         */
        public function get dataProviders():Object { return _dataProviders; }

        /**
         * Sets the data providers of this VSSpreadsheetCell instance.
         */
        public function set dataProviders($value:Object):void
        {
            if (VSObjectUtil.isEqual(_dataProviders, $value)) return;

            _dataProviders = $value;

            if (_dataProviders['data'] != null) data  = _dataProviders['data'];
            if (_dataProviders['style'] != null) style = _dataProviders['style'];
        }

        /**
         * Gets the style struct of this cell.
         */
        public function get style():Object { return _style; }

        /**
         * Sets the style struct of this cell.
         */
        public function set style($value:Object):void
        {
            _style = $value;

            setDirty(VSDirtyType.VIEW);
        }

        /**
         * Creates a new VSSpreadsheetCell instance.
         */
        public function VSSpreadsheetCell()
        {
            enabled = true;
        }

        /**
         * @inheritDoc
         */
        override protected function render():void
        {
            if (getDirty(VSDirtyType.VIEW))
            {
                refreshStyle();
            }

            if (getDirty(VSDirtyType.DATA))
            {
                refreshData();
            }

            super.render();
        }

        /**
         * Refreshes the current style.
         */
        protected function refreshStyle():void
        {
            dispatchEvent(new VSEvent(Event.RENDER));
        }

        /**
         * Refreshes the current data.
         */
        protected function refreshData():void
        {
            dispatchEvent(new VSEvent(Event.CHANGE));
        }
    }
}
