package;

import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	var stageSuffix:String = "";

	var isReplaySaved:Bool = false;
	var replayText:FlxText;
	var randomGameover:Int = 1;

	var playingDeathSound:Bool = false;

	public function new(x:Float, y:Float)
	{
		randomGameover = FlxG.random.int(1, 25);

		var daStage = PlayState.curStage;
		var daBf:String = '';
		switch (daStage)
		{
			case 'school' | 'schoolEvil':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			default:
				daBf = 'bf';
		}

		var daSong = PlayState.SONG.song.toLowerCase();

		switch (daSong)
		{
			case 'stress':
				daBf = 'bf-holding-gf-dead';
		}

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf, 'bf');
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');

		replayText = new FlxText(5, FlxG.height - 20, 0, "Press F1 to save replay", 20);
		replayText.scrollFactor.set();
		replayText.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		if (!FreeplayState.isRandomNotes)
			add(replayText);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE)
		{
			endBullshit();
		}

		if (FlxG.keys.justPressed.F1 && !isReplaySaved){
			if (!FreeplayState.isRandomNotes)
				Replay.saveReplay(false);
			replayText.visible = false;
			isReplaySaved = true;
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				FlxG.switchState(new StoryMenuState());
			else
				FlxG.switchState(new FreeplayState());
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		switch (PlayState.storyWeek)
		{
			case 7:
				if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished && !playingDeathSound)
				{
					playingDeathSound = true;

					coolStartDeath(0.2);

					FlxG.sound.play(Paths.sound('jeffGameover/jeffGameover-' + randomGameover), 1, false, null, true, function()
					{
						if (!isEnding)
							FlxG.sound.music.fadeIn(4, 0.2, 1);
					});
				}
			default:
				if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
				{
					coolStartDeath();
				}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = Std.int(FlxG.sound.music.time);
		}
	}

	private function coolStartDeath(?vol:Float = 1):Void
	{
		if (!isEnding)
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix), vol);
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
