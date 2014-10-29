/**
 *  ©2012 Andrew Wei (http://andrewwei.mu)
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.media
{
    import flash.events.Event;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundTransform;
    import flash.net.URLRequest;
    import io.variante.events.VSEvent;
    import io.variante.events.VSEventDispatcher;
    import io.variante.events.VSMediaEvent;

    /**
     * Dispatched when sound plays.
     *
     * @eventType io.variante.events.VSMediaEvent.PLAY
     */
    [Event(name = 'PLAY', type = 'io.variante.events.VSMediaEvent')]

    /**
     * Dispatched when sound pauses.
     *
     * @eventType io.variante.events.VSMediaEvent.PAUSE
     */
    [Event(name = 'PAUSE', type = 'io.variante.events.VSMediaEvent')]

    /**
     * Dispatched when sound stops.
     *
     * @eventType io.variante.events.VSMediaEvent.STOP
     */
    [Event(name = 'STOP', type = 'io.variante.events.VSMediaEvent')]

    /**
     * Dispatched when seeking sound.
     *
     * @eventType io.variante.events.VSMediaEvent.SEEK
     */
    [Event(name = 'SEEK', type = 'io.variante.events.VSMediaEvent')]

    /**
     * Dispatched when sound is done loading.
     *
     * @eventType io.variante.events.VSEvent.COMPLETE
     */
    [Event(name = 'COMPLETE', type = 'io.variante.events.VSEvent')]

    /**
     * Dispatched when sound finishes playing.
     *
     * @eventType io.variante.events.VSMediaEvent.PLAY_COMPLETE
     */
    [Event(name = 'PLAY_COMPLETE', type = 'io.variante.events.VSMediaEvent')]

    /**
     * Dispatched when sound repeats.
     *
     * @eventType io.variante.events.VSMediaEvent.REPEAT
     */
    [Event(name = 'REPEAT', type = 'io.variante.events.VSMediaEvent')]

    /**
     * Dispatched when sound volume increases.
     *
     * @eventType io.variante.events.VSMediaEvent.VOLUME_INCREASE
     */
    [Event(name = 'VOLUME_INCREASE', type = 'io.variante.events.VSMediaEvent')]

    /**
     * Dispatched when sound volume decreases.
     *
     * @eventType io.variante.events.VSMediaEvent.VOLUME_DECREASE
     */
    [Event(name = 'VOLUME_DECREASE', type = 'io.variante.events.VSMediaEvent')]

    /**
     * Dispatched when sound mutes.
     *
     * @eventType io.variante.events.VSMediaEvent.MUTE
     */
    [Event(name = 'MUTE', type = 'io.variante.events.VSMediaEvent')]

    /**
     * Dispatched when sound unmutes.
     *
     * @eventType io.variante.events.VSMediaEvent.UNMUTE
     */
    [Event(name = 'UNMUTE', type = 'io.variante.events.VSMediaEvent')]

    /**
     * Generic sound component.
     */
    public class VSSound extends VSEventDispatcher implements IVSMedia
    {
        /**
         * State when this VSSound instance is done loading / has done playing the specified number of times and is in an idle state.
         */
        public static const STATE_IDLE:uint = 0;

        /**
         * State when this VSSound instance is playing.
         */
        public static const STATE_PLAY:uint = 1;

        /**
         * State when this VSSound instance is paused.
         */
        public static const STATE_PAUSE:uint = 2;

        /**
         * State when this VSSound instance is stopped.
         */
        public static const STATE_STOP:uint = 3;

        /**
         * @private
         *
         * ID of this VSSound instance.
         */
        private var _id:int;

        /**
         * @private
         *
         * Path to the source of the sound.
         */
        private var _source:String;

        /**
         * @private
         *
         * URLRequest instance.
         */
        private var _urlRequest:URLRequest;

        /**
         * @private
         *
         * Sound instance.
         */
        private var _sound:Sound;

        /**
         * @private
         *
         * SoundChannel instance.
         */
        private var _soundChannel:SoundChannel;

        /**
         * @private
         *
         * SoundTransform instance.
         */
        private var _soundTransform:SoundTransform;

        /**
         * @private
         *
         * Boolean value that indicates whether this VSSound instance plays itself after the specified sound is done loading.
         */
        private var _autoPlay:Boolean;

        /**
         * @private
         *
         * Number of times this VSSound instance is set to repeat. -1 indicates an infinite loop.
         */
        private var _repeat:int;

        /**
         * @private
         *
         * Current play count.
         */
        private var _playCount:uint;

        /**
         * @private
         *
         * Current position (in milliseconds) of the sound.
         */
        private var _position:Number;

        /**
         * @private
         *
         * Current state of this VSSound instance.
         */
        private var _state:uint;

        /**
         * @private
         *
         * Current volume of the sound (0-1).
         */
        private var _volume:Number;

        /**
         * @private
         *
         * Boolean value indicating whether the sound is mute.
         */
        private var _mute:Boolean;

        /**
         * Gets the ID of this VSSound instance.
         */
        public function get id():int { return _id; }

        /**
         * Sets the ID of this VSSound instance.
         */
        public function set id($value:int):void { _id = $value; }

        /**
         * Gets the boolean value that indicates whether the sound plays itself after it is done loading.
         */
        public function get autoPlay():Boolean { return _autoPlay; }

        /**
         * Sets the boolean value that indicates whether the sound plays itself after it is done loading.
         */
        public function set autoPlay($value:Boolean):void { _autoPlay = $value; }

        /**
         * Gets the number of times the sound repeats.
         */
        public function get repeat():int { return _repeat; }

        /**
         * Sets the number of numbers of times the sound repeats.
         */
        public function set repeat($value:int):void
        {
            _repeat = $value;
            _playCount  = 0; // reset the play count
        }

        /**
         * Gets the current play count.
         */
        public function get playCount():uint { return _playCount; }

        /**
         * Gets the current position of the sound.
         */
        public function get position():Number { return (_state == STATE_PLAY) ? _soundChannel.position : _position; }

        /**
         * Gets the current state of this VSSound instance.
         */
        public function get state():uint { return _state; }

        /**
         * @inheritDoc
         */
        public function get source():String { return _source; }

        /**
         * @inheritDoc
         */
        public function set source($value:String):void
        {
            if (_source == $value) return;

            _source = $value;

            init();
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

            if (_soundTransform)
            {
                _soundTransform.volume       = (_mute) ? 0 : _volume;
                _soundChannel.soundTransform = _soundTransform;

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
            if (_volume == $value) return;

            var isIncreased:Boolean = ($value > _volume);
            var isDecreased:Boolean = ($value < _volume);

            _volume = $value;

            if (_soundTransform && !_mute)
            {
                _soundTransform.volume       = _volume;
                _soundChannel.soundTransform = _soundTransform;

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
         * Gets the length in milliseconds of the current sound.
         */
        public function get length():Number { return (_sound) ? _sound.length : 0; }

        /**
         * Creates a new VSSound instance.
         */
        public function VSSound($source:String = null)
        {
            _id        = -1;
            _source    = $source;
            _autoPlay  = false;
            _repeat    = 0;
            _playCount = 0;
            _position  = 0;
            _volume    = 0.5;
            _mute      = false;
            _state     = STATE_IDLE;
        }

        /**
         * Initializes this VSSound instance.
         */
        protected function init():void
        {
            if (_sound != null)
            {
                destroy();
            }

            _state          = STATE_IDLE;
            _urlRequest     = new URLRequest(_source);
            _soundChannel   = new SoundChannel();
            _soundTransform = new SoundTransform();
            _sound          = new Sound(_urlRequest);

            _sound.addEventListener(Event.COMPLETE, _onLoadSoundComplete, false, 0, true);
        }

        /**
         * Destroys this VSSound instance.
         */
        protected function destroy():void
        {
            _playCount = 0;
            _position  = 0;

            if (_soundChannel.hasEventListener(Event.SOUND_COMPLETE)) _soundChannel.removeEventListener(Event.SOUND_COMPLETE, _onSoundChannelSoundComplete);
            _sound.removeEventListener(Event.COMPLETE, _onLoadSoundComplete);

            _urlRequest     = null;
            _sound          = null;
            _soundChannel   = null;
            _soundTransform = null;
        }

        /**
         * Plays the sound.
         */
        public function play():void
        {
            _state = STATE_PLAY;

            if (!_sound) return;

            _soundChannel                = _sound.play(_position);
            _soundTransform.volume       = (_mute) ? 0 : _volume;
            _soundChannel.soundTransform = _soundTransform;
            _soundChannel.addEventListener(Event.SOUND_COMPLETE, _onSoundChannelSoundComplete, false, 0, true);

            dispatchEvent(new VSMediaEvent(VSMediaEvent.PLAY, { id: _id, playCount: _playCount, position: _position }));
        }

        /**
         * Pauses the sound.
         */
        public function pause():void
        {
            _state = STATE_PAUSE;

            if (!_sound) return;

            _position = _soundChannel.position;

            _soundChannel.stop();
            _soundChannel.removeEventListener(Event.SOUND_COMPLETE, _onSoundChannelSoundComplete);

            dispatchEvent(new VSMediaEvent(VSMediaEvent.PAUSE, { id: _id, playCount: _playCount, position: _position }));
        }

        /**
         * Stops the sound.
         */
        public function stop():void
        {
            _state = STATE_STOP;

            if (!_sound) return;

            _playCount = 0;
            _position = 0;

            _soundChannel.stop();
            _soundChannel.removeEventListener(Event.SOUND_COMPLETE, _onSoundChannelSoundComplete);

            dispatchEvent(new VSMediaEvent(VSMediaEvent.STOP, { id: _id, playCount: _playCount, position: _position }));
        }

        /**
         * Plays the current sound at a certain point.
         *
         * @param $ms
         */
        public function seek($ms:Number):void
        {
            if (!_sound) return;

            _soundChannel.stop();
            _soundChannel.removeEventListener(Event.SOUND_COMPLETE, _onSoundChannelSoundComplete);

            _position = ($ms > length) ? length : $ms;

            _soundChannel                = _sound.play(_position);
            _soundChannel.soundTransform = _soundTransform;
            _soundChannel.addEventListener(Event.SOUND_COMPLETE, _onSoundChannelSoundComplete, false, 0, true);

            _soundTransform.volume = (_mute) ? 0 : _volume;

            dispatchEvent(new VSMediaEvent(VSMediaEvent.SEEK, { id: _id, playCount: _playCount, position: _position }));
        }

        /**
         * @private
         *
         * Handler triggered when sound is loaded.
         *
         * @param $event
         */
        private function _onLoadSoundComplete($event:Event):void
        {
            dispatchEvent(new VSEvent(VSEvent.COMPLETE));

            if (_playCount == 0 && _autoPlay)
            {
                play();
            }
        }

        /**
         * @private
         *
         * Handler triggered when sound is done playing.
         *
         * @param $event
         */
        private function _onSoundChannelSoundComplete($event:Event):void
        {
            _soundChannel.removeEventListener(Event.SOUND_COMPLETE, _onSoundChannelSoundComplete);

            _playCount++;

            dispatchEvent(new VSMediaEvent(VSMediaEvent.PLAY_COMPLETE, { id: _id, playCount: _playCount }));

            if (_playCount <= _repeat || _repeat == -1)
            {
                _position = 0;

                play();

                dispatchEvent(new VSMediaEvent(VSMediaEvent.REPEAT, { id: _id, playCount: _playCount }));
            }
            else
            {
                _state = STATE_IDLE;
            }
        }
    }
}
