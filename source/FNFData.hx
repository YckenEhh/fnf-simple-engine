package;

import flixel.FlxG;
import flixel.system.FlxSound;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

class FNFData
{
	
	public static var version:String = '0.3alpha';
	// KEYBINDS
	public static var kb1:Array<String> = ['SPACE'];
	public static var kb2:Array<String> = ['A', 'D'];
	public static var kb3:Array<String> = ['A', 'SPACE', 'D'];
	public static var kb4:Array<String> = ['A', 'S', 'W', 'D'];
	public static var kb5:Array<String> = ['A', 'S', 'SPACE', 'W', 'D'];
	public static var kb6:Array<String> = ['S', 'D', 'F', 'J', 'K', 'L'];
	public static var kb7:Array<String> = ['S', 'D', 'F', 'SPACE', 'J', 'K', 'L'];
	public static var kb8:Array<String> = ['A', 'S', 'D', 'F', 'H', 'J', 'K', 'L'];
	public static var kb9:Array<String> = ['A', 'S', 'D', 'F', 'SPACE', 'H', 'J', 'K', 'L'];
	// Custom stuff
	public static var charsArray:Array<String> = [];
	public static var charsModsArray:Array<String> = [];
	public static var stagesArray:Array<String> = [];
	public static var stagesModsArray:Array<String> = [];

	public static function loadSave()
	{
		// KEYBINDS
		kb1 = FlxG.save.data.kb1;
		kb2 = FlxG.save.data.kb2;
		kb3 = FlxG.save.data.kb3;
		kb4 = FlxG.save.data.kb4;
		kb5 = FlxG.save.data.kb5;
		kb6 = FlxG.save.data.kb6;
		kb7 = FlxG.save.data.kb7;
		kb8 = FlxG.save.data.kb8;
		kb9 = FlxG.save.data.kb9;
	}

	public static function loadCharsNames()
	{
		charsModsArray = [];
		charsArray = [];
		charsArray = CoolUtil.coolTextFile(Paths.txt('characterList'));
		#if sys
		for (chars in FileSystem.readDirectory(FileSystem.absolutePath("mods/characters/")))
		{
			if (!chars.endsWith('.txt'))
			{
				charsArray.push(chars);
				charsModsArray.push(chars);
			}
		}
		#end
	}

	public static function loadStageNames()
	{
		stagesModsArray = [];
		stagesArray = [];
		stagesArray = CoolUtil.coolTextFile(Paths.txt('stageList'));
		#if sys
		for (stages in FileSystem.readDirectory(FileSystem.absolutePath("mods/stages/")))
		{
			if (!stages.endsWith('.txt'))
			{
				stagesArray.push(stages);
				stagesModsArray.push(stages);
			}
		}
		#end
	}

	public static function getVersionGithub()
	{
		var link:String = 'https://raw.githubusercontent.com/YckenEhh/fnf-simple-engine/main/version.txt';
		var http = new haxe.Http(link);

		http.request();

		var ver:String;

		http.onData = function(data:String)
		{
			ver = data;
		}

		http.onError = function(error)
		{
			trace('error: $error');
		}

		http.request();
		trace('GitHub ver is ${CoolUtil.coolString(ver)[0]}');
		return(ver);
	}

	public static function firstStart()
	{
		// KEYBINDS
		if (FlxG.save.data.kb1 == null)
			FlxG.save.data.kb1 = ['SPACE'];
		if (FlxG.save.data.kb2 == null)
			FlxG.save.data.kb2 = ['A', 'D'];
		if (FlxG.save.data.kb3 == null)
			FlxG.save.data.kb3 = ['A', 'SPACE', 'D'];
		if (FlxG.save.data.kb4 == null)
			FlxG.save.data.kb4 = ['A', 'S', 'W', 'D'];
		if (FlxG.save.data.kb5 == null)
			FlxG.save.data.kb5 = ['A', 'S', 'SPACE', 'W', 'D'];
		if (FlxG.save.data.kb6 == null)
			FlxG.save.data.kb6 = ['S', 'D', 'F', 'J', 'K', 'L'];
		if (FlxG.save.data.kb7 == null)
			FlxG.save.data.kb7 = ['S', 'D', 'F', 'SPACE', 'J', 'K', 'L'];
		if (FlxG.save.data.kb8 == null)
			FlxG.save.data.kb8 = ['A', 'S', 'D', 'F', 'H', 'J', 'K', 'L'];
		if (FlxG.save.data.kb9 == null)
			FlxG.save.data.kb9 = ['A', 'S', 'D', 'F', 'SPACE', 'H', 'J', 'K', 'L'];
		// Scroll speed
		if (FlxG.save.data.scrollSpeed == null)
			FlxG.save.data.scrollSpeed = 1.0;
		// FPS
		if (FlxG.save.data.fpslimit == null)
			FlxG.save.data.fpslimit = 60;
		if (FlxG.save.data.fpslimit < 60)
			FlxG.save.data.fpslimit = 60;
		if (FlxG.save.data.fpslimit > 720)
			FlxG.save.data.fpslimit = 720;
		if (FlxG.save.data.songTimer == null)
			FlxG.save.data.songTimer = true;
		if (FlxG.save.data.laneUnderlay == null)
			FlxG.save.data.laneUnderlay = 0;
	}
}
