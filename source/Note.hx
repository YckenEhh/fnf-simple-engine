package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end

using StringTools;

typedef AsfPixel =
{
	color:String,
	int:Int
}

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var noteType:String;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var noteScore:Float = 1;

	public static var swagWidth:Float = 160 * 0.7;
	public static var noteScale:Float = 0.7;
	public static var pixelnoteScale:Float = 1;
	public static var noteColors:Array<String>;
	var pixelNoteColorsLine:Array<AsfPixel> = [
		{color: 'purple', int: 9},
		{color: 'blue', int: 10},
		{color: 'green', int: 11},
		{color: 'red', int: 12},
		{color: 'white', int: 13},
		{color: 'yellow', int: 14},
		{color: 'violet', int: 15},
		{color: 'black', int: 16},
		{color: 'dark', int: 17}
	];

	public var shouldBePressed:Bool = true;

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, daType:String = 'default', ?sustainNote:Bool = false)
	{
		super();

		if (daType == null)
			daType = 'default';

		switch (daType)
		{
			case 'default':
				shouldBePressed = true;
			case 'blammed':
				shouldBePressed = true;
		}

		/*
			Note scales setup
			There no notes under that 4 beacause this have scale like as 4 keys
		 */
		switch (PlayState.SONG.mania)
		{
			case 4:
				noteScale = 0.7;
			case 5:
				noteScale = 0.65;
			case 6:
				noteScale = 0.6;
			case 7:
				noteScale = 0.56;
			case 8:
				noteScale = 0.48;
			case 9:
				noteScale = 0.46;
		}
		/*
			Considers an approximate swagWidth using math. 
			(Not counting mania 4 because it hurts the eyes, people are accustomed to the original) 
		 */
		pixelnoteScale = (1.428571428571429 * noteScale);
		var genWidth:Float = (228.57142857 * noteScale);
		if (PlayState.SONG.mania != 4)
			genWidth -= PlayState.SONG.mania * 1.6;
		swagWidth = genWidth * 0.7;
		/*
			Considers an approximate pixel note size using math. 
		 */
		/* 
			Note colors
		 */
		switch (PlayState.SONG.mania)
		{
			case 1:
				noteColors = ['white'];
			case 2:
				noteColors = ['purple', 'red'];
			case 3:
				noteColors = ['purple', 'white', 'red'];
			case 4:
				noteColors = ['purple', 'blue', 'green', 'red'];
			case 5:
				noteColors = ['purple', 'blue', 'white', 'green', 'red'];
			case 6:
				noteColors = ['purple', 'green', 'red', 'yellow', 'blue', 'dark'];
			case 7:
				noteColors = ['purple', 'green', 'red', 'white', 'yellow', 'blue', 'dark'];
			case 8:
				noteColors = ['purple', 'blue', 'green', 'red', 'yellow', 'violet', 'black', 'dark'];
			case 9:
				noteColors = ['purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'black', 'dark'];
			default:
				noteColors = ['purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'black', 'dark'];
		}

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += 50;
		y -= 2000;
		this.strumTime = strumTime;

		this.noteData = noteData;

		var daStage:String = PlayState.curStage;

		/*
			Texture data of skin
		 */
		switch (daStage)
		{
			case 'school' | 'schoolEvil':
				switch (daType)
				{
					case "default":
						if (!isSustainNote)
							loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
						else
							loadGraphic(Paths.image('weeb/pixelUI/arrowEnds'), true, 7, 6);

						for (i in 0...pixelNoteColorsLine.length)
						{
							if (!isSustainNote)
								animation.add(pixelNoteColorsLine[i].color + 'Scroll', [pixelNoteColorsLine[i].int]); // Normal notes
							else
							{
								animation.add(pixelNoteColorsLine[i].color + 'hold', [pixelNoteColorsLine[i].int - 9]); // Holds
								animation.add(pixelNoteColorsLine[i].color + 'holdend', [pixelNoteColorsLine[i].int]); // Tails
							}
						}
						setGraphicSize(Std.int(width * PlayState.daPixelZoom * pixelnoteScale));
						updateHitbox();
					case "blammed":
						if (!isSustainNote)
							loadGraphic(Paths.image('noteTypes/pixel/blammedNotes', 'shared'), true, 17, 17);
						else
							loadGraphic(Paths.image('noteTypes/pixel/blammedEnds', 'shared'), true, 7, 6);

						for (i in 0...PlayState.SONG.mania)
						{
							if (!isSustainNote)
								animation.add(pixelNoteColorsLine[i] + 'Scroll', [0]); // Normal notes
							else
							{
								animation.add(pixelNoteColorsLine[i] + 'hold', [0]); // Holds
								animation.add(pixelNoteColorsLine[i] + 'holdend', [1]); // Tails
							}
						}
						setGraphicSize(Std.int(width * PlayState.daPixelZoom * pixelnoteScale));
						updateHitbox();
				}

			default:
				switch (daType)
				{
					case "default":
						frames = Paths.getSparrowAtlas('Arrows');

						animation.addByPrefix('greenScroll', 'green0');
						animation.addByPrefix('redScroll', 'red0');
						animation.addByPrefix('blueScroll', 'blue0');
						animation.addByPrefix('purpleScroll', 'purple0');
						animation.addByPrefix('whiteScroll', 'white0');
						animation.addByPrefix('yellowScroll', 'yellow0');
						animation.addByPrefix('violetScroll', 'violet0');
						animation.addByPrefix('blackScroll', 'black0');
						animation.addByPrefix('darkScroll', 'dark0');

						animation.addByPrefix('purpleholdend', 'pruple end hold');
						animation.addByPrefix('greenholdend', 'green hold end');
						animation.addByPrefix('redholdend', 'red hold end');
						animation.addByPrefix('blueholdend', 'blue hold end');
						animation.addByPrefix('whiteholdend', 'white hold end');
						animation.addByPrefix('yellowholdend', 'yellow hold end');
						animation.addByPrefix('violetholdend', 'violet hold end');
						animation.addByPrefix('blackholdend', 'black hold end');
						animation.addByPrefix('darkholdend', 'dark hold end');

						animation.addByPrefix('purplehold', 'purple hold piece');
						animation.addByPrefix('greenhold', 'green hold piece');
						animation.addByPrefix('redhold', 'red hold piece');
						animation.addByPrefix('bluehold', 'blue hold piece');
						animation.addByPrefix('whitehold', 'white hold piece');
						animation.addByPrefix('yellowhold', 'yellow hold piece');
						animation.addByPrefix('violethold', 'violet hold piece');
						animation.addByPrefix('blackhold', 'black hold piece');
						animation.addByPrefix('darkhold', 'dark hold piece');

						setGraphicSize(Std.int(width * noteScale));
						updateHitbox();
						antialiasing = true;
					case "blammed":
						frames = Paths.getSparrowAtlas('noteTypes/normal/blammedNotes', 'shared');

						animation.addByPrefix('greenScroll', 'warningNote');
						animation.addByPrefix('redScroll', 'warningNote');
						animation.addByPrefix('blueScroll', 'warningNote');
						animation.addByPrefix('purpleScroll', 'warningNote');
						animation.addByPrefix('whiteScroll', 'warningNote');
						animation.addByPrefix('yellowScroll', 'warningNote');
						animation.addByPrefix('violetScroll', 'warningNote');
						animation.addByPrefix('blackScroll', 'warningNote');
						animation.addByPrefix('darkScroll', 'warningNote');

						animation.addByPrefix('purpleholdend', 'warning hold end');
						animation.addByPrefix('greenholdend', 'warning hold end');
						animation.addByPrefix('redholdend', 'warning hold end');
						animation.addByPrefix('blueholdend', 'warning hold end');
						animation.addByPrefix('whiteholdend', 'warning hold end');
						animation.addByPrefix('yellowholdend', 'warning hold end');
						animation.addByPrefix('violetholdend', 'warning hold end');
						animation.addByPrefix('blackholdend', 'warning hold end');
						animation.addByPrefix('darkholdend', 'warning hold end');

						animation.addByPrefix('purplehold', 'warning hold piece');
						animation.addByPrefix('greenhold', 'warning hold piece');
						animation.addByPrefix('redhold', 'warning hold piece');
						animation.addByPrefix('bluehold', 'warning hold piece');
						animation.addByPrefix('whitehold', 'warning hold piece');
						animation.addByPrefix('yellowhold', 'warning hold piece');
						animation.addByPrefix('violethold', 'warning hold piece');
						animation.addByPrefix('blackhold', 'warning hold piece');
						animation.addByPrefix('darkhold', 'warning hold piece');

						setGraphicSize(Std.int(width * noteScale));
						updateHitbox();
						antialiasing = true;
				}
		}
		/*
			Flips arrows trails if user use downscroll
		 */
		if (isSustainNote && FlxG.save.data.downscroll)
		{
			flipY = true;
		}
		/*
			There is setup of scroll notes
		 */
		x += swagWidth * (noteData % PlayState.SONG.mania);
		animation.play(noteColors[noteData % PlayState.SONG.mania] + 'Scroll');
		/*
			There is setup size and position of sustian trails (end of trails).
		 */

		var stepHeight = (((0.45 * Conductor.stepCrochet)) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? PlayState.SONG.speed : FlxG.save.data.scrollSpeed,
			2));

		if (isSustainNote && prevNote != null)
		{
			noteScore * 0.2;
			alpha = 0.6;
			if (FlxG.save.data.downscroll)
			{
				flipY = true;
			}

			x += width / 2;

			animation.play(noteColors[noteData % PlayState.SONG.mania] + 'holdend');

			updateHitbox();

			x -= width / 2;

			if (PlayState.curStage.startsWith('school'))
				x += 30;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(noteColors[prevNote.noteData] + 'hold');
				prevNote.scale.y *= stepHeight / prevNote.height;
				prevNote.updateHitbox();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			// The * 0.5 is so that it's easier to hit them too late, instead of too early
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
