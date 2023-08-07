package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import Song.SwagSong;
import Section.SwagSection;
import flash.media.Sound;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

typedef JsonFreeplay = 
{
	songs:Array<String>,
	icons:Array<String>,
	weekNum:Int,
	bgColor:Array<Int>
}

class FreeplayState extends MusicBeatState
{
	public static var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	public static var curSelected:Int = 0;
	public static var isRandomNotes:Bool = false;
	public static var mania:Int = 4;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var totalNotesText:FlxText;
	var maxScoreText:FlxText;
	var keycountText:FlxText;
	var noteRandomText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];
	var scoreBG:FlxSprite;
	var bg:FlxSprite;

	var coolColors:Array<Int> = [
		0xff9271fd,
		0xff9271fd,
		0xff223344,
		0xFF941653,
		0xFFfc96d7,
		0xFFa0d1ff,
		0xffff78bf,
		0xfff6b604
	];

	var songsJS:Array<String>;
	var iconsJS:Array<String>;
	var weekNumJS:Int;
	var bgColorJS:Array<Int>;

	override function create()
	{
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
        	var _json:JsonFreeplay = cast haxe.Json.parse(toParse);

			songsJS = _json.songs;
			iconsJS = _json.icons;
			weekNumJS = _json.weekNum;
			bgColorJS = _json.bgColor;

			coolColors.push(CoolUtil.rgbToHex(bgColorJS[0], bgColorJS[1], bgColorJS[2]));

			addWeek(songsJS, weekNumJS, iconsJS);
		}
		#end

		/* 
			if (FlxG.sound.music != null)
			{
				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		 */

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);

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

		scoreText = new FlxText(FlxG.width * 0.62, 5, 0, "", 32);
		scoreText.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.4), 196, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		totalNotesText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		totalNotesText.font = scoreText.font;
		add(totalNotesText);

		maxScoreText = new FlxText(scoreText.x, scoreText.y + 68, 0, "", 24);
		maxScoreText.font = scoreText.font;
		add(maxScoreText);

		keycountText = new FlxText(scoreText.x, scoreText.y + 100, 0, "", 24);
		keycountText.font = scoreText.font;
		add(keycountText);

		noteRandomText = new FlxText(scoreText.x, scoreText.y + 132, 0, "", 24);
		noteRandomText.font = scoreText.font;
		add(noteRandomText);

		diffText = new FlxText(scoreText.x, scoreText.y + 164, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();

		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, "Press R to open replay selecor menu", 20);
		text.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER);
		text.scrollFactor.set();
		add(text);

		super.create();
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

	function getNotesCount() {
		var curSong:SwagSong;
		var notesInChart:Int = 0;

		var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
		curSong = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());

		var shitTime:Array<Float> = [];

		var noteData:Array<SwagSection>;
		noteData = curSong.notes;

		for (section in noteData)
		{
			if (section.mustHitSection){
				notesInChart += section.sectionNotes.length;
				shitTime.push(section.sectionNotes[0]);
			}
		}

		if (!isRandomNotes){
			mania = curSong.mania;
			if (mania < 1)
				mania = 4;
		}

		return notesInChart;
	}

	function updateInfoTexts() {
		diffText.text = '< ${CoolUtil.difficultyArray[curDifficulty]} >';
		totalNotesText.text = 'Total notes: ${getNotesCount()}';
		maxScoreText.text = 'Max score: ${getNotesCount() * 320}';
		keycountText.text = 'Key count: ${mania}';
		if (isRandomNotes)
			keycountText.text += ' (CTRL + A/D)'; 
		noteRandomText.text = 'Randomizer: ' + getStateByBool(isRandomNotes) + '(E to switch)';
	}

	function getStateByBool(a:Bool){
		var str:String = 'Disabled';
		if (a)
			str = 'Enabled';
		return(str);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (FlxG.keys.justPressed.R){
			openSubState(new ReplayMenuSubState());
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));
		bg.color = FlxColor.interpolate(bg.color, coolColors[songs[curSelected].week], CoolUtil.camLerp(0.045));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;

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

		if (FlxG.keys.justPressed.E){
			isRandomNotes = !isRandomNotes;
			getNotesCount();
			updateInfoTexts();
		}

		if (FlxG.keys.justPressed.A || FlxG.keys.justPressed.LEFT){
			if (FlxG.keys.pressed.CONTROL){
				if (mania > 1)
					mania -= 1;
				updateInfoTexts();
			}
			else
				changeDiff(-1);
		}
		if (FlxG.keys.justPressed.D || FlxG.keys.justPressed.RIGHT){
			if (FlxG.keys.pressed.CONTROL){
				if (mania < 9)
					mania += 1;
				updateInfoTexts();
			}
			else
				changeDiff(1);
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);

			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.isMultiplayer = false;
			PlayState.storyDifficulty = curDifficulty;

			PlayState.storyWeek = songs[curSelected].week;
			trace('CUR WEEK' + PlayState.storyWeek);
			LoadingState.loadAndSwitchState(new PlayState());
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		updateInfoTexts();
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		// lerpScore = 0;
		#end

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
