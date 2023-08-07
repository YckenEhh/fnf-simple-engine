package multiplayer;

import Section.SwagSection;
import Song.SwagSong;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

/**
This is just freeplay menu, but a little bit changed
*/
class MultiplayerSongSelectMenu extends MusicBeatSubstate
{
	public static var songs:Array<SongMetadata> = [];

	public static var curSelected:Int = 0;
	public static var mania:Int = 4;
	var curDifficulty:Int = 1;

	var diffText:FlxText;
	var totalNotesText:FlxText;
	var keycountText:FlxText;

	private var grpSongs:FlxTypedGroup<Alphabet>;

	private var iconArray:Array<HealthIcon> = [];

	var songsJS:Array<String>;
	var iconsJS:Array<String>;
	var weekNumJS:Int;
	var bgColorJS:Array<Int>;

	public function new()
	{
		super();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		add(bg);

		songs = [];

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));

		for (i in 0...initSonglist.length)
		{
			var data:Array<String> = initSonglist[i].split(':');
			songs.push(new SongMetadata(data[0], Std.parseInt(data[2]), data[1]));
		}

		#if sys
		var songsAmmo:Array<String> = [];

		for (songs in FileSystem.readDirectory(FileSystem.absolutePath("mods/freeplay/")))
			{
				if (songs.endsWith('.json'))
				{
					songsAmmo.push(songs);
				}
			}

		for (i in 0...songsAmmo.length)
		{
			var toParse:String = File.getContent('mods/freeplay/' + songsAmmo[i]);
        	var _json:FreeplayState.JsonFreeplay = cast haxe.Json.parse(toParse);

			songsJS = _json.songs;
			iconsJS = _json.icons;
			weekNumJS = _json.weekNum;
			bgColorJS = _json.bgColor;

			addWeek(songsJS, weekNumJS, iconsJS);
		}
		#end

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			iconArray.push(icon);
			add(icon);
		}

		totalNotesText = new FlxText(0, 0, 0, "", 24);
		totalNotesText.font = "assets/fonts/vcr.ttf";
		totalNotesText.x = FlxG.width - totalNotesText.width;
		add(totalNotesText);

		keycountText = new FlxText(0, 36, 0, "", 24);
		keycountText.font = "assets/fonts/vcr.ttf";
		keycountText.x = FlxG.width - keycountText.width;
		add(keycountText);

		diffText = new FlxText(0, 68, 0, "", 24);
		diffText.font = "assets/fonts/vcr.ttf";
		diffText.x = FlxG.width - diffText.width;
		add(diffText);

		changeSelection();
		changeDiff();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE)
		{
			close();
		}

		var upP = FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP;
		var downP = FlxG.keys.justPressed.S || FlxG.keys.justPressed.DOWN;
		var accepted = FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (FlxG.keys.justPressed.A || FlxG.keys.justPressed.LEFT){
			changeDiff(-1);
		}
		if (FlxG.keys.justPressed.D || FlxG.keys.justPressed.RIGHT){
			changeDiff(1);
		}

		if (accepted)
		{
			close();
			MultiplayerLobbyState.songName = songs[curSelected].songName.toLowerCase();
			MultiplayerLobbyState.songDifficulty = curDifficulty;
			MultiplayerLobbyState.songWeek = songs[curSelected].week;
			SessionData._session.send({verb: "song-changed", name: songs[curSelected].songName.toLowerCase(), diff: curDifficulty, week: songs[curSelected].week});
		}
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	function updateInfoTexts() {
		diffText.text = '< ${CoolUtil.difficultyArray[curDifficulty]} >';
		totalNotesText.text = 'Total notes: ${getNotesCount()}';
		keycountText.text = 'Key count: ${mania}';

		totalNotesText.x = FlxG.width - totalNotesText.width;
		keycountText.x = FlxG.width - keycountText.width;
		diffText.x = FlxG.width - diffText.width;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		updateInfoTexts();
	}

	function getNotesCount() {
		var curSong:SwagSong;
		var notesInChart:Int = 0;

		var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
		curSong = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());

		var noteData:Array<SwagSection>;
		noteData = curSong.notes;

		for (section in noteData)
		{
			if (section.mustHitSection){
				notesInChart += section.sectionNotes.length;
			}
		}

		mania = curSong.mania;
		if (mania < 1)
			mania = 4;

		return notesInChart;
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;


		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}

		updateInfoTexts();
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}