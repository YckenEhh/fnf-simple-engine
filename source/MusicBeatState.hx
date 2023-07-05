package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.FlxG;
import Conductor.BPMChangeEvent;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxMath;
#if sys
import sys.io.File;
import haxe.Json;
#end

import GameJolt;
import GameJolt.GameJoltAPI;

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	override function create()
	{
		if (transIn != null)
			trace('reg ' + transIn.region);

		#if sys
		var toParse:String = File.getContent(Paths.json('transitionData'));
		var _json:TransitionHandler.TransitionJson = cast haxe.Json.parse(toParse);
		TransitionHandler.setTransitionType(_json.id, _json.durationArray);
		#else
		TransitionHandler.setTransitionType(1, [0.7, 1]);
		#end

		super.create();
	}

	override function update(elapsed:Float)
	{
		// everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
	}

	function truncateFloat(number:Float, precision:Int):Float
	{
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		// do literally nothing dumbass
	}
}