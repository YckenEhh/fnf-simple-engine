package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.addons.transition.TransitionData.TransitionType;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;

typedef TransitionJson = 
{
    id:Int,
    durationArray:Array<Float>
}

class TransitionHandler
{
	public static function setTransitionType(id:Int = 1, time:Array<Float>)
	{
		var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
		diamond.persist = true;
		diamond.destroyOnNoUse = false;

		switch (id)
		{
			case 0:
				FlxTransitionableState.defaultTransIn = new TransitionData(NONE, FlxColor.BLACK, time[0], new FlxPoint(0, -1),
					{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
				FlxTransitionableState.defaultTransOut = new TransitionData(NONE, FlxColor.BLACK, time[1], new FlxPoint(0, 1),
					{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			case 1:
				FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, time[0], new FlxPoint(0, -1),
					{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
				FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, time[1], new FlxPoint(0, 1),
					{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			case 2:
				FlxTransitionableState.defaultTransIn = new TransitionData(TILES, FlxColor.BLACK, time[0], new FlxPoint(0, -1),
					{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
				FlxTransitionableState.defaultTransOut = new TransitionData(TILES, FlxColor.BLACK, time[1], new FlxPoint(0, 1),
					{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
		}
	}
}
