/**
 *  (c) VARIANTE <http://variante.io>
 *
 *  This software is released under the MIT License:
 *  http://www.opensource.org/licenses/mit-license.php
 */
package io.variante.transitions
{
    import com.greensock.plugins.AutoAlphaPlugin;
    import com.greensock.plugins.BlurFilterPlugin;
    import com.greensock.plugins.ColorTransformPlugin;
    import com.greensock.plugins.TintPlugin;
    import com.greensock.plugins.TweenPlugin;
    import com.greensock.TweenMax;
    import io.variante.transitions.easing.Linear;
    import io.variante.utils.VSNumberUtil;

    /**
     * Wrapper class for external tween libraries. Modify this class to use a different tween library.
     */
    public class VSTween
    {
        /**
         * @private
         *
         * Static initializer.
         */
        {
            TweenPlugin.activate([AutoAlphaPlugin, BlurFilterPlugin, TintPlugin, ColorTransformPlugin]);
        }

        /**
         * @copy com.greensock.TweenMax#to()
         */
        public static function to($target:Object, $duration:Number, $vars:Object):TweenMax
        {
            return TweenMax.to($target, $duration, $vars);
        }

        /**
         * @copy com.greensock.TweenMax#from()
         */
        public static function from($target:Object, $duration:Number, $vars:Object):TweenMax
        {
            return TweenMax.from($target, $duration, $vars);
        }

        /**
         * @copy com.greensock.TweenMax#fromTo()
         */
        public static function fromTo($target:Object, $duration:Number, $fromVars:Object, $toVars:Object):TweenMax
        {
            return TweenMax.fromTo($target, $duration, $fromVars, $toVars);
        }

        /**
         * @copy com.greensock.TweenMax#set()
         */
        public static function set($target:Object, $vars:Object):TweenMax
        {
            return TweenMax.set($target, $vars);
        }

        /**
         * @copy com.greensock.TweenMax#killTweensOf()
         */
        public static function killTweensOf($target:*, $vars:Object = null):void
        {
            TweenMax.killTweensOf($target, $vars);
        }

        /**
         * Shakes the target object.
         *
         * @param $target
         */
        public static function shake($target:Object):void
        {
            to($target, 0.1, { x: $target.x + (1 + Math.random() * 2), y: $target.y + (1 + Math.random() * 2), repeat: 2, ease: Linear.easeNone});
            to($target, 0, { x: $target.x + (Math.random() * 0), y: $target.y + (Math.random() * 0), delay: 0.2, onComplete: shake, onCompleteParams: [$target], ease: Linear.easeNone});
        }

        /**
         * Makes the target object breathe.
         *
         * @param $target
         * @param $duration
         */
        public static function breathe($target:Object, $duration:Number = 0.5):void
        {
            fromTo($target, $duration, { scaleX: 1, scaleY: 1, scaleZ: 1 }, { scaleX: 1.03, scaleY: 1.01, scaleZ: 1.02, repeat: -1, yoyo: true });
        }

        /**
         * Makes the target object float.
         *
         * @param $target
         */
        public static function float($target:Object):void
        {
            to($target, VSNumberUtil.randomNumber(1, 3), { x: $target.x + VSNumberUtil.randomNumber(-10, 10), y: $target.y + VSNumberUtil.randomNumber(-10, 10), z: $target.z + VSNumberUtil.randomNumber(-50, 50), ease:Linear.easeNone, onComplete: float, onCompleteParams:[$target] });
        }
    }
}
