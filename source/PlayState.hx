package;

import flixel.tweens.misc.NumTween;
import flixel.math.FlxAngle;
import flixel.group.FlxGroup;
#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import flash.media.Sound;
import Replay.ReplayData;
import multiplayer.MultiplayerLobbyState;
import multiplayer.MultiplayerResultsSubstate;
import multiplayer.SessionData;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var curStage:String = 'stage';
	public static var stageCheck:String = 'stage';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var unrankedGame:Bool = false;
	public static var isMultiplayer:Bool = false;

	var yourPlayerID:Int = 0;

	var moddedStage:Bool = false;
	var stageFolder:String = '';

	var halloweenLevel:Bool = false;

	private var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var curSection:Int = 0;

	private var camFollow:FlxObject;
	private var camPos:FlxPoint;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;
	private var opponentStrums:FlxTypedGroup<FlxSprite>;
	var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;
	private var misses:Int = 0;
	private var accuracy:Float = 100.00;
	private var nps:Int = 0;
	private var npsMax:Int = 0;
	private var totalNotesHit:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var tankmanRun:FlxTypedGroup<TankmenBG>;
	var gfCutsceneLayer:FlxGroup;
	var bfTankCutsceneLayer:FlxGroup;
	var tankWatchtower:BGSprite;
	var tankGround:BGSprite;
	var foregroundSprites:FlxTypedGroup<BGSprite>;

	var talking:Bool = true;

	public static var songScore:Int = 0;

	var scoreTxt:FlxText;
	var judgementCounter:FlxText;

	var isArrowsGenerated:Bool = false;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;

	public static var controlsFromSave:Array<String>;

	public static var mania:Int = 4;

	public static var currentSongSpeed:Float = 0;

	var keyCountJson:Int = 4;

	public static var botplay:Bool = false;

	var botplayTxt:FlxText;
	var timerText:FlxText;

	public var laneunderlay:FlxSprite;
	public var laneunderlayOpponent:FlxSprite;

	var daRatings:Array<Int> = [0, 0, 0, 0, 0];
	var laneOffset:Float = 45.0;

	var noteSpeedSprite:FlxText;

	public static var highestCombo:Int = 0;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	// replays
	public static var currentReplayPresses:Array<ReplayData> = [];
	public static var downscroll:Bool = false;
	public static var ghostTaps:Bool = false;
	public static var scrollSpeed:Float = 1.0;
	public static var replayFromFile:Array<ReplayData> = [];

	// Multiplayer
	var player0Info:FlxText;
	var player1Info:FlxText;
	var opponentJudgementCounter:FlxText;
	var waitingForPlayerText:Alphabet;

	public static var opponentScore:Int = 0;
	public static var opponentAccuracy:Float = 100.00;
	public static var opponentDaRatings:Array<Int> = [0, 0, 0, 0, 0];
	public static var opponentMisses:Int = 0;
	public static var isYouReady:Bool = false;
	public static var isOpponentReady:Bool = false;
	public static var opponentArrowsAnimations:Array<String>;
	public static var yourArrowsAnimations:Array<String>;
	public static var opponentCharAnim:String = 'idle';

	private var middlescroll:Bool = FlxG.save.data.middlescroll;

	override public function create()
	{
		FNFData.loadSave();

		// Preload vocals
		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Sound.fromFile(Paths.voices(PlayState.SONG.song)));
		else
			vocals = new FlxSound();
		vocals.pause();

		// Multiplayer (again)
		// https://discord.com/assets/38002403475def186f4b7ac64cc9d04f.svg omg this is...
		opponentScore = 0;
		opponentAccuracy = 100.00;
		opponentMisses = 0;
		opponentDaRatings = [0, 0, 0, 0, 0];
		isYouReady = false;
		isOpponentReady = false;
		opponentArrowsAnimations = [
			'static',
			'static',
			'static',
			'static',
			'static',
			'static',
			'static',
			'static',
			'static'
		];
		opponentCharAnim = 'idle';
		yourArrowsAnimations = [
			'static',
			'static',
			'static',
			'static',
			'static',
			'static',
			'static',
			'static',
			'static'
		];

		if (isMultiplayer)
			yourPlayerID = MultiplayerLobbyState.yourPlayerID;
		if (isMultiplayer)
			middlescroll = false;
		else
			middlescroll = FlxG.save.data.middlescroll;

		trace('MULTIPLAYER STATUS: ' + isMultiplayer);

		keyCountJson = SONG.mania;

		if (Replay.isReplay)
		{
			currentReplayPresses = replayFromFile;
		}
		else
		{
			currentReplayPresses = [];
			downscroll = FlxG.save.data.downscroll;
			ghostTaps = FlxG.save.data.ghosttaps;
			scrollSpeed = FlxG.save.data.scrollSpeed;
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		daRatings = [0, 0, 0, 0, 0];
		songScore = 0;
		currentSongSpeed = SONG.speed;
		if (FlxG.save.data.scrollSpeed != 1.0)
			currentSongSpeed = FlxG.save.data.scrollSpeed;

		if (SONG.mania > 0)
		{
			mania = SONG.mania;
		}
		else
		{
			mania = 4;
			SONG.mania = mania;
		}

		if (FreeplayState.isRandomNotes)
		{
			SONG.mania = FreeplayState.mania;
			mania = FreeplayState.mania;
		}

		trace('Mania: $mania');

		if (!Replay.isReplay)
		{
			switch (mania)
			{
				case 1:
					controlsFromSave = FNFData.kb1;
				case 2:
					controlsFromSave = FNFData.kb2;
				case 3:
					controlsFromSave = FNFData.kb3;
				case 4:
					controlsFromSave = FNFData.kb4;
				case 5:
					controlsFromSave = FNFData.kb5;
				case 6:
					controlsFromSave = FNFData.kb6;
				case 7:
					controlsFromSave = FNFData.kb7;
				case 8:
					controlsFromSave = FNFData.kb8;
				case 9:
					controlsFromSave = FNFData.kb9;
			}
		}

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		foregroundSprites = new FlxTypedGroup<BGSprite>();

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		switch (SONG.song.toLowerCase())
		{
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('songs/senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('songs/roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('songs/thorns/thornsDialogue'));
		}

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		#end

		StageData.getDefaults();
		switch (stageCheck)
		{
			case 'stage':
				{
					moddedStage = false;

					defaultCamZoom = 0.9;
					curStage = 'stage';
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback', 'shared'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					add(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront', 'shared'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = true;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					add(stageFront);

					var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains', 'shared'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					stageCurtains.antialiasing = true;
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;

					add(stageCurtains);
				}
			case 'spooky':
				{
					moddedStage = false;

					curStage = 'spooky';
					halloweenLevel = true;

					var hallowTex = Paths.getSparrowAtlas('halloween_bg', 'week2');

					halloweenBG = new FlxSprite(-200, -100);
					halloweenBG.frames = hallowTex;
					halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
					halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
					halloweenBG.animation.play('idle');
					halloweenBG.antialiasing = true;
					add(halloweenBG);

					isHalloween = true;
				}
			case 'philly':
				{
					moddedStage = false;

					curStage = 'philly';

					var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky', 'week3'));
					bg.scrollFactor.set(0.1, 0.1);
					add(bg);

					var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city', 'week3'));
					city.scrollFactor.set(0.3, 0.3);
					city.setGraphicSize(Std.int(city.width * 0.85));
					city.updateHitbox();
					add(city);

					phillyCityLights = new FlxTypedGroup<FlxSprite>();
					add(phillyCityLights);

					for (i in 0...5)
					{
						var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i, 'week3'));
						light.scrollFactor.set(0.3, 0.3);
						light.visible = false;
						light.setGraphicSize(Std.int(light.width * 0.85));
						light.updateHitbox();
						light.antialiasing = true;
						phillyCityLights.add(light);
					}

					var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain', 'week3'));
					add(streetBehind);

					phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
					add(phillyTrain);

					trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
					FlxG.sound.list.add(trainSound);

					// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

					var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street', 'week3'));
					add(street);
				}
			case 'limo':
				{
					moddedStage = false;

					curStage = 'limo';
					defaultCamZoom = 0.90;

					var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset', 'week4'));
					skyBG.scrollFactor.set(0.1, 0.1);
					add(skyBG);

					var bgLimo:FlxSprite = new FlxSprite(-200, 480);
					bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo', 'week4');
					bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
					bgLimo.animation.play('drive');
					bgLimo.scrollFactor.set(0.4, 0.4);
					add(bgLimo);

					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);

					for (i in 0...5)
					{
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
						dancer.scrollFactor.set(0.4, 0.4);
						grpLimoDancers.add(dancer);
					}

					var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay', 'week4'));
					overlayShit.alpha = 0.5;
					// add(overlayShit);

					// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

					// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

					// overlayShit.shader = shaderBullshit;

					var limoTex = Paths.getSparrowAtlas('limo/limoDrive', 'week4');

					limo = new FlxSprite(-120, 550);
					limo.frames = limoTex;
					limo.animation.addByPrefix('drive', "Limo stage", 24);
					limo.animation.play('drive');
					limo.antialiasing = true;

					fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol', 'week4'));
					// add(limo);
				}
			case 'mall':
				{
					moddedStage = false;

					curStage = 'mall';

					defaultCamZoom = 0.80;

					var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls', 'week5'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					add(bg);

					upperBoppers = new FlxSprite(-240, -90);
					upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop', 'week5');
					upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
					upperBoppers.antialiasing = true;
					upperBoppers.scrollFactor.set(0.33, 0.33);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					add(upperBoppers);

					var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator', 'week5'));
					bgEscalator.antialiasing = true;
					bgEscalator.scrollFactor.set(0.3, 0.3);
					bgEscalator.active = false;
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);

					var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree', 'week5'));
					tree.antialiasing = true;
					tree.scrollFactor.set(0.40, 0.40);
					add(tree);

					bottomBoppers = new FlxSprite(-300, 140);
					bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop', 'week5');
					bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
					bottomBoppers.antialiasing = true;
					bottomBoppers.scrollFactor.set(0.9, 0.9);
					bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
					bottomBoppers.updateHitbox();
					add(bottomBoppers);

					var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow', 'week5'));
					fgSnow.active = false;
					fgSnow.antialiasing = true;
					add(fgSnow);

					santa = new FlxSprite(-840, 150);
					santa.frames = Paths.getSparrowAtlas('christmas/santa', 'week5');
					santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
					santa.antialiasing = true;
					add(santa);
				}
			case 'mallEvil':
				{
					moddedStage = false;

					curStage = 'mallEvil';
					var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG', 'week5'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					add(bg);

					var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree', 'week5'));
					evilTree.antialiasing = true;
					evilTree.scrollFactor.set(0.2, 0.2);
					add(evilTree);

					var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow", 'week5'));
					evilSnow.antialiasing = true;
					add(evilSnow);
				}
			case 'school':
				{
					moddedStage = false;

					curStage = 'school';

					// defaultCamZoom = 0.9;

					var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky', 'week6'));
					bgSky.scrollFactor.set(0.1, 0.1);
					add(bgSky);

					var repositionShit = -200;

					var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool', 'week6'));
					bgSchool.scrollFactor.set(0.6, 0.90);
					add(bgSchool);

					var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet', 'week6'));
					bgStreet.scrollFactor.set(0.95, 0.95);
					add(bgStreet);

					var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack', 'week6'));
					fgTrees.scrollFactor.set(0.9, 0.9);
					add(fgTrees);

					var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
					var treetex = Paths.getPackerAtlas('weeb/weebTrees', 'week6');
					bgTrees.frames = treetex;
					bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
					bgTrees.animation.play('treeLoop');
					bgTrees.scrollFactor.set(0.85, 0.85);
					add(bgTrees);

					var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
					treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals', 'week6');
					treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
					treeLeaves.animation.play('leaves');
					treeLeaves.scrollFactor.set(0.85, 0.85);
					add(treeLeaves);

					var widShit = Std.int(bgSky.width * 6);

					bgSky.setGraphicSize(widShit);
					bgSchool.setGraphicSize(widShit);
					bgStreet.setGraphicSize(widShit);
					bgTrees.setGraphicSize(Std.int(widShit * 1.4));
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					treeLeaves.setGraphicSize(widShit);

					fgTrees.updateHitbox();
					bgSky.updateHitbox();
					bgSchool.updateHitbox();
					bgStreet.updateHitbox();
					bgTrees.updateHitbox();
					treeLeaves.updateHitbox();

					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					if (SONG.song.toLowerCase() == 'roses')
					{
						bgGirls.getScared();
					}

					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					add(bgGirls);
				}
			case 'schoolEvil':
				{
					moddedStage = false;

					curStage = 'schoolEvil';

					var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
					var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

					var posX = 400;
					var posY = 200;

					var bg:FlxSprite = new FlxSprite(posX, posY);
					bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool', 'week6');
					bg.animation.addByPrefix('idle', 'background 2', 24);
					bg.animation.play('idle');
					bg.scrollFactor.set(0.8, 0.9);
					bg.scale.set(6, 6);
					add(bg);
				}
			case 'tank':
				moddedStage = false;

				defaultCamZoom = 0.90;
				curStage = 'tank';

				var bg:BGSprite = new BGSprite('tankSky', -400, -400, 0, 0);
				add(bg);

				var tankSky:BGSprite = new BGSprite('tankClouds', FlxG.random.int(-700, -100), FlxG.random.int(-20, 20), 0.1, 0.1);
				tankSky.active = true;
				tankSky.velocity.x = FlxG.random.float(5, 15);
				add(tankSky);

				var tankMountains:BGSprite = new BGSprite('tankMountains', -300, -20, 0.2, 0.2);
				tankMountains.setGraphicSize(Std.int(tankMountains.width * 1.2));
				tankMountains.updateHitbox();
				add(tankMountains);

				var tankBuildings:BGSprite = new BGSprite('tankBuildings', -200, 0, 0.30, 0.30);
				tankBuildings.setGraphicSize(Std.int(tankBuildings.width * 1.1));
				tankBuildings.updateHitbox();
				add(tankBuildings);

				var tankRuins:BGSprite = new BGSprite('tankRuins', -200, 0, 0.35, 0.35);
				tankRuins.setGraphicSize(Std.int(tankRuins.width * 1.1));
				tankRuins.updateHitbox();
				add(tankRuins);

				var smokeLeft:BGSprite = new BGSprite('smokeLeft', -200, -100, 0.4, 0.4, ['SmokeBlurLeft'], true);
				add(smokeLeft);

				var smokeRight:BGSprite = new BGSprite('smokeRight', 1100, -100, 0.4, 0.4, ['SmokeRight'], true);
				add(smokeRight);

				tankWatchtower = new BGSprite('tankWatchtower', 100, 50, 0.5, 0.5, ['watchtower gradient color']);
				add(tankWatchtower);

				tankGround = new BGSprite('tankRolling', 300, 300, 0.5, 0.5, ['BG tank w lighting'], true);
				add(tankGround);

				tankmanRun = new FlxTypedGroup<TankmenBG>();
				add(tankmanRun);

				var tankGround:BGSprite = new BGSprite('tankGround', -420, -150);
				tankGround.setGraphicSize(Std.int(tankGround.width * 1.15));
				tankGround.updateHitbox();
				add(tankGround);

				moveTank();

				var fgTank0:BGSprite = new BGSprite('tank0', -500, 650, 1.7, 1.5, ['fg']);
				foregroundSprites.add(fgTank0);

				var fgTank1:BGSprite = new BGSprite('tank1', -300, 750, 2, 0.2, ['fg']);
				foregroundSprites.add(fgTank1);

				var fgTank2:BGSprite = new BGSprite('tank2', 450, 940, 1.5, 1.5, ['foreground']);
				foregroundSprites.add(fgTank2);

				var fgTank4:BGSprite = new BGSprite('tank4', 1300, 900, 1.5, 1.5, ['fg']);
				foregroundSprites.add(fgTank4);

				var fgTank5:BGSprite = new BGSprite('tank5', 1620, 700, 1.5, 1.5, ['fg']);
				foregroundSprites.add(fgTank5);

				var fgTank3:BGSprite = new BGSprite('tank3', 1300, 1200, 3.5, 2.5, ['fg']);
				foregroundSprites.add(fgTank3);
			default:
				#if sys
				moddedStage = true;

				curStage = SONG.stage;
				stageFolder = SONG.stage;

				var toParse:String = File.getContent('mods/stages/$curStage/config.json');
				var _json:StageData.StageConfig = cast haxe.Json.parse(toParse);

				defaultCamZoom = _json.cameraZoom;

				var partsCount:Int = 0;

				for (stages in FileSystem.readDirectory(FileSystem.absolutePath('mods/stages/$curStage/')))
				{
					if (stages.endsWith('.png'))
					{
						partsCount += 1;
					}
				}
				trace('stage $curStage has $partsCount parts');

				if (partsCount > 0)
				{
					for (j in 0...partsCount)
					{
						var part:StagePart = new StagePart(curStage, j);
						add(part);
					}
				}
				#end
		}

		var gfVersion:String = 'gf';

		switch (curStage)
		{
			case 'limo':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school':
				gfVersion = 'gf-pixel';
			case 'schoolEvil':
				gfVersion = 'gf-pixel';
			case 'tank':
				gfVersion = 'gf-tankmen';
		}

		switch (SONG.song.toLowerCase())
		{
			case 'stress':
				gfVersion = 'pico-speaker';
		}

		if (curStage == 'limo')
			gfVersion = 'gf-car';

		gf = new Character(400, 130, gfVersion, 'gf');
		gf.scrollFactor.set(0.95, 0.95);

		switch (gfVersion)
		{
			case 'pico-speaker':
				gf.x -= 50;
				gf.y -= 200;

				var tempTankman:TankmenBG = new TankmenBG(20, 500, true);
				tempTankman.strumTime = 10;
				tempTankman.resetShit(20, 600, true);
				tankmanRun.add(tempTankman);

				for (i in 0...TankmenBG.animationNotes.length)
				{
					if (FlxG.random.bool(16))
					{
						var tankman:TankmenBG = tankmanRun.recycle(TankmenBG);
						tankman.strumTime = TankmenBG.animationNotes[i][0];
						tankman.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
						tankmanRun.add(tankman);
					}
				}
		}

		dad = new Character(100, 100, SONG.player2, 'dad');

		camPos = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'tankman':
				dad.y += 180;
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1, 'bf');

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case "tank":
				gf.y += 10;
				gf.x -= 30;
				boyfriend.x += 40;
				boyfriend.y += 0;
				dad.y += 60;
				dad.x -= 80;

				if (gfVersion != 'pico-speaker')
				{
					gf.x -= 170;
					gf.y -= 75;
				}
			default:
				if (moddedStage)
				{
					#if sys
					var toParse:String = File.getContent('mods/stages/$stageFolder/config.json');
					var _json:StageData.StageConfig = cast haxe.Json.parse(toParse);
					gf.y -= _json.gfOffsets[1];
					gf.x += _json.gfOffsets[0];
					boyfriend.x += _json.bfOffsets[0];
					boyfriend.y -= _json.bfOffsets[1];
					dad.y -= _json.dadOffsets[1];
					dad.x += _json.dadOffsets[0];
					#end
				}
		}

		add(gf);

		gfCutsceneLayer = new FlxGroup();
		add(gfCutsceneLayer);

		bfTankCutsceneLayer = new FlxGroup();
		add(bfTankCutsceneLayer);

		if (curStage == 'limo')
			add(limo);

		add(dad);
		add(boyfriend);

		if (dad.isModded)
		{
			dad.x += dad.globalOffsetX;
			dad.y -= dad.globalOffsetY;
			camPos.set(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);
		}
		if (boyfriend.isModded)
		{
			boyfriend.x += boyfriend.globalOffsetX;
			boyfriend.y -= boyfriend.globalOffsetY;
		}
		if (gf.isModded)
		{
			gf.x += gf.globalOffsetX;
			gf.y -= gf.globalOffsetY;
		}

		if (curStage == 'tank')
			add(foregroundSprites);

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		var laneUnderlayScale:Float;

		laneunderlayOpponent = new FlxSprite(0, 0).makeGraphic(1, 1);
		laneunderlayOpponent.alpha = FlxG.save.data.laneUnderlay;
		laneunderlayOpponent.color = FlxColor.BLACK;
		laneunderlayOpponent.scrollFactor.set();
		laneunderlayOpponent.cameras = [camHUD];

		laneunderlay = new FlxSprite(0, 0).makeGraphic(1, 1);
		laneunderlay.alpha = FlxG.save.data.laneUnderlay;
		laneunderlay.color = FlxColor.BLACK;
		laneunderlay.scrollFactor.set();
		laneunderlay.cameras = [camHUD];

		if (middlescroll)
		{
			add(laneunderlay);
		}
		else
		{
			add(laneunderlayOpponent);
			add(laneunderlay);
		}

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		var noteSplash:NoteSplash = new NoteSplash(100, 100, 0, 'default');
		grpNoteSplashes.add(noteSplash);
		noteSplash.alpha = 0;

		add(grpNoteSplashes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		opponentStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		#if desktop
		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / FlxG.save.data.fpslimit));
		#else
		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		#end
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		if (downscroll)
			healthBarBG.y = 50;
		healthBarBG.scrollFactor.set();
		if (!isMultiplayer)
			add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(dad.barColor, boyfriend.barColor);
		// healthBar
		if (!isMultiplayer)
			add(healthBar);

		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 190, healthBarBG.y + 30, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		if (!isMultiplayer)
			add(scoreTxt);

		judgementCounter = new FlxText(20, 0, 0, "", 20);
		if (!isMultiplayer)
		{
			judgementCounter.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		else if (isMultiplayer)
		{
			judgementCounter.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			judgementCounter.x = FlxG.width - (judgementCounter.width + 20);
		}
		judgementCounter.borderSize = 2;
		judgementCounter.borderQuality = 2;
		judgementCounter.scrollFactor.set();
		judgementCounter.cameras = [camHUD];
		judgementCounter.screenCenter(Y);
		judgementCounter.text = 'Marvelous: ${daRatings[0]}\nSicks: ${daRatings[1]}\nGoods: ${daRatings[2]}\nBads: ${daRatings[3]}\nShits: ${daRatings[4]}\nMisses: ${misses}\n';
		if (FlxG.save.data.judgementCounter || isMultiplayer)
		{
			add(judgementCounter);
		}

		opponentJudgementCounter = new FlxText(20, 0, 0, "", 20);
		opponentJudgementCounter.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		opponentJudgementCounter.borderSize = 2;
		opponentJudgementCounter.borderQuality = 2;
		opponentJudgementCounter.scrollFactor.set();
		opponentJudgementCounter.cameras = [camHUD];
		opponentJudgementCounter.screenCenter(Y);
		opponentJudgementCounter.text = 'Marvelous: ${opponentDaRatings[0]}\nSicks: ${opponentDaRatings[1]}\nGoods: ${opponentDaRatings[2]}\nBads: ${opponentDaRatings[3]}\nShits: ${opponentDaRatings[4]}\nMisses: ${opponentMisses}\n';
		if (isMultiplayer)
			add(opponentJudgementCounter);

		botplayTxt = new FlxText(0, 0, 0, "BOTPLAY", 42);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		botplayTxt.x = 5;
		botplayTxt.y = FlxG.height - (botplayTxt.height + 5);
		botplayTxt.borderQuality = 2;
		botplayTxt.borderSize = 2;
		botplayTxt.visible = false;
		if (Replay.isReplay)
			botplayTxt.text = 'REPLAY MODE';
		add(botplayTxt);

		timerText = new FlxText(0, 0, 0, "0:00", 24);
		timerText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		timerText.screenCenter(X);
		if (!downscroll)
			timerText.y = 3;
		else
			timerText.y = FlxG.height - (24 + 3);
		timerText.borderQuality = 1;
		timerText.borderSize = 1;
		timerText.visible = FlxG.save.data.songTimer;
		add(timerText);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		if (!isMultiplayer)
			add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		if (!isMultiplayer)
			add(iconP2);

		if (downscroll)
			scoreTxt.y = healthBar.y + (iconP1.y + iconP1.height / 2.2);

		// oaoaoaoa multiplayer shit aaaa

		player0Info = new FlxText(0, 5, 0, 'Score: ${songScore}\n${truncateFloat(accuracy, 2)}%\n', 24);
		player0Info.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		player0Info.x = FlxG.width - (player0Info.width + 5);
		if (isMultiplayer)
			add(player0Info);

		player1Info = new FlxText(0, 5, 0, 'Score: ${opponentScore}\n${truncateFloat(opponentAccuracy, 2)}%\n', 24);
		player1Info.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		player1Info.x = 5;
		if (isMultiplayer)
			add(player1Info);

		waitingForPlayerText = new Alphabet(0, 0, 'Waiting for your opponent', true, false);
		waitingForPlayerText.screenCenter();
		if (isMultiplayer)
			add(waitingForPlayerText);

		grpNoteSplashes.cameras = [camHUD];
		timerText.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		player0Info.cameras = [camHUD];
		player1Info.cameras = [camHUD];
		waitingForPlayerText.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				case 'ugh':
					ughIntro();
				case 'guns':
					gunsIntro();
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					if (!isMultiplayer)
						startCountdown();
					else if (isMultiplayer)
						readyToPlay();
			}
		}

		super.create();

		startNPSTimer();
	}

	function readyToPlay() // cool thing, really
	{
		isYouReady = true;
		SessionData._session.send({verb: 'opponent-ready-playstate'});
	}

	function ughIntro()
	{
		inCutscene = true;

		FlxG.sound.playMusic(Paths.music('DISTORTO'), 0);
		FlxG.sound.music.fadeIn(5, 0, 0.5);

		camFollow.setPosition(camPos.x, camPos.y);

		dad.visible = false;
		var tankCutscene:TankCutscene = new TankCutscene(-20, 320);
		tankCutscene.frames = Paths.getSparrowAtlas('cutsceneStuff/tankTalkSong1');
		tankCutscene.animation.addByPrefix('wellWell', 'TANK TALK 1 P1', 24, false);
		tankCutscene.animation.addByPrefix('killYou', 'TANK TALK 1 P2', 24, false);
		tankCutscene.animation.play('wellWell');
		tankCutscene.antialiasing = true;
		gfCutsceneLayer.add(tankCutscene);

		camHUD.visible = false;

		FlxG.camera.zoom *= 1.2;
		camFollow.x = 436.5;
		camFollow.y = 534.5;

		tankCutscene.startSyncAudio = FlxG.sound.load(Paths.sound('wellWellWell'));

		new FlxTimer().start(3, function(tmr:FlxTimer)
		{
			camFollow.x += 700;
			camFollow.y += 90;
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 0.27, {ease: FlxEase.quadInOut});

			new FlxTimer().start(1.5, function(bep:FlxTimer)
			{
				boyfriend.playAnim('singUP');
				// play sound
				FlxG.sound.play(Paths.sound('bfBeep'), function()
				{
					boyfriend.playAnim('idle');
				});
			});

			new FlxTimer().start(3, function(swaggy:FlxTimer)
			{
				camFollow.x = 436.5;
				camFollow.y = 534.5;
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 0.5, {ease: FlxEase.quadInOut});
				tankCutscene.animation.play('killYou');
				FlxG.sound.play(Paths.sound('killYou'));
				new FlxTimer().start(6.1, function(swagasdga:FlxTimer)
				{
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, (Conductor.crochet / 1000) * 5, {ease: FlxEase.quadInOut});

					FlxG.sound.music.fadeOut((Conductor.crochet / 1000) * 5, 0);

					new FlxTimer().start((Conductor.crochet / 1000) * 5, function(money:FlxTimer)
					{
						dad.visible = true;
						gfCutsceneLayer.remove(tankCutscene);
					});

					startCountdown();
					camHUD.visible = true;
				});
			});
		});
	}

	function gunsIntro()
	{
		inCutscene = true;

		camFollow.setPosition(camPos.x, camPos.y);

		camHUD.visible = false;

		FlxG.sound.playMusic(Paths.music('DISTORTO'), 0);
		FlxG.sound.music.fadeIn(5, 0, 0.5);

		camFollow.y += 100;

		FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.3}, 4, {ease: FlxEase.quadInOut});

		dad.visible = false;
		var tankCutscene:TankCutscene = new TankCutscene(20, 320);
		tankCutscene.frames = Paths.getSparrowAtlas('cutsceneStuff/tankTalkSong2');
		tankCutscene.animation.addByPrefix('tankyguy', 'TANK TALK 2', 24, false);
		tankCutscene.animation.play('tankyguy');
		tankCutscene.antialiasing = true;
		gfCutsceneLayer.add(tankCutscene);

		tankCutscene.startSyncAudio = FlxG.sound.load(Paths.sound('tankSong2'));

		new FlxTimer().start(4.1, function(ugly:FlxTimer)
		{
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.4}, 0.4, {ease: FlxEase.quadOut});
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.3}, 0.7, {ease: FlxEase.quadInOut, startDelay: 0.45});

			gf.playAnim('sad');
		});

		new FlxTimer().start(11, function(tmr:FlxTimer)
		{
			FlxG.sound.music.fadeOut((Conductor.crochet / 1000) * 5, 0);

			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, (Conductor.crochet * 5) / 1000, {ease: FlxEase.quartIn});
			startCountdown();
			new FlxTimer().start((Conductor.crochet * 25) / 1000, function(daTim:FlxTimer)
			{
			});

			dad.visible = true;
			gfCutsceneLayer.remove(tankCutscene);
			camHUD.visible = true;
		});
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	private var ctrTime:Float = 0;

	function generateKeyBindsText()
	{
		for (i in 0...mania)
		{
			var keybindText:FlxText = new FlxText(0, 0, 0, splitString(controlsFromSave[i]), 32);
			keybindText.x = playerStrums.members[i].x + ((playerStrums.members[i].width / 2) - (keybindText.width / 2));
			keybindText.y = playerStrums.members[i].y - (4 + playerStrums.members[i].height / 1.25);
			keybindText.alpha = 0;
			keybindText.scrollFactor.set();

			var keybindTextShadow:FlxText = new FlxText(0, 0, 0, splitString(controlsFromSave[i]), 32);
			keybindTextShadow.x = keybindText.x + 4;
			keybindTextShadow.y = keybindText.y + 4;
			keybindTextShadow.alpha = 0;
			keybindTextShadow.color = FlxColor.BLACK;
			keybindTextShadow.scrollFactor.set();

			add(keybindTextShadow);
			add(keybindText);

			keybindTextShadow.cameras = [camHUD];
			keybindText.cameras = [camHUD];

			FlxTween.tween(keybindText, {alpha: 1}, 0.5);
			FlxTween.tween(keybindTextShadow, {alpha: 1}, 0.5);

			new FlxTimer().start(2.5, function(tmr:FlxTimer)
			{
				FlxTween.tween(keybindText, {alpha: 0}, 0.5);
				FlxTween.tween(keybindTextShadow, {alpha: 0}, 0.5);
			});
		}
	}

	function splitString(str:String)
	{
		var stringArray:Array<String> = [];
		var s = ~//g;

		stringArray = s.split(str);

		var extStr:String = '';

		for (i in 0...stringArray.length)
		{
			extStr += '${stringArray[i]}\n';
		}

		return (extStr);
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;

		// Preload music
		FlxG.sound.playMusic(Sound.fromFile(Paths.inst(PlayState.SONG.song)), 1, false);
		FlxG.sound.music.pause();

		generateStaticArrows(0);
		generateStaticArrows(1);

		isArrowsGenerated = true;

		var val:Float = 0.0;

		for (i in 0...mania)
		{
			val += Note.swagWidth;
		}

		laneunderlay.scale.set(Std.int(val), FlxG.height * 2);
		laneunderlayOpponent.scale.set(Std.int(val), FlxG.height * 2);
		laneunderlay.updateHitbox();
		laneunderlayOpponent.updateHitbox();

		laneunderlay.x = playerStrums.members[0].x;
		laneunderlayOpponent.x = opponentStrums.members[0].x;

		laneunderlay.screenCenter(Y);
		laneunderlayOpponent.screenCenter(Y);

		generateKeyBindsText();

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Std.int(Conductor.crochet * 5);

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.music.play(true);
		FlxG.sound.music.volume = 1;
		FlxG.sound.music.onComplete = endSong;
		vocals.play(true);

		#if desktop
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
		#end
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % mania);
				if (FreeplayState.isRandomNotes)
					daNoteData = Std.int(noteRandomizer(daNoteData) % mania);

				var gottaHitNote:Bool = section.mustHitSection;

				var middlescrollOffsetX:Float = Note.swagWidth * daNoteData;
				if (songNotes[1] > mania - 1)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, songNotes[3]);
				swagNote.sustainLength = songNotes[2];
				swagNote.noteType = songNotes[3];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote,
						songNotes[3], true);
					sustainNote.scrollFactor.set();
					sustainNote.noteType = songNotes[3];
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;
				}

				swagNote.mustPress = gottaHitNote;
			}
		}
		daBeats += 1;

		// trace(unspawnNotes.length);
		// playerCounter += 1;
		unspawnNotes.sort(sortByShit);
		generatedMusic = true;
	}

	function noteRandomizer(jsonNoteData:Int)
	{
		var noteData:Int = 0;
		var idk:Bool = false;

		if (jsonNoteData <= keyCountJson - 1)
			idk = true;

		if (idk)
			noteData = FlxG.random.int(0, keyCountJson - 1);
		else
			noteData = FlxG.random.int(keyCountJson, mania - 1);

		return (noteData);
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...mania)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, 0);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [11]);
					babyArrow.animation.add('red', [12]);
					babyArrow.animation.add('blue', [10]);
					babyArrow.animation.add('purplel', [9]);

					babyArrow.animation.add('white', [13]);
					babyArrow.animation.add('yellow', [14]);
					babyArrow.animation.add('violet', [15]);
					babyArrow.animation.add('black', [16]);
					babyArrow.animation.add('darkred', [16]);
					babyArrow.animation.add('orange', [16]);
					babyArrow.animation.add('dark', [17]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom * Note.pixelnoteScale));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					// big thanks to TheZoroForce240
					var numstatic:Array<Int> = [0, 1, 2, 3, 4, 5, 6, 7, 8];
					var startpress:Array<Int> = [9, 10, 11, 12, 13, 14, 15, 16, 17];
					var endpress:Array<Int> = [18, 19, 20, 21, 22, 23, 24, 25, 26];
					var startconf:Array<Int> = [27, 28, 29, 30, 31, 32, 33, 34, 35];
					var endconf:Array<Int> = [36, 37, 38, 39, 40, 41, 42, 43, 44];

					switch (mania)
					{
						case 1:
							numstatic = [4];
							startpress = [13];
							endpress = [22];
							startconf = [31];
							endconf = [40];
						case 2:
							numstatic = [0, 3];
							startpress = [9, 12];
							endpress = [18, 21];
							startconf = [27, 30];
							endconf = [36, 39];
						case 3:
							numstatic = [0, 4, 3];
							startpress = [9, 13, 12];
							endpress = [18, 22, 21];
							startconf = [27, 31, 30];
							endconf = [36, 40, 39];
						case 4:
							numstatic = [0, 1, 2, 3];
							startpress = [9, 10, 11, 12];
							endpress = [18, 19, 20, 21];
							startconf = [27, 28, 29, 30];
							endconf = [36, 37, 38, 39];
						case 5:
							numstatic = [0, 1, 4, 2, 3];
							startpress = [9, 10, 13, 11, 12];
							endpress = [18, 19, 22, 20, 21];
							startconf = [27, 28, 31, 29, 30];
							endconf = [36, 37, 40, 38, 39];
						case 6:
							numstatic = [0, 2, 3, 5, 1, 8];
							startpress = [9, 11, 12, 14, 10, 17];
							endpress = [18, 20, 21, 23, 19, 26];
							startconf = [27, 29, 30, 32, 28, 35];
							endconf = [36, 38, 39, 41, 37, 44];
						case 7:
							numstatic = [0, 2, 3, 4, 5, 1, 8];
							startpress = [9, 11, 12, 13, 14, 10, 17];
							endpress = [18, 20, 21, 22, 23, 19, 26];
							startconf = [27, 29, 30, 31, 32, 28, 35];
							endconf = [36, 38, 39, 40, 41, 37, 44];
						case 8:
							numstatic = [0, 1, 2, 3, 5, 6, 7, 8];
							startpress = [9, 10, 11, 12, 14, 15, 16, 17];
							endpress = [18, 19, 20, 21, 23, 24, 25, 26];
							startconf = [27, 28, 29, 30, 32, 33, 34, 35];
							endconf = [36, 37, 38, 39, 41, 42, 43, 44];
						case 9:
							numstatic = [0, 1, 2, 3, 4, 5, 6, 7, 8];
							startpress = [9, 10, 11, 12, 13, 14, 15, 16, 17];
							endpress = [18, 19, 20, 21, 22, 23, 24, 25, 26];
							startconf = [27, 28, 29, 30, 31, 32, 33, 34, 35];
							endconf = [36, 37, 38, 39, 40, 41, 42, 43, 44];
					}
					babyArrow.animation.add('static', [numstatic[i]]);
					babyArrow.animation.add('pressed', [startpress[i], endpress[i]], 12, false);
					babyArrow.animation.add('confirm', [startconf[i], endconf[i]], 24, false);

				default:
					babyArrow.frames = Paths.getSparrowAtlas('Arrows');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * Note.noteScale));

					var nSuf:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
					var pPre:Array<String> = ['left', 'down', 'up', 'right'];
					switch (mania)
					{
						case 1:
							nSuf = ['SPACE'];
							pPre = ['white'];
						case 2:
							nSuf = ['LEFT', 'RIGHT'];
							pPre = ['left', 'right'];
						case 3:
							nSuf = ['LEFT', 'SPACE', 'RIGHT'];
							pPre = ['left', 'white', 'right'];
						case 4:
							nSuf = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
							pPre = ['left', 'down', 'up', 'right'];
						case 5:
							nSuf = ['LEFT', 'DOWN', 'SPACE', 'UP', 'RIGHT'];
							pPre = ['left', 'down', 'white', 'up', 'right'];
						case 6:
							nSuf = ['LEFT', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'RIGHT'];
							pPre = ['left', 'up', 'right', 'yel', 'down', 'dark'];
						case 7:
							nSuf = ['LEFT', 'UP', 'RIGHT', 'SPACE', 'LEFT', 'DOWN', 'RIGHT'];
							pPre = ['left', 'up', 'right', 'white', 'yel', 'down', 'dark'];
						case 8:
							nSuf = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
							pPre = ['left', 'down', 'up', 'right', 'yel', 'violet', 'black', 'dark'];
						case 9:
							nSuf = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'SPACE', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
							pPre = ['left', 'down', 'up', 'right', 'white', 'yel', 'violet', 'black', 'dark'];
					}
					babyArrow.animation.addByPrefix('static', 'arrow' + nSuf[i]);
					babyArrow.animation.addByPrefix('pressed', pPre[i] + ' press', 24, false);
					babyArrow.animation.addByPrefix('confirm', pPre[i] + ' confirm', 24, false);
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (downscroll)
				babyArrow.y = FlxG.height - (laneOffset + babyArrow.height);
			else
				babyArrow.y = laneOffset;

			/*
				// This shit make my eyes hurt
				if (!isStoryMode)
				{
					babyArrow.y -= 10;
					babyArrow.alpha = 0;
					FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
				}
			 */

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					opponentStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			if (middlescroll && player == 0)
				babyArrow.x = -100000;

			babyArrow.animation.play('static');
			if (middlescroll && player == 1)
			{
				babyArrow.x = (FlxG.width / 2) - (Note.swagWidth * mania / 2);
			}
			if (!middlescroll)
			{
				switch (player)
				{
					case 0:
						babyArrow.x = Note.swagWidth - Note.swagWidth / 2.5;
					case 1:
						babyArrow.x = (FlxG.width - Note.swagWidth * (mania + 1)) + Note.swagWidth / 2.5;
				}
			}
			babyArrow.x += Note.swagWidth * i;

			opponentStrums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets();
			});

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = Std.int(FlxG.sound.music.time);
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	function startNPSTimer()
	{
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			nps = 0;
			startNPSTimer();
		});
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		if (isMultiplayer)
			vocals.volume = 1;

		accuracy = truncateFloat(Ratings.calculateAccuracy(daRatings, misses, totalNotesHit), 2);
		if (accuracy < 0)
			accuracy = 100;

		if (isMultiplayer)
		{
			if (isYouReady && isOpponentReady)
			{
				remove(waitingForPlayerText);
				startCountdown();
				isYouReady = false;
				isOpponentReady = false;
			}
		}

		if (isMultiplayer && isArrowsGenerated)
		{
			SessionData._session.send({verb: "opponent-score-change", accuracy: accuracy, score: songScore});
			SessionData._session.send({verb: "opponent-juds-change", daRatings: daRatings, misses: misses});
			if (yourPlayerID == 1)
				SessionData._session.send({verb: "opponent-char-anim", name: dad.animation.curAnim.name});
			if (yourPlayerID == 0)
				SessionData._session.send({verb: "opponent-char-anim", name: boyfriend.animation.curAnim.name});
			if (yourPlayerID == 0)
			{
				var arrayLmao:Array<String> = [];
				for (i in 0...playerStrums.length)
				{
					arrayLmao.push(playerStrums.members[i].animation.curAnim.name);
				}
				SessionData._session.send({verb: "opponent-arrows-anim", anims: arrayLmao});
				for (i in 0...opponentStrums.length)
				{
					if (opponentStrums.members[i].animation.curAnim.name != opponentArrowsAnimations[i])
						opponentStrums.members[i].animation.play(opponentArrowsAnimations[i], true);
				}
			}
			else if (yourPlayerID == 1)
			{
				var arrayLmao:Array<String> = [];
				for (i in 0...opponentStrums.length)
				{
					arrayLmao.push(opponentStrums.members[i].animation.curAnim.name);
				}
				SessionData._session.send({verb: "opponent-arrows-anim", anims: arrayLmao});
				for (i in 0...playerStrums.length)
				{
					if (playerStrums.members[i].animation.curAnim.name != opponentArrowsAnimations[i])
						playerStrums.members[i].animation.play(opponentArrowsAnimations[i], true);
				}
			}

			opponentStrums.forEach(function(spr:FlxSprite)
			{
				if (spr.animation.curAnim.name != 'confirm' || curStage.startsWith('school'))
					spr.centerOffsets();
				else
				{
					spr.centerOffsets();
					spr.offset.x -= 7.8 / Note.noteScale;
					spr.offset.y -= 7.8 / Note.noteScale;
				}
			});

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (spr.animation.curAnim.name != 'confirm' || curStage.startsWith('school'))
					spr.centerOffsets();
				else
				{
					spr.centerOffsets();
					spr.offset.x -= 7.8 / Note.noteScale;
					spr.offset.y -= 7.8 / Note.noteScale;
				}
			});

			if (yourPlayerID == 0)
			{
				if (dad.animation.curAnim.name != opponentCharAnim)
					dad.playAnim(opponentCharAnim, true);
			}
			if (yourPlayerID == 1)
			{
				if (boyfriend.animation.curAnim.name != opponentCharAnim)
					boyfriend.playAnim(opponentCharAnim, true);
			}

			if (yourPlayerID == 0)
				player0Info.text = 'Score: ${songScore}\n${truncateFloat(accuracy, 2)}%\n';
			if (yourPlayerID == 1)
				player0Info.text = 'Score: ${opponentScore}\n${truncateFloat(opponentAccuracy, 2)}%\n';
			player0Info.x = FlxG.width - (player0Info.width + 5);

			if (yourPlayerID == 1)
				player1Info.text = 'Score: ${songScore}\n${truncateFloat(accuracy, 2)}%\n';
			if (yourPlayerID == 0)
				player1Info.text = 'Score: ${opponentScore}\n${truncateFloat(opponentAccuracy, 2)}%\n';
			player1Info.x = 5;

			if (yourPlayerID == 1)
				opponentJudgementCounter.text = 'Marvelous: ${daRatings[0]}\nSicks: ${daRatings[1]}\nGoods: ${daRatings[2]}\nBads: ${daRatings[3]}\nShits: ${daRatings[4]}\nMisses: ${misses}\n';
			if (yourPlayerID == 0)
				opponentJudgementCounter.text = 'Marvelous: ${opponentDaRatings[0]}\nSicks: ${opponentDaRatings[1]}\nGoods: ${opponentDaRatings[2]}\nBads: ${opponentDaRatings[3]}\nShits: ${opponentDaRatings[4]}\nMisses: ${opponentMisses}\n';
			opponentJudgementCounter.x = 20;
		}

		if (botplay || Replay.isReplay || FreeplayState.isRandomNotes)
			unrankedGame = true;

		if (yourPlayerID == 0)
			judgementCounter.text = 'Marvelous: ${daRatings[0]}\nSicks: ${daRatings[1]}\nGoods: ${daRatings[2]}\nBads: ${daRatings[3]}\nShits: ${daRatings[4]}\nMisses: ${misses}\n';
		if (yourPlayerID == 1)
			judgementCounter.text = 'Marvelous: ${opponentDaRatings[0]}\nSicks: ${opponentDaRatings[1]}\nGoods: ${opponentDaRatings[2]}\nBads: ${opponentDaRatings[3]}\nShits: ${opponentDaRatings[4]}\nMisses: ${opponentMisses}\n';

		if (!isMultiplayer)
		{
			judgementCounter.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			judgementCounter.borderSize = 2;
			judgementCounter.borderQuality = 2;
		}
		else if (isMultiplayer)
		{
			judgementCounter.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			judgementCounter.x = FlxG.width - (judgementCounter.width + 20);
			judgementCounter.borderSize = 2;
			judgementCounter.borderQuality = 2;
		}

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
			// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
			case 'tank':
				moveTank();
		}

		super.update(elapsed);

		if (botplay || Replay.isReplay)
			botplayTxt.visible = true;

		if (nps > npsMax)
			npsMax = nps;

		scoreTxt.text = 'Score: $songScore // Misses: $misses // Accuracy: ${truncateFloat(accuracy, 2)}% // Rating: ${Ratings.getRating(accuracy)} // NPS: $nps (Max: $npsMax)';
		scoreTxt.screenCenter(X);

		if ((FlxG.keys.justPressed.ENTER && startedCountdown && canPause) && !isMultiplayer)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if desktop
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (FlxG.keys.justPressed.SEVEN && !isMultiplayer)
		{
			FlxG.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += Std.int(FlxG.elapsed * 1000);
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += Std.int(FlxG.elapsed * 1000);

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				switch (dad.curCharacter)
				{
					case 'mom':
						camFollow.y = dad.getMidpoint().y;
					case 'senpai':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
					case 'senpai-angry':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
				}

				if (dad.curCharacter == 'mom')
					vocals.volume = 1;

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					tweenCamIn();
				}
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

				switch (curStage)
				{
					case 'limo':
						camFollow.x = boyfriend.getMidpoint().x - 300;
					case 'mall':
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'school':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'schoolEvil':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
				}

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		// better streaming of shit

		if (health <= 0 && !isMultiplayer)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if desktop
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				if ((!daNote.mustPress && daNote.wasGoodHit) && !isMultiplayer)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					var sDir:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
					switch (mania)
					{
						case 1:
							sDir = ['UP'];
						case 2:
							sDir = ['LEFT', 'RIGHT'];
						case 3:
							sDir = ['LEFT', 'UP', 'RIGHT'];
						case 4:
							sDir = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
						case 5:
							sDir = ['LEFT', 'DOWN', 'UP', 'UP', 'RIGHT'];
						case 6:
							sDir = ['LEFT', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'RIGHT'];
						case 7:
							sDir = ['LEFT', 'UP', 'RIGHT', 'UP', 'LEFT', 'DOWN', 'RIGHT'];
						case 8:
							sDir = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
						case 9:
							sDir = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'UP', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
					}
					dad.playAnim('sing' + sDir[daNote.noteData], true);

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					// Opponent laight strums
					opponentStrums.forEach(function(spr:FlxSprite)
					{
						if (daNote.noteData == spr.ID && daNote.shouldBePressed)
						{
							spr.animation.play('confirm', true);
						}
						if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
						{
							spr.centerOffsets();
							spr.offset.x -= 7.8 / Note.noteScale;
							spr.offset.y -= 7.8 / Note.noteScale;
						}
						else
							spr.centerOffsets();
					});

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				var strumLineY:Float = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y;

				var center = strumLineY + (Note.swagWidth / 2);

				if (FlxG.save.data.scrollSpeed <= 1)
					currentSongSpeed = SONG.speed;
				else
					currentSongSpeed = FlxG.save.data.scrollSpeed;

				if (downscroll)
					daNote.y = (strumLineY - ((Conductor.songPosition - daNote.strumTime)) * (-0.45 * FlxMath.roundDecimal(currentSongSpeed, 2)));
				else
					daNote.y = (strumLineY - ((Conductor.songPosition - daNote.strumTime)) * (0.45 * FlxMath.roundDecimal(currentSongSpeed, 2)));

				if (botplay)
				{
					if (daNote.y < strumLineY && !downscroll && daNote.mustPress || daNote.y > strumLineY && downscroll && daNote.mustPress)
					{
						// Do goodNoteHit() without pressed note
						if (daNote.shouldBePressed)
							goodNoteHit(daNote, 0);

						// Player light strums when bot
						if (botplay && daNote.shouldBePressed)
						{
							playerStrums.forEach(function(spr:FlxSprite)
							{
								if (daNote.noteData == spr.ID)
								{
									spr.animation.play('confirm', true);
								}
								if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
								{
									spr.centerOffsets();
									spr.offset.x -= 7.8 / Note.noteScale;
									spr.offset.y -= 7.8 / Note.noteScale;
								}
								else
									spr.centerOffsets();
							});
						}

						if (daNote.shouldBePressed)
						{
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();

							daNote.active = false;
							daNote.visible = false;
						}
						else if ((daNote.y < -daNote.height && !downscroll || daNote.y >= strumLineY + 106 && downscroll)
							&& daNote.mustPress)
						{
							if (daNote.isSustainNote && daNote.wasGoodHit)
							{
								daNote.kill();
								notes.remove(daNote, true);
								daNote.destroy();
							}

							daNote.active = false;
							daNote.visible = false;

							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
					}
				}
				else
				{
					if (((daNote.y < -daNote.height && !downscroll || daNote.y >= strumLineY + 106 && downscroll) && daNote.mustPress)
						&& yourPlayerID == 0)
					{
						if (daNote.isSustainNote && daNote.wasGoodHit)
						{
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
						else
						{
							if (daNote.shouldBePressed)
								health -= 0.075;
							if (!isMultiplayer)
								vocals.volume = 0;
							noteMiss(daNote);
						}

						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
					if (((daNote.y < -daNote.height && !downscroll || daNote.y >= strumLineY + 106 && downscroll) && !daNote.mustPress)
						&& yourPlayerID == 1)
					{
						if (daNote.isSustainNote && daNote.wasGoodHit)
						{
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
						else
						{
							if (daNote.shouldBePressed)
								health -= 0.075;
							if (!isMultiplayer)
								vocals.volume = 0;
							noteMiss(daNote);
						}

						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				}
				if (isArrowsGenerated)
				{
					if (daNote.mustPress)
						daNote.x = playerStrums.members[daNote.noteData].x;
					if (!daNote.mustPress)
						daNote.x = opponentStrums.members[daNote.noteData].x;

					daNote.x += (Note.swagWidth / 2) - (daNote.width / 2);

					if (daNote.isSustainNote)
					{
						if (downscroll)
						{
							try {
								if (daNote.animation.curAnim.name.endsWith('holdend'))
									daNote.y += daNote.prevNote.height - daNote.height;
							} catch(e)
							{
								// anti-crash lol
								// I know, this is really dumb system but this works
							}
	
							if (isMultiplayer)
							{
								if (daNote.y > opponentStrums.members[daNote.noteData].y + opponentStrums.members[daNote.noteData].height * 2)
									daNote.visible = false;
							}
							else
							{
								if (daNote.y > opponentStrums.members[daNote.noteData].y + opponentStrums.members[daNote.noteData].height * 2 && !daNote.mustPress)
									daNote.visible = false;
							}
						}
						else
						{
							if (isMultiplayer)
								{
									if (daNote.y < opponentStrums.members[daNote.noteData].y - opponentStrums.members[daNote.noteData].height * 2)
										daNote.visible = false;
								}
								else
								{
									if (daNote.y < opponentStrums.members[daNote.noteData].y - opponentStrums.members[daNote.noteData].height * 2 && !daNote.mustPress)
										daNote.visible = false;
								}
						}
					}
				}
			});

			if (!isMultiplayer)
			{
				opponentStrums.forEach(function(spr:FlxSprite)
				{
					if (spr.animation.finished)
					{
						spr.animation.play('static');
						spr.centerOffsets();
					}
				});
			}

			// Player light strums when bot
			if (botplay)
			{
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (spr.animation.finished)
					{
						spr.animation.play('static');
						spr.centerOffsets();
					}
				});
			}
		}

		timerText.text = FlxStringUtil.formatTime((FlxG.sound.music.length - FlxG.sound.music.time) / 1000);
		timerText.screenCenter(X);

		if (!inCutscene)
			inputMehanics();

		if (FlxG.keys.justPressed.ONE)
			endSong();
	}

	function endSong():Void
	{
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;

		if (!FreeplayState.isRandomNotes || !isMultiplayer)
			Replay.saveReplay(true);

		if ((SONG.validScore && !unrankedGame) && !isMultiplayer)
		{
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
		}

		if (isMultiplayer)
		{
			var status:String = 'what';
			if (songScore > opponentScore)
				status = 'You win';
			if (songScore < opponentScore)
				status = 'You lose';
			if (songScore == opponentScore)
				status = 'Tie';
			notes.visible = false; // 6:54 AM lol
			openSubState(new MultiplayerResultsSubstate(status));
		}
		else if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				FlxG.switchState(new StoryMenuState());

				// if ()
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore && !unrankedGame)
				{
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				LoadingState.loadAndSwitchState(new PlayState());
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;

	var notePressDelay:FlxText = null;

	private function popUpScore(note:Note, replayPressed:Float):Void
	{
		var noteDiff:Float = 0;
		noteDiff = Math.abs(note.strumTime - Conductor.songPosition);
		if (botplay)
			noteDiff = 0;

		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 320;

		var daRating:String = "marvelous";

		if (noteDiff <= Ratings.juds[0])
		{
			daRatings[0]++;
		}
		else if (noteDiff <= Ratings.juds[1])
		{
			daRating = 'sick';
			score = 300;
			daRatings[1]++;
		}
		else if (noteDiff <= Ratings.juds[2])
		{
			daRating = 'good';
			score = 200;
			daRatings[2]++;
		}
		else if (noteDiff <= Ratings.juds[3])
		{
			daRating = 'bad';
			score = 100;
			daRatings[3]++;
		}
		else if (noteDiff <= Ratings.juds[4])
		{
			daRating = 'shit';
			score = 100;
			daRatings[4]++;
		}

		totalNotesHit += 1;

		if (daRating == 'sick' || daRating == 'marvelous')
		{
			var noteSplash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
			if (yourPlayerID == 0)
				noteSplash.setupNoteSplash(playerStrums.members[note.noteData].x, playerStrums.members[note.noteData].y, note.noteData, note.width, note.noteType);
			if (yourPlayerID == 1)
				noteSplash.setupNoteSplash(opponentStrums.members[note.noteData].x, opponentStrums.members[note.noteData].y, note.noteData, note.width, note.noteType);
			grpNoteSplashes.add(noteSplash);
		}

		songScore += score;

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		if (notePressDelay != null)
			remove(notePressDelay);

		notePressDelay = new FlxText(0, 0, 0, "0ms");
		notePressDelay.color = FlxColor.CYAN;
		notePressDelay.borderStyle = OUTLINE;
		notePressDelay.borderSize = 1;
		notePressDelay.borderColor = FlxColor.BLACK;
		notePressDelay.text = truncateFloat(noteDiff, 2) + 'ms';
		notePressDelay.size = 20;
		notePressDelay.alpha = 1;
		notePressDelay.screenCenter();
		notePressDelay.x = comboSpr.x + 100;
		notePressDelay.y = rating.y + 100;
		notePressDelay.acceleration.y = 600;
		notePressDelay.velocity.y -= 150;
		notePressDelay.velocity.x += comboSpr.velocity.x;
		notePressDelay.updateHitbox();
		add(notePressDelay);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		var comboSplit:Array<String> = (combo + "").split('');

		if (combo > highestCombo)
			highestCombo = combo;

		if (comboSplit.length == 1)
		{
			seperatedScore.push(0);
			seperatedScore.push(0);
		}
		else if (comboSplit.length == 2)
			seperatedScore.push(0);

		for (i in 0...comboSplit.length)
		{
			var str:String = comboSplit[i];
			seperatedScore.push(Std.parseInt(str));
		}

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = rating.x + (43 * daLoop) - 50;
			numScore.y = rating.y + 100;

			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(notePressDelay, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001,
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	private function onEvent(eventName:String, ?params:Array<Dynamic>)
	{
		trace('Trying to call event with name: ' + eventName);

		switch (eventName)
		{
			case 'change-dad':
				remove(dad);
				dad = new Character(100, 100, params[0], 'dad');
				add(dad);
				iconP2.animation.play(params[0]);
				healthBar.createFilledBar(dad.barColor, boyfriend.barColor);
				health += 0.000001; // idk why, but color does not changing without it
			case 'change-bf':
				remove(boyfriend);
				boyfriend = new Boyfriend(770, 450, params[0], 'bf');
				add(boyfriend);
				iconP1.animation.play(params[0]);
				healthBar.createFilledBar(dad.barColor, boyfriend.barColor);
				health += 0.000001; // idk why, but color does not changing without it
			case 'change-gf':
				remove(gf);
				gf = new Character(400, 130, params[0], 'gf');
				gf.scrollFactor.set(0.95, 0.95);
				add(gf);
			case 'play-anim':
				switch (Std.string(params[0]).toLowerCase())
				{
					case 'dad':
						dad.playAnim(params[1], true);
					case 'bf':
						boyfriend.playAnim(params[1], true);
					case 'gf':
						gf.playAnim(params[1], true);
				}
			case 'change-hud-alpha':
				FlxTween.tween(camHUD, {alpha: params[0]}, params[1], {ease: FlxEase.quartInOut});
		}
	}

	private function onNotePress(noteType:String)
	{
		switch (noteType)
		{
			case 'death':
				health -= 10;
		}
	}

	private function onNoteMiss(noteType:String)
	{
		switch (noteType)
		{
			case 'blammed':
				health -= 10;
		}
	}

	private function inputMehanics():Void
	{
		var holdingArray:Array<Bool>;
		var controlArray:Array<Bool>;
		if (!Replay.isReplay)
		{
			holdingArray = [];
			controlArray = [];
		}
		else
		{
			holdingArray = Replay.holdingArray;
			controlArray = Replay.controlArray;
		}

		if (!Replay.isReplay)
		{
			if (!botplay)
			{
				for (i in 0...controlsFromSave.length)
				{
					holdingArray.push(FlxG.keys.anyPressed([controlsFromSave[i]]));
					controlArray.push(FlxG.keys.anyJustPressed([controlsFromSave[i]]));
				}
			}
			else
			{
				// Disables all binds when you using botplay
				for (i in 0...mania)
				{
					holdingArray.push(false);
					controlArray.push(false);
				}
			}
		}

		// replay code
		var replayTime:Float = 0;
		var isAnyPressed:Bool = false;

		for (i in 0...controlArray.length)
		{
			if (controlArray[i] || holdingArray[i])
			{
				isAnyPressed = true;
			}
		}
		if (!Replay.isReplay && isAnyPressed)
		{
			currentReplayPresses.push({
				pressed: controlArray,
				holded: holdingArray,
				time: Conductor.songPosition
			});
		}

		if (Replay.isReplay)
		{
			for (curCheck in 0...currentReplayPresses.length)
			{
				if (currentReplayPresses[curCheck].time == Conductor.songPosition)
				{
					holdingArray = currentReplayPresses[curCheck].pressed;
					controlArray = currentReplayPresses[curCheck].holded;

					replayTime = currentReplayPresses[curCheck].time;
				}
			}
		}

		if (holdingArray.contains(true) && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if ((daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdingArray[daNote.noteData]) && yourPlayerID == 0)
					goodNoteHit(daNote, replayTime);
				if ((daNote.isSustainNote && daNote.canBeHit && !daNote.mustPress && holdingArray[daNote.noteData]) && yourPlayerID == 1)
					goodNoteHit(daNote, replayTime);
			});
		}
		if (controlArray.contains(true) && generatedMusic)
		{
			if (yourPlayerID == 0)
				boyfriend.holdTimer = 0;
			if (yourPlayerID == 1)
				dad.holdTimer = 0;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			var removeList:Array<Note> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if ((daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) && yourPlayerID == 0)
				{
					if (ignoreList.contains(daNote.noteData))
					{
						for (possibleNote in possibleNotes)
						{
							if (possibleNote.noteData == daNote.noteData && daNote.strumTime < possibleNote.strumTime)
							{
								possibleNotes.remove(possibleNote);
								possibleNotes.push(daNote);
							}
						}
					}
					else
					{
						possibleNotes.push(daNote);
						ignoreList.push(daNote.noteData);
					}
				}
				if ((daNote.canBeHit && !daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) && yourPlayerID == 1)
				{
					if (ignoreList.contains(daNote.noteData))
					{
						for (possibleNote in possibleNotes)
						{
							if (possibleNote.noteData == daNote.noteData && daNote.strumTime < possibleNote.strumTime)
							{
								possibleNotes.remove(possibleNote);
								possibleNotes.push(daNote);
							}
						}
					}
					else
					{
						possibleNotes.push(daNote);
						ignoreList.push(daNote.noteData);
					}
				}
			});

			for (badNote in removeList)
			{
				badNote.kill();
				notes.remove(badNote, true);
				badNote.destroy();
			}

			possibleNotes.sort(function(note1:Note, note2:Note)
			{
				return Std.int(note1.strumTime - note2.strumTime);
			});

			if (possibleNotes.length > 0)
			{
				for (possibleNote in possibleNotes)
				{
					if (controlArray[possibleNote.noteData])
					{
						goodNoteHit(possibleNote, replayTime);
					}
				}
			}
		}

		var timeHold:Float = 0.004;
		// Makes the animation length longer to make the botplay kinda look plausible
		if (botplay)
			timeHold = 0.020;

		if (yourPlayerID == 0)
		{
			if (boyfriend.holdTimer > timeHold * Conductor.stepCrochet
				&& !holdingArray.contains(true)
				&& boyfriend.animation.curAnim.name.startsWith('sing')
				&& !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.playAnim('idle');
			}

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (!botplay || !Replay.isReplay)
				{
					if (controlArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (!holdingArray[spr.ID])
						spr.animation.play('static');
				}

				if (spr.animation.curAnim.name != 'confirm' || curStage.startsWith('school'))
					spr.centerOffsets();
				else
				{
					spr.centerOffsets();
					spr.offset.x -= 7.8 / Note.noteScale;
					spr.offset.y -= 7.8 / Note.noteScale;
				}
			});
		}
		if (yourPlayerID == 1)
		{
			if (dad.holdTimer > timeHold * Conductor.stepCrochet
				&& !holdingArray.contains(true)
				&& dad.animation.curAnim.name.startsWith('sing')
				&& !dad.animation.curAnim.name.endsWith('miss'))
			{
				dad.playAnim('idle');
			}

			opponentStrums.forEach(function(spr:FlxSprite)
			{
				if (!botplay || !Replay.isReplay)
				{
					if (controlArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (!holdingArray[spr.ID])
						spr.animation.play('static');
				}

				if (spr.animation.curAnim.name != 'confirm' || curStage.startsWith('school'))
					spr.centerOffsets();
				else
				{
					spr.centerOffsets();
					spr.offset.x -= 7.8 / Note.noteScale;
					spr.offset.y -= 7.8 / Note.noteScale;
				}
			});
		}
	}

	function noteMiss(note:Note):Void
	{
		onNoteMiss(note.noteType);
		if (note.shouldBePressed)
		{
			if (!boyfriend.stunned && !note.isSustainNote)
			{
				health -= 0.05;

				if (combo > 10 && gf.animOffsets.exists('sad'))
				{
					gf.playAnim('sad');
				}

				var pixelShitPart1:String = ""; // pixel prefixes
				var pixelShitPart2:String = '';
				var comboBr:FlxSprite = new FlxSprite();

				if (curStage.startsWith('school'))
				{
					pixelShitPart1 = 'weeb/pixelUI/';
					pixelShitPart2 = '-pixel';
				}

				if (songScore >= 10)
					songScore -= 10;

				combo = 0;

				misses++;

				FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

				boyfriend.stunned = true;

				// get stunned for 5 seconds
				new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
				{
					boyfriend.stunned = false;
				});

				if (!isMultiplayer)
				{
					switch (note.noteData)
					{
						case 0:
							boyfriend.playAnim('singLEFTmiss', true);
						case 1:
							boyfriend.playAnim('singDOWNmiss', true);
						case 2:
							boyfriend.playAnim('singUPmiss', true);
						case 3:
							boyfriend.playAnim('singRIGHTmiss', true);
						case 4:
							boyfriend.playAnim('singDOWNmiss', true);
						case 5:
							boyfriend.playAnim('singRIGHTmiss', true);
						case 6:
							boyfriend.playAnim('singDOWNmiss', true);
						case 7:
							boyfriend.playAnim('singUPmiss', true);
						case 8:
							boyfriend.playAnim('singRIGHTmiss', true);
					}
				}
			}
			else if (!boyfriend.stunned && note.isSustainNote)
			{
				combo = 0;
			}
		}
	}

	function goodNoteHit(note:Note, replayTime:Float):Void
	{
		if (!note.wasGoodHit)
		{
			onNotePress(note.noteType);

			if (!note.isSustainNote)
			{
				popUpScore(note, replayTime);
				nps++;
				combo += 1;
			}

			if (note.noteData >= 0)
				health += 0.023;
			else
				health += 0.004;

			var sDir:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
			switch (mania)
			{
				case 1:
					sDir = ['UP'];
				case 2:
					sDir = ['LEFT', 'RIGHT'];
				case 3:
					sDir = ['LEFT', 'UP', 'RIGHT'];
				case 4:
					sDir = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
				case 5:
					sDir = ['LEFT', 'DOWN', 'UP', 'UP', 'RIGHT'];
				case 6:
					sDir = ['LEFT', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'RIGHT'];
				case 7:
					sDir = ['LEFT', 'UP', 'RIGHT', 'UP', 'LEFT', 'DOWN', 'RIGHT'];
				case 8:
					sDir = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
				case 9:
					sDir = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'UP', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
			}
			if (yourPlayerID == 0)
				boyfriend.playAnim('sing' + sDir[note.noteData], true);
			if (yourPlayerID == 1)
				dad.playAnim('sing' + sDir[note.noteData], true);

			if (yourPlayerID == 0)
			{
				if (!botplay || !Replay.isReplay)
				{
					playerStrums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(note.noteData) == spr.ID)
						{
							spr.animation.play('confirm', true);
						}
					});
				}
			}
			if (yourPlayerID == 1)
			{
				if (!botplay || !Replay.isReplay)
				{
					opponentStrums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(note.noteData) == spr.ID)
						{
							spr.animation.play('confirm', true);
						}
					});
				}
			}

			note.wasGoodHit = true;
			vocals.volume = 1;

			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;
	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function moveTank():Void
	{
		if (!inCutscene)
		{
			var daAngleOffset:Float = 1;
			tankAngle += FlxG.elapsed * tankSpeed;
			tankGround.angle = tankAngle - 90 + 15;

			tankGround.x = tankX + Math.cos(FlxAngle.asRadians((tankAngle * daAngleOffset) + 180)) * 1500;
			tankGround.y = 1300 + Math.sin(FlxAngle.asRadians((tankAngle * daAngleOffset) + 180)) * 1100;
		}
	}

	var tankResetShit:Bool = false;
	var tankMoving:Bool = false;
	var tankAngle:Float = FlxG.random.int(-90, 45);
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankX:Float = 400;

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// dad.dance();
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
				dad.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing"))
		{
			boyfriend.playAnim('idle');
		}

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		foregroundSprites.forEach(function(spr:BGSprite)
		{
			spr.dance();
		});

		switch (curStage)
		{
			case 'school':
				bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
					// phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
			case 'tank':
				tankWatchtower.dance();
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	var curLight:Int = 0;
}
