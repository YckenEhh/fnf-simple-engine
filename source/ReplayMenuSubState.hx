package;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxSprite;
import haxe.Json;
import lime.utils.Assets;
#if sys
import sys.io.File;
#end
import Replay.ReplayFile;

using StringTools;

class ReplayMenuSubState extends MusicBeatSubstate
{
	private var grpControls:FlxTypedGroup<Alphabet>;
	var replaysInFolder:Array<String> = [];
	var replaysForCurrentSong:Array<String> = [];
    var curSelected:Int = 0;
    var hasReplays:Bool = true;

	override function create()
	{
		#if sys
		replaysInFolder = sys.FileSystem.readDirectory(Sys.getCwd() + "replays/");
		#end

		for (i in 0...replaysInFolder.length){
			if (replaysInFolder[i].startsWith(FreeplayState.songs[FreeplayState.curSelected].songName.toLowerCase() + "-replay") && replaysInFolder[i].endsWith(".fnfReplay")){
				replaysForCurrentSong.push(replaysInFolder[i]);
			}
		}

        replaysForCurrentSong.sort(Reflect.compare);

		if (replaysForCurrentSong.length == 0){
			hasReplays = false;
			replaysForCurrentSong.push("nope");
		}

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		bg.screenCenter();
		bg.visible = true;
		bg.antialiasing = true;
		bg.color = 0xFF427B;
		add(bg);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...replaysForCurrentSong.length)
		{
			var curText:String = 'Dont works without sys libriary';
			#if sys
			if (hasReplays){
				var replayFile:ReplayFile = cast Json.parse(File.getContent(Sys.getCwd() + "replays/" + replaysForCurrentSong[i]));
				curText = i + 1 + ". " + FreeplayState.songs[FreeplayState.curSelected].songName + " " + replayFile.date;
			}
			if (!hasReplays){
				curText = "No replays for this song";
			}
			#end

			var replaysLabel:Alphabet = new Alphabet(0, (70 * i) + 30, curText, true, false);
			replaysLabel.isMenuItem = true;
			replaysLabel.targetY = i;
			grpControls.add(replaysLabel);
		}

        changeSelection(0);

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, "WARNING! Replay system in beta! Replay can be not 100% right!", 20);
		text.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER);
		text.scrollFactor.set();
		add(text);

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE)
		{
			close();
		}
        if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP)
            changeSelection(-1);
        if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S)
            changeSelection(1);

		if (FlxG.keys.justPressed.ENTER){
			Replay.loadReplay(replaysForCurrentSong[curSelected]);
			Replay.isReplay = true;
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
	}
}
