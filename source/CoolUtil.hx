package;

import flixel.FlxG;
import lime.utils.Assets;

using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<String> = ["EASY", "NORMAL", "HARD"];

	public static function difficultyString():String
	{
		return difficultyArray[PlayState.storyDifficulty];
	}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float
	{
		return Math.max(min, Math.min(max, value));
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function coolString(path:String):Array<String>
	{
		var daList:Array<String> = path.split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function openLink(link:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [link, "&"]);
		#else
		FlxG.openURL(link);
		#end
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	public static function camLerp(a:Float):Float
	{
		return FlxG.elapsed / 0.016666666666666666 * a;
	}
}
