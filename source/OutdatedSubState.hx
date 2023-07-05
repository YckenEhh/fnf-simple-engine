package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;

using StringTools;

class OutdatedSubState extends MusicBeatSubstate
{
	public static var newestVersion:String;
	public static var needVer:String;

	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xa8cbff;
		add(bg);

		var upperText:FlxText = new FlxText(0, 0, 0, 'ENGINE IS OUTDATED!', 52);
		upperText.font = 'VCR OSD Mono';
		upperText.borderQuality = 2;
		upperText.borderSize = 2;
		upperText.borderStyle = OUTLINE;
		upperText.y = upperText.height * 1.5;
		upperText.screenCenter(X);
		add(upperText);

		var downText:FlxText = new FlxText(0, 0, upperText.width * 1.75, '', 32);
		downText.font = 'VCR OSD Mono';
		downText.text = 'Please, press enter to install lasted version of engine, if you want to skip this notification press ESCAPE. Your version of game ${FNFData.version}, newest version is ${needVer}';
		downText.borderQuality = 2;
		downText.borderSize = 2;
		downText.alignment = CENTER;
		downText.borderStyle = OUTLINE;
		downText.screenCenter();
		downText.y += upperText.height * 1.5;
		add(downText);
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ENTER && sys.FileSystem.exists(Sys.getCwd() + "\\Update.exe")){
			var dir:String = Sys.getCwd();
			Sys.command(dir + 'Update.exe', [getUpdateFileLink()]);
			Sys.exit(1);
		}
		if (FlxG.keys.justPressed.ESCAPE)
		{
			close();
		}
		super.update(elapsed);
	}

	function getUpdateFileLink(){
		var link:String = 'https://raw.githubusercontent.com/YckenEhh/fnf-simple-engine/main/updateLink.updateData';
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
		return(ver);
	}
}
