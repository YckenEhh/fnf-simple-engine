package ui;

import openfl.display.BitmapData;
import openfl.display.Bitmap;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import openfl.Lib;
import flixel.util.FlxColor;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.events.Event;
import openfl.display.Sprite;
import flixel.FlxG;

/**
Custom volume controller for flixel writed by ycken for fnf simple engine
You also can use it with your flixel projects
*/

class Volume extends Sprite
{
	var text:TextField;
	var currentWindowHeight:Int = Std.int(Lib.application.window.height);
	var textTween:FlxTween;
	var bgTween:FlxTween;
	var bg:Bitmap;

	public function new()
	{
		super();

		FlxG.signals.postStateSwitch.add(onStateSwitch);

		if (FlxG.save.data.volume == null)
			FlxG.save.data.volume = 1;

		FlxG.sound.volume = FlxG.save.data.volume;

		text = new TextField();
		text.text = 'Volume: ${getVolPrc()}%';
		text.setTextFormat(new TextFormat(openfl.utils.Assets.getFont("assets/fonts/vcr.ttf").fontName, 32, FlxColor.WHITE, true));
		text.selectable = false;
		text.height = 16000;
		text.width = 16000;
		text.x = 8;
		text.y = currentWindowHeight - (32 + 8);
		text.alpha = 0;

		bg = new Bitmap(new BitmapData(Std.int((text.text.length * 32) / 1.6) + 8, 40, true, 0xFF000000));
		bg.alpha = 0;
		bg.x = 0;
		bg.y = currentWindowHeight - 40;
		addChild(bg);
		addChild(text);

		addEventListener(Event.ENTER_FRAME, function(e)
		{
			if (FlxG.keys.justPressed.MINUS)
			{
				if (textTween != null)
					textTween.cancel();
				FlxG.sound.volume -= 0.05;
				text.text = 'Volume: ${getVolPrc()}%';
                funnyUpdate();
				text.alpha = 1;
				textTween = FlxTween.tween(text, {alpha: 0}, 0.25, {startDelay: 0.35});
				if (bgTween != null)
					bgTween.cancel();
				bg.alpha = 0.6;
				bgTween = FlxTween.tween(bg, {alpha: 0}, 0.25, {startDelay: 0.35});
				FlxG.save.data.volume = FlxG.sound.volume;
			}
			if (FlxG.keys.justPressed.PLUS)
			{
				if (textTween != null)
					textTween.cancel();
				FlxG.sound.volume += 0.05;
				text.text = 'Volume: ${getVolPrc()}%';
                funnyUpdate();
				text.alpha = 1;
				textTween = FlxTween.tween(text, {alpha: 0}, 0.25, {startDelay: 0.35});
				if (bgTween != null)
					bgTween.cancel();
				bg.alpha = 0.6;
				bgTween = FlxTween.tween(bg, {alpha: 0}, 0.25, {startDelay: 0.35});
				FlxG.save.data.volume = FlxG.sound.volume;
			}
			if (FlxG.keys.justPressed.ZERO)
			{
				if (textTween != null)
					textTween.cancel();
				FlxG.sound.volume = 0;
				text.text = 'Volume: ${getVolPrc()}%';
                funnyUpdate();
				text.alpha = 1;
				textTween = FlxTween.tween(text, {alpha: 0}, 0.25, {startDelay: 0.35});
				if (bgTween != null)
					bgTween.cancel();
				bg.alpha = 0.6;
				bgTween = FlxTween.tween(bg, {alpha: 0}, 0.25, {startDelay: 0.35});
				FlxG.save.data.volume = FlxG.sound.volume;
			}

			currentWindowHeight = Std.int(Lib.application.window.height);
			text.y = currentWindowHeight - (32 + 8);
		});
	}

	function funnyUpdate()
	{
		removeChild(bg);
		removeChild(text);
		text.y = currentWindowHeight - (32 + 8);
		text = new TextField();
		text.text = 'Volume: ${getVolPrc()}%';
		text.setTextFormat(new TextFormat(openfl.utils.Assets.getFont("assets/fonts/vcr.ttf").fontName, 32, FlxColor.WHITE, true));
		text.selectable = false;
		text.height = 16000;
		text.width = 16000;
		text.x = 8;
		text.y = currentWindowHeight - (32 + 8);

		bg = new Bitmap(new BitmapData(Std.int((text.text.length * 32) / 1.6) + 8, 40, true, 0xFF000000));
		bg.x = 0;
		bg.y = currentWindowHeight - 40;
		addChild(bg);
		addChild(text);
	}

	function onStateSwitch():Void
	{
		if (textTween != null)
			textTween.cancel();
		text.alpha = 0;
		if (bgTween != null)
			bgTween.cancel();
		bg.alpha = 0;
	}

	function getVolPrc():Int
	{
		return Std.int(FlxMath.roundDecimal(FlxG.sound.volume * 100, 0));
	}
}
