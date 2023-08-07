package;

import openfl.display.BitmapData;
import flixel.util.FlxSort;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
#if mods
import sys.io.File;
import haxe.Json;
import sys.FileSystem;
#end

using StringTools;

typedef CharacterAnimData =
{
	animName:String,
	animXml:String,
	framerate:Int,
	looped:Bool,
	offsetX:Int,
	offsetY:Int
}

typedef CharacterJSON =
{
	animations:Array<CharacterAnimData>,
	idleAnim:String,
	image:String,
	barColor:Array<Int>,
	flipX:Bool,
	cameraOffset:Array<Int>,
	offsetX:Int,
	offsetY:Int
}

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;

	public var barColor:FlxColor = FlxColor.WHITE;
	public var animationNotes:Array<Dynamic> = [];

	// Mods data
	public var isModded:Bool = false;
	public var barColorJson:Array<Int>;
	public var idleAnimJson:String;
	public var imageJson:String;
	public var animationsJson:Array<CharacterAnimData>;
	public var flipXJson:Bool;
	public var cameraOffset:Array<Int>;
	public var globalOffsetX:Int;
	public var globalOffsetY:Int;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false, curRole:String)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		antialiasing = true;

		switch (curCharacter)
		{
			case 'gf':
				tex = Paths.getSparrowAtlas('characters/GF_assets', 'shared');
				frames = tex;
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				playAnim('danceRight');
				barColor = 0xED790135;

			case 'gf-christmas':
				tex = Paths.getSparrowAtlas('characters/gfChristmas', 'shared');
				frames = tex;
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				playAnim('danceRight');
				barColor = 0xED790135;

			case 'gf-car':
				tex = Paths.getSparrowAtlas('characters/gfCar', 'shared');
				frames = tex;
				animation.addByIndices('singUP', 'GF Dancing Beat Hair blowing CAR', [0], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat Hair blowing CAR', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24,
					false);
				animation.addByIndices('idleHair', 'GF Dancing Beat Hair blowing CAR', [10, 11, 12, 25, 26, 27], "", 24, true);

				playAnim('danceRight');
				barColor = 0xED790135;

			case 'gf-pixel':
				tex = Paths.getSparrowAtlas('characters/gfPixel', 'shared');
				frames = tex;
				animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
				animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				playAnim('danceRight');

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
				antialiasing = false;
				barColor = 0xED790135;

			case 'gf-tankmen':
				frames = Paths.getSparrowAtlas('characters/gfTankmen', 'shared');
				animation.addByIndices('sad', 'GF Crying at Gunpoint ', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing at Gunpoint', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing at Gunpoint', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				playAnim('danceRight');
				barColor = 0xED790135;

			case 'pico-speaker':
				tex = Paths.getSparrowAtlas('characters/picoSpeaker', 'shared');
				frames = tex;

				animation.addByIndices('idle', 'Pico shoot 1', [10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24], "", 24, true);

				animation.addByPrefix('shoot1', 'Pico shoot 1', 24, false);
				animation.addByPrefix('shoot2', 'Pico shoot 2', 24, false);
				animation.addByPrefix('shoot3', 'Pico shoot 3', 24, false);
				animation.addByPrefix('shoot4', 'Pico shoot 4', 24, false);

				playAnim('shoot1');

				loadMappedAnims();

				barColor = 0xFFb7d855;

			case 'dad':
				tex = Paths.getSparrowAtlas('characters/DADDY_DEAREST', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'Dad idle dance', 24);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);

				playAnim('idle');

				barColor = 0xFFaf66ce;

			case 'spooky':
				tex = Paths.getSparrowAtlas('characters/spooky_kids_assets', 'shared');
				frames = tex;
				animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);
				animation.addByPrefix('singLEFT', 'note sing left', 24, false);
				animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
				animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
				animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

				playAnim('danceRight');

				barColor = 0xFFd57e00;

			case 'mom':
				tex = Paths.getSparrowAtlas('characters/Mom_Assets', 'shared');
				frames = tex;

				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				playAnim('idle');

				barColor = 0xFFd8558e;

			case 'mom-car':
				tex = Paths.getSparrowAtlas('characters/momCar', 'shared');
				frames = tex;

				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				playAnim('idle');

				barColor = 0xFFd8558e;

			case 'monster':
				tex = Paths.getSparrowAtlas('characters/Monster_Assets', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				playAnim('idle');

				barColor = 0xFFf3ff6e;

			case 'monster-christmas':
				tex = Paths.getSparrowAtlas('characters/monsterChristmas', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				playAnim('idle');

				barColor = 0xFFf3ff6e;

			case 'pico':
				tex = Paths.getSparrowAtlas('characters/Pico_FNF_assetss', 'shared');
				frames = tex;
				animation.addByPrefix('idle', "Pico Idle Dance", 24);
				animation.addByPrefix('singUP', 'pico Up note0', 24, false);
				animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
				animation.addByPrefix('singLEFT', 'Pico NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'Pico Note Right0', 24, false);

				animation.addByPrefix('singUPmiss', 'pico Up note miss', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Pico Down Note MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Pico Note Right Miss', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Pico NOTE LEFT miss', 24, false);

				playAnim('idle');

				flipX = true;

				barColor = 0xFFb7d855;

			case 'bf':
				var tex = Paths.getSparrowAtlas('characters/BOYFRIEND', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				playAnim('idle');

				flipX = true;

				barColor = 0xFF31b0d1;

			case 'bf-christmas':
				var tex = Paths.getSparrowAtlas('characters/bfChristmas', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				playAnim('idle');

				flipX = true;

				barColor = 0xFF31b0d1;

			case 'bf-car':
				var tex = Paths.getSparrowAtlas('characters/bfCar', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);

				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);

				playAnim('idle');

				flipX = true;

				barColor = 0xFF31b0d1;

			case 'bf-pixel':
				frames = Paths.getSparrowAtlas('characters/bfPixel', 'shared');
				animation.addByPrefix('idle', 'BF IDLE', 24, false);
				animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
				animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				width -= 100;
				height -= 100;

				flipX = true;

				antialiasing = false;

				barColor = 0xFF31b0d1;

			case 'bf-pixel-dead':
				frames = Paths.getSparrowAtlas('characters/bfPixelsDEAD', 'shared');
				animation.addByPrefix('singUP', "BF Dies pixel", 24, false);
				animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
				animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
				animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);
				animation.play('firstDeath');

				playAnim('firstDeath');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				flipX = true;

				antialiasing = false;

				barColor = 0xFF31b0d1;

			case 'bf-holding-gf':
				frames = Paths.getSparrowAtlas('characters/bfAndGF', 'shared');
				animation.addByPrefix('idle', 'BF idle dance w gf0', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);

				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS0', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS0', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS0', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS0', 24, false);

				animation.addByPrefix('Catch', 'BF catches GF', 24, false);

				playAnim('idle');

				flipX = true;

				barColor = 0xFF31b0d1;

			case 'bf-holding-gf-dead':
				frames = Paths.getSparrowAtlas('characters/bfHoldingGF-DEAD', 'shared');
				animation.addByPrefix('singUP', "BF Dies with GF", 24, false);
				animation.addByPrefix('firstDeath', "BF Dies with GF", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead with GF Loop", 24, true);
				animation.addByPrefix('deathConfirm', "RETRY confirm holding gf", 24, false);
				animation.play('firstDeath');

				playAnim('firstDeath');

				flipX = true;

				barColor = 0xFF31b0d1;

			case 'senpai':
				frames = Paths.getSparrowAtlas('characters/senpai', 'shared');
				animation.addByPrefix('idle', 'Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'SENPAI UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'SENPAI LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'SENPAI RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'SENPAI DOWN NOTE', 24, false);

				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;

				barColor = 0xFFffaa6f;

			case 'senpai-angry':
				frames = Paths.getSparrowAtlas('characters/senpai', 'shared');
				animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'Angry Senpai UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'Angry Senpai LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'Angry Senpai RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'Angry Senpai DOWN NOTE', 24, false);

				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;

				barColor = 0xFFffaa6f;

			case 'spirit':
				frames = Paths.getPackerAtlas('characters/spirit', 'shared');
				animation.addByPrefix('idle', "idle spirit_", 24, false);
				animation.addByPrefix('singUP', "up_", 24, false);
				animation.addByPrefix('singRIGHT', "right_", 24, false);
				animation.addByPrefix('singLEFT', "left_", 24, false);
				animation.addByPrefix('singDOWN', "spirit down_", 24, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				playAnim('idle');

				antialiasing = false;

				barColor = 0xFFff3c6e;

			case 'parents-christmas':
				frames = Paths.getSparrowAtlas('characters/mom_dad_christmas_assets', 'shared');
				animation.addByPrefix('idle', 'Parent Christmas Idle', 24, false);
				animation.addByPrefix('singUP', 'Parent Up Note Dad', 24, false);
				animation.addByPrefix('singDOWN', 'Parent Down Note Dad', 24, false);
				animation.addByPrefix('singLEFT', 'Parent Left Note Dad', 24, false);
				animation.addByPrefix('singRIGHT', 'Parent Right Note Dad', 24, false);

				animation.addByPrefix('singUP-alt', 'Parent Up Note Mom', 24, false);
				animation.addByPrefix('singDOWN-alt', 'Parent Down Note Mom', 24, false);
				animation.addByPrefix('singLEFT-alt', 'Parent Left Note Mom', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'Parent Right Note Mom', 24, false);

				playAnim('idle');

				barColor = 0x86f800df;

			case 'tankman':
				tex = Paths.getSparrowAtlas('characters/tankmanCaptain', 'shared');
				frames = tex;
				animation.addByPrefix('idle', "Tankman Idle Dance instance", 24);
				animation.addByPrefix('singUP', 'Tankman UP note instance', 24, false);
				animation.addByPrefix('singDOWN', 'Tankman DOWN note instance', 24, false);
				animation.addByPrefix('singLEFT', 'Tankman Right Note instance', 24, false);
				animation.addByPrefix('singRIGHT', 'Tankman Note Left instance', 24, false);

				animation.addByPrefix('singUP-alt', 'Tankman UP note instance', 24, false);
				animation.addByPrefix('singDOWN-alt', 'PRETTY GOOD tankman instance', 24, false);
				animation.addByPrefix('ughAnim', 'TANKMAN UGH instance', 24, false);

				playAnim('idle');

				flipX = true;

				barColor = 0xff000000;
			default:
				#if sys
				if (checkForChar(curCharacter))
				{
					isModded = true;

					var rawXml = File.getContent('mods/characters/$curCharacter/$curCharacter.xml');
					tex = FlxAtlasFrames.fromSparrow(BitmapData.fromFile('mods/characters/$curCharacter/$curCharacter.png'), rawXml);
					frames = tex;

					var toParse:String = File.getContent('mods/characters/$curCharacter/' + curCharacter + '.json');
					var _json:CharacterJSON = cast haxe.Json.parse(toParse);

					barColorJson = _json.barColor;
					idleAnimJson = _json.idleAnim;
					imageJson = _json.image;
					flipXJson = _json.flipX;
					animationsJson = _json.animations;
					globalOffsetX = _json.offsetX;
					globalOffsetY = _json.offsetY;
					cameraOffset = _json.cameraOffset;

					for (anim in animationsJson)
					{
						var animName:String = '' + anim.animName;
						var animXml:String = '' + anim.animXml;
						var animFps:Int = anim.framerate;
						var animLoop:Bool = anim.looped;
						var animX:Int = anim.offsetX;
						var animY:Int = anim.offsetY;

						animation.addByPrefix(animName, animXml, animFps, animLoop);
						addOffset(animName, animX, animY);
					}

					playAnim(idleAnimJson);

					flipX = flipXJson;

					barColor = CoolUtil.rgbToHex(barColorJson[0], barColorJson[1], barColorJson[2]);
				}
				else
				{
					switch (curRole)
					{
						case 'dad':
							PlayState.SONG.player2 = 'dad';
							curCharacter = 'dad';
							tex = Paths.getSparrowAtlas('characters/DADDY_DEAREST', 'shared');
							frames = tex;
							animation.addByPrefix('idle', 'Dad idle dance', 24);
							animation.addByPrefix('singUP', 'Dad Sing Note UP', 24);
							animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24);
							animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
							animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);

							addOffset('idle');
							addOffset("singUP", -6, 50);
							addOffset("singRIGHT", 0, 27);
							addOffset("singLEFT", -10, 10);
							addOffset("singDOWN", 0, -30);

							playAnim('idle');
							barColor = 0xFFaf66ce;
						case 'bf':
							PlayState.SONG.player1 = 'bf';
							curCharacter = 'bf';
							var tex = Paths.getSparrowAtlas('characters/BOYFRIEND', 'shared');
							frames = tex;
							animation.addByPrefix('idle', 'BF idle dance', 24, false);
							animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
							animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
							animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
							animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
							animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
							animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
							animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
							animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
							animation.addByPrefix('hey', 'BF HEY', 24, false);

							animation.addByPrefix('firstDeath', "BF dies", 24, false);
							animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
							animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

							animation.addByPrefix('scared', 'BF idle shaking', 24);

							playAnim('idle');

							flipX = true;

							barColor = 0xFF31b0d1;
					}
					trace('Cannot to find character with tag ${curCharacter}');
				}
				#end
		}
		switch (curCharacter)
		{
			case 'gf-tankmen':
				loadOffsetFile('gf');
			default:
				if (!isModded)
					loadOffsetFile(curCharacter);
		}

		dance();

		if (isPlayer)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
	}

	private function checkForChar(name:String):Bool
	{
		var charList:Array<String> = FNFData.charsArray;
		var isFounded:Bool = false;
		for (char in charList)
		{
			if (char == name)
				isFounded = true;
		}
		return isFounded;
	}

	private function loadOffsetFile(offsetCharacter:String)
	{
		var fileData:String = '';
		#if sys
		fileData = File.getContent("assets/shared/images/characters/" + offsetCharacter + "Offsets.txt");
		#end
		var daFile:Array<String> = coolTextFileAgainLol(fileData);

		for (i in daFile)
		{
			var splitWords:Array<String> = i.split(" ");
			addOffset(splitWords[0], Std.parseInt(splitWords[1]), Std.parseInt(splitWords[2]));
		}
	}

	private function coolTextFileAgainLol(string:String):Array<String>
	{
		var daList:Array<String> = string.split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return (daList);
	}

	override function update(elapsed:Float)
	{
		if (!curCharacter.startsWith('bf'))
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;

			if (curCharacter == 'dad')
				dadVar = 6.1;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}

		switch (curCharacter)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode)
		{
			switch (curCharacter)
			{
				case 'gf':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}
				case 'gf-tankmen':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}
				case "pico-speaker":
					// for pico??
					if (animationNotes.length > 0)
					{
						if (Conductor.songPosition > animationNotes[0][0])
						{
							var shootAnim:Int = 1;

							if (animationNotes[0][1] >= 2)
								shootAnim = 3;

							shootAnim += FlxG.random.int(0, 1);

							playAnim('shoot' + shootAnim, true);
							animationNotes.shift();
						}
					}

				case 'gf-christmas':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'gf-car':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}
				case 'gf-pixel':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'spooky':
					danced = !danced;

					if (danced)
						playAnim('danceRight');
					else
						playAnim('danceLeft');
				default:
					playAnim('idle');
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	function loadMappedAnims()
	{
		var swagshit = Song.loadFromJson('picospeaker', 'stress');

		var notes = swagshit.notes;

		for (section in notes)
		{
			for (idk in section.sectionNotes)
			{
				animationNotes.push(idk);
			}
		}

		TankmenBG.animationNotes = animationNotes;

		trace(animationNotes);
		animationNotes.sort(sortAnims);
	}

	function sortAnims(val1:Array<Dynamic>, val2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, val1[0], val2[0]);
	}
}
