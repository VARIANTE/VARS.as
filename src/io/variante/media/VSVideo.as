/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.media
{
    import flash.events.NetStatusEvent;
    import flash.media.SoundTransform;
    import flash.media.Video;
    import flash.net.NetConnection;
    import flash.net.NetStream;
    import io.variante.display.VSInteractiveObject;
    import io.variante.enums.VSDirtyType;
    import io.variante.events.VSMediaEvent;

    /**
     * Dispatched when movie plays.
     *
     * @eventType io.variante.events.VSMediaEvent.PLAY
     */
    [Event(name = 'PLAY', type = 'io.variante.events.VSMediaEvent')]

    /**
     * Dispatched when movie pauses.
     *
     * @eventType io.variante.events.VSMediaEvent.PAUSE
     */
    [Event(name = 'PAUSE', type = 'io.variante.events.VSMediaEvent')]

    /**
     * Dispatched when movie stops.
     *
     * @eventType io.variante.events.VSMediaEvent.STOP
     */
    [Event(name = 'STOP', type = 'io.variante.events.VSMediaEvent')]

    /**
     * Dispatched when seeking movie.
     *
     * @eventType io.variante.events.VSMediaEvent.SEEK
     */
    [Event(name = 'SEEK', type = 'io.variante.events.VSMediaEvent')]

    /**
     * Dispatched when movie finishes playing.
     *
     * @eventType io.variante.events.VSMediaEvent.PLAY_COMPLETE
     */
    [Event(name = 'PLAY_COMPLETE', type = 'io.variante.events.VSMediaEvent')]

    /**
     * Dispatched when movie repeats.
     *
     * @eventType io.variante.events.VSMediaEvent.REPEAT
     */
    [Event(name = 'REPEAT', type = 'io.variante.events.VSMediaEvent')]

    /**
     * Dispatched when movie volume increases.
     *
     * @eventType io.variante.events.VSMediaEvent.VOLUME_INCREASE
     */
    [Event(name = 'VOLUME_INCREASE', type = 'io.variante.events.VSMediaEvent')]

    /**
     * Dispatched when movie volume decreases.
     *
     * @eventType io.variante.events.VSMediaEvent.VOLUME_DECREASE
     */
    [Event(name = 'VOLUME_DECREASE', type = 'io.variante.events.VSMediaEvent')]

    /**
     * Dispatched when movie mutes.
     *
     * @eventType io.variante.events.VSMediaEvent.MUTE
     */
    [Event(name = 'MUTE', type = 'io.variante.events.VSMediaEvent')]

    /**
     * Dispatched when movie unmutes.
     *
     * @eventType io.variante.events.VSMediaEvent.UNMUTE
     */
    [Event(name = 'UNMUTE', type = 'io.variante.events.VSMediaEvent')]

    /**
     * Generic video component.
     */
    public class VSVideo extends VSInteractiveObject implements IVSMedia
    {
        /**
         * State when this VSVideo instance is in an idling (either before it starts playing or after it is done playing.
         */
        public static const STATE_IDLE:uint = 0;

        /**
         * State when this VSVideo instance is playing.
         */
        public static const STATE_PLAY:uint = 1;

        /**
         * State when this VSVideo instance is paused.
         */
        public static const STATE_PAUSE:uint = 2;

        /**
         * State when this VSVideo instance is stopped.
         */
        public static const STATE_STOP:uint = 3;

        /**
         * @private
         *
         * NetConnection instance.
         */
        private var _netConnection:NetConnection;

        /**
         * @private
         *
         * NetStream instance.
         */
        private var _netStream:NetStream;

        /**
         * @private
         *
         * Video instance.
         */
        private var _video:Video;

        /**
         * @private
         *
         * Meta object of the video.
         */
        private var _metaObject:Object;

        /**
         * @private
         *
         * Source path of the video.
         */
        private var _source:String;

        /**
         * @private
         *
         * Current width of the video.
         */
        private var _width:Number;

        /**
         * @private
         *
         * Set width of the video.
         */
        private var _setWidth:Number;

        /**
         * @private
         *
         * Current height of the video.
         */
        private var _height:Number;

        /**
         * @private
         *
         * Set height of the video.
         */
        private var _setHeight:Number;

        /**
         * @private
         *
         * Boolean value that indicates whether this VSVideo instance plays itself after the specified sound is done loading.
         */
        private var _autoPlay:Boolean;

        /**
         * @private
         *
         * Boolean value indicating whether the video loops itself on play complete.
         */
        private var _autoLoop:Boolean;

        /**
         * @private
         *
         * Boolean value indicating whether the sound is mute.
         */
        private var _mute:Boolean;

        /**
         * @private
         *
         * Current volume of the sound (0-1).
         */
        private var _volume:Number;

        /**
         * @private
         *
         * Duration of the video.
         */
        private var _duration:Number;

        /**
         * @private
         *
         * @see flash.net.NetStream#inBufferSeek
         */
        private var _inBufferSeek:Boolean;

        /**
         * @private
         *
         * Current state of this VSVideo instance.
         */
        private var _state:uint;

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
            _width = $value;
            _setWidth = $value;

            setDirty(VSDirtyType.DIMENSION);
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
            _height = $value;
            _setHeight = $value;

            setDirty(VSDirtyType.DIMENSION);
        }

        /**
         * Gets the current state of this VSVideo instance.
         */
        public function get state():uint
        {
            return _state;
        }

        /**
         * @inheritDoc
         */
        public function get source():String
        {
            return _source;
        }

        /**
         * @inheritDoc
         */
        public function set source($value:String):void
        {
            if (_source == $value) return;

            _source = $value;

            if (initialized)
            {
                _netStream.play(_source);
                _state = STATE_PLAY;
                dispatchEvent(new VSMediaEvent(VSMediaEvent.PLAY));

                setDirty(VSDirtyType.DATA);
            }
        }

        /**
         * Gets the duration of the video.
         */
        public function get duration():Number { return _duration; }

        /**
         * Gets the current time of the video.
         */
        public function get time():Number { return (_netStream) ? _netStream.time : 0; }

        /**
         * Gets the boolean value that indicates whether the video plays automatically on load complete.
         */
        public function get autoPlay():Boolean
        {
            return _autoPlay;
        }

        /**
         * Sets the boolean value that indicates whether the video plays automatically on load complete.
         */
        public function set autoPlay($value:Boolean):void
        {
            if (_autoPlay == $value) return;

            _autoPlay = $value;
        }

        /**
         * Gets the boolean value that indicates whether the video loops automatically.
         */
        public function get autoLoop():Boolean
        {
            return _autoLoop;
        }

        /**
         * Sets the boolean value that indicates whether the video loops automatically.
         */
        public function set autoLoop($value:Boolean):void
        {
            if (_autoLoop == $value) return;

            _autoLoop = $value;
        }

        /**
         * @see flash.net.NetStream#inBufferSeek
         */
        public function get inBufferSeek():Boolean
        {
            return _inBufferSeek;
        }

        /**
         * @see flash.net.NetStream#inBufferSeek
         */
        public function set inBufferSeek($value:Boolean):void
        {
            _inBufferSeek = $value;

            if (_netStream)
            {
                _netStream.inBufferSeek = $value;
            }
        }

        /**
         * Gets the current mute status of the sound.
         */
        public function get mute():Boolean { return _mute; }

        /**
         * Sets the boolean value that indicates whether the sound is mute.
         */
        public function set mute($value:Boolean):void
        {
            _mute = $value;

            if (_netStream)
            {
                var soundTransform:SoundTransform = new SoundTransform();
                soundTransform.volume = (_mute) ? 0 : _volume;

                _netStream.soundTransform = soundTransform;

                if (_mute)
                {
                    dispatchEvent(new VSMediaEvent(VSMediaEvent.MUTE));
                }
                else
                {
                    dispatchEvent(new VSMediaEvent(VSMediaEvent.UNMUTE));
                }
            }
        }

        /**
         * Gets the volume of the sound.
         */
        public function get volume():Number { return _volume; }

        /**
         * Sets the volume of the sound (0-1).
         */
        public function set volume($value:Number):void
        {
            var isIncreased:Boolean = ($value > _volume);
            var isDecreased:Boolean = ($value < _volume);

            _volume = $value;

            if (_netStream && !_mute)
            {
                var soundTransform:SoundTransform = new SoundTransform();
                soundTransform.volume = _volume;

                _netStream.soundTransform = soundTransform;

                if (isIncreased)
                {
                    dispatchEvent(new VSMediaEvent(VSMediaEvent.VOLUME_INCREASE));
                }
                else if (isDecreased)
                {
                    dispatchEvent(new VSMediaEvent(VSMediaEvent.VOLUME_DECREASE));
                }
            }
        }

        /**
         * Creates a new VSVideo instance.
         */
        public function VSVideo($source:String = null)
        {
            _autoPlay     = true;
            _autoLoop     = false;
            _volume       = 0.5;
            _mute         = false;
            _duration     = 0;
            _inBufferSeek = true;
            _state        = STATE_IDLE;

            source = $source;
        }

        /**
         * @inheritDoc
         */
        override protected function init():void
        {
            _metaObject = new Object();
            _metaObject['onMetaData'] = _onMetaData;
            _metaObject['onCuePoint'] = _onCuePoint;

            _netConnection = new NetConnection();
            _netConnection.addEventListener(NetStatusEvent.NET_STATUS, _onNetStatus, false, 0, true);
            _netConnection.connect(null);

            _netStream = new NetStream(_netConnection);
            _netStream.inBufferSeek = _inBufferSeek;
            _netStream.addEventListener(NetStatusEvent.NET_STATUS, _onNetStatus, false, 0, true);
            _netStream.client = _metaObject;

            _video = new Video();
            _video.attachNetStream(_netStream);

            addChild(_video);

            super.init();
        }

        /**
         * @inheritDoc
         */
        override protected function destroy():void
        {
            stop();

            _video.clear();
            removeChild(_video);
            _video = null;

            _netStream.soundTransform = null;
            _netStream.removeEventListener(NetStatusEvent.NET_STATUS, _onNetStatus);
            _netStream = null;

            _netConnection.removeEventListener(NetStatusEvent.NET_STATUS, _onNetStatus);
            _netConnection.close();
            _netConnection = null;

            delete(_metaObject['onMetaData']);
            delete(_metaObject['onCuePoint']);
            _metaObject = null;

            super.destroy();
        }

        /**
         * @inheritDoc
         */
        override protected function render():void
        {
            if (getDirty(VSDirtyType.DIMENSION))
            {
                _video.width = width;
                _video.height = height;
            }

            super.render();
        }

        /**
         * @inheritDoc
         */
        override protected function initComplete():void
        {
            super.initComplete();

            if ((_source != null) && (_source != ''))
            {
                _netStream.play(_source);

                if (_mute)
                {
                    mute = true;
                }
                else
                {
                    volume = _volume;
                }

                if (!_autoPlay)
                {
                    pause();
                }
                else
                {
                    _state = STATE_PLAY;
                    dispatchEvent(new VSMediaEvent(VSMediaEvent.PLAY));
                }
            }
        }

        /**
         * @see flash.net.NetStream#resume()
         */
        public function play():void
        {
            if (!_netStream) return;

            _netStream.resume();
            _state = STATE_PLAY;

            dispatchEvent(new VSMediaEvent(VSMediaEvent.PLAY));
        }

        /**
         * @see flash.net.NetStream#pause()
         */
        public function pause():void
        {
            if (!_netStream) return;

            _netStream.pause();
            _state = STATE_PAUSE;

            dispatchEvent(new VSMediaEvent(VSMediaEvent.PAUSE));
        }

        /**
         * Stops the video.
         */
        public function stop():void
        {
            if (!_netStream) return;

            _netStream.pause();
            _netStream.seek(0);
            _state = STATE_STOP;

            dispatchEvent(new VSMediaEvent(VSMediaEvent.STOP));
        }

        /**
         * @see flash.net.NetStream#togglePause
         */
        public function togglePause():void
        {
            if (!_netStream) return;

            _netStream.togglePause();

            if (_state == STATE_PLAY)
            {
                _state = STATE_PAUSE;
                dispatchEvent(new VSMediaEvent(VSMediaEvent.PAUSE));
            }
            else if (_state == STATE_PAUSE)
            {
                _state = STATE_PLAY;
                dispatchEvent(new VSMediaEvent(VSMediaEvent.PLAY));
            }
        }

        /**
         * @see flash.net.NetStream#seek()
         */
        public function seek($offset:Number):void
        {
            if (!_netStream) return;

            _netStream.pause();
            _netStream.seek($offset);
            _netStream.resume();
        }

        /**
         * @see flash.net.NetStream#step()
         */
        public function step($seconds:Number):void
        {
            if (!_netStream) return;

            _netStream.pause();
            _netStream.seek(_netStream.time + $seconds);
            _netStream.resume();
        }

        /**
         * @private
         *
         * @param $data
         */
        private function _onMetaData($data:Object):void
        {
            if (isNaN(_setWidth))
            {
                _width  = $data.width;
            }

            if (isNaN(_setHeight))
            {
                _height = $data.height;
            }

            _duration = $data['duration'];

            setDirty(VSDirtyType.DIMENSION);
        }

        /**
         * @private
         *
         * @param $data
         */
        private function _onCuePoint($data:Object):void
        {

        }

        /**
         * @private
         *
         * flash.events.NetStatusEvent handler.
         *
         * @param $event
         */
        private function _onNetStatus($event:NetStatusEvent):void
        {
            switch ($event.info.code)
            {
                case 'NetConnection.Connect.Success':
                    break;

                case 'NetStream.Buffer.Empty':
                    dispatchEvent(new VSMediaEvent(VSMediaEvent.PLAY_COMPLETE));

                    if (_autoLoop)
                    {
                        _netStream.seek(0);

                        _state = STATE_PLAY;
                        dispatchEvent(new VSMediaEvent(VSMediaEvent.REPEAT));
                    }
                    else
                    {
                        _state = STATE_IDLE;
                    }

                    break;
            }
        }
    }
}
