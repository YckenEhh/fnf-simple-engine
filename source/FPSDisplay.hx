package;

import flixel.util.FlxStringUtil;
import Discord.DiscordClient;
import GameJolt.GameJoltAPI;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.util.FlxColor;
import openfl.display.Sprite;
import openfl.system.System;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;

class FPSDisplay extends Sprite
{
    var text:TextField;
    public var currentFPS(default, null):Int;
	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;
    
	var isAdvencedMode:Bool = false;

	var startDate:Float = Date.now().getTime();

    public function new()
    {
        super();

        text = new TextField();
        text.text = 'FPS: ';
        text.setTextFormat(new TextFormat(openfl.utils.Assets.getFont("assets/fonts/vcr.ttf").fontName, 16, FlxColor.WHITE, true));
		text.width = 16000;
		text.height = 16000;
		text.selectable = false;
        text.x = 8;
        text.y = 8;
        addChild(text);

        currentFPS = 0;
        cacheCount = 0;
		currentTime = 0;
		times = [];

        #if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			var time = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end
    }

    @:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		if (FlxG.keys.justPressed.F3 && FlxG.keys.pressed.SHIFT){
			isAdvencedMode = !isAdvencedMode;
        }

		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
		{
			times.shift();
		}

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);

		if (currentCount != cacheCount)
		{
			if (!isAdvencedMode)
				text.text = "FPS: " + currentFPS;
			else if (isAdvencedMode){
				var mem:Float = Math.abs(FlxMath.roundDecimal(System.totalMemory / 1000000, 2));

				text.text = "FPS: " + currentFPS;
				text.text += "\nRender latency: " + truncateFloat(1000 / currentFPS, 1) + "ms";
				text.text += "\nRAM used: " + mem + "MB";
				text.text += "\nConductor time: " + Conductor.songPosition;
				if (GameJoltAPI.getStatus())
					text.text += "\nLogined GameJolt as " + GameJoltAPI.getUserInfo(true);
				#if desktop
				text.text += "\nDiscord status: " + DiscordClient.curStatus;
				#end
				text.text += "\nSession time: " + FlxStringUtil.formatTime(((Date.now().getTime() - startDate) / 1000), false);
				text.text += "\n\nSHIFT + F3 to disable advenced information\n";
			}
		}

		cacheCount = currentCount;
	}

	function truncateFloat(number:Float, precision:Int):Float
	{
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
	}
}