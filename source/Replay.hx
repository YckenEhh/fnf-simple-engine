package;

import flixel.FlxG;
import haxe.Json;
#if sys
import sys.io.File;
#end
import Replay.ReplayFile;

using StringTools;

typedef ReplayData =
{
	public var pressed:Array<Bool>;
	public var holded:Array<Bool>;
	public var time:Int;
}

typedef ReplayFile =
{
	public var songName:String;
	public var difficulty:String;
	public var replayData:Array<ReplayData>;
	public var date:String;
	public var downscroll:Bool;
	public var ghosttaps:Bool;
	public var scrollSpeed:Float;
	public var keyBinds:Array<String>;
	public var isCompleted:Bool;
}

class Replay
{
	public static var isReplay:Bool = false;

	public static var holdingArray:Array<Bool> = [];
	public static var controlArray:Array<Bool> = [];

	public static function saveReplay(isCompleted:Bool)
	{
		var json = {
			"songName": PlayState.SONG.song.toLowerCase(),
			"difficulty": PlayState.storyDifficulty,
			"replayData": PlayState.currentReplayPresses,
			"date": Date.now().getMonth() + 1 + "." + Date.now().getUTCDate() + " " + Date.now().getHours() + "h" + Date.now().getMinutes() + "min",
			"downscroll": FlxG.save.data.downscroll,
			"ghosttaps": FlxG.save.data.ghosttaps,
			"scrollSpeed": FlxG.save.data.scrollSpeed,
			"keyBinds": PlayState.controlsFromSave,
			"isCompleted": isCompleted
		};

		var data:String = Json.stringify(json);

		#if sys
		File.saveContent("replays/" + PlayState.SONG.song.toLowerCase() + "-replay" + Date.now().getTime() + ".fnfReplay", data);
        // Date.now().getTime() is smth like replay ig
		#end
	}
	
	public static function loadReplay(name:String){
		#if sys
		var replayFile:ReplayFile = cast Json.parse(File.getContent(Sys.getCwd() + "replays/" + name));
		var poop:String = Highscore.formatSong(replayFile.songName, Std.parseInt(replayFile.difficulty));

		PlayState.SONG = Song.loadFromJson(poop, replayFile.songName);
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = Std.parseInt(replayFile.difficulty);

		PlayState.storyWeek = FreeplayState.songs[FreeplayState.curSelected].week;
		LoadingState.loadAndSwitchState(new PlayState());

		Replay.isReplay = true;
		PlayState.replayFromFile = replayFile.replayData;
		PlayState.downscroll = replayFile.downscroll;
		PlayState.ghostTaps = replayFile.ghosttaps;
		PlayState.controlsFromSave = replayFile.keyBinds;
		PlayState.scrollSpeed = FlxG.save.data.scrollSpeed;
		#end
	}
}
