package;

import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxSprite;
import flixel.FlxG;

using StringTools;

class SetKeybindsState extends MusicBeatState
{
	var keybindsArray:Array<String>;
	var textGroup:FlxTypedGroup<FlxText>;

	public static var mania:Int = 4;

	var curSelected:Int = 0;

	override function create()
	{
		keybindsArray = [];

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.visible = true;
		bg.antialiasing = true;
		bg.color = 0xFF58BF;
		add(bg);

		textGroup = new FlxTypedGroup<FlxText>();
		add(textGroup);

		for (i in 0...mania)
		{
			var text:FlxText = new FlxText(0, 0, 0, '_', 32);
			text.screenCenter();
			text.x += text.width * i;
			text.x -= (text.width / mania) * mania;
			textGroup.add(text);
		}

		selectedColor();

		super.create();
	}

	function selectedColor()
	{
		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			if (curSelected < mania)
				textGroup.members[curSelected].alpha = 0;
			new FlxTimer().start(0.3, function(tmr:FlxTimer)
			{
				if (curSelected < mania)
					textGroup.members[curSelected].alpha = 1;
				selectedColor();
			});
		});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (keybindsArray.length == mania)
		{
			switch (mania)
			{
				case 1:
					FlxG.save.data.kb1 = keybindsArray;
				case 2:
					FlxG.save.data.kb2 = keybindsArray;
				case 3:
					FlxG.save.data.kb3 = keybindsArray;
				case 4:
					FlxG.save.data.kb4 = keybindsArray;
				case 5:
					FlxG.save.data.kb5 = keybindsArray;
				case 6:
					FlxG.save.data.kb6 = keybindsArray;
				case 7:
					FlxG.save.data.kb7 = keybindsArray;
				case 8:
					FlxG.save.data.kb8 = keybindsArray;
				case 9:
					FlxG.save.data.kb9 = keybindsArray;
			}
			textGroup.clear();
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.switchState(new ControlsState());
		}
		else
		{
			var keyPressed:Int = FlxG.keys.firstJustPressed();
			if (keyPressed > -1)
			{
				if (curSelected < mania)
				{
					textGroup.members[curSelected].alpha = 1;
					textGroup.members[curSelected].color = 0x00ff00;
				}
				keybindsArray.push(FlxG.keys.getIsDown()[0].ID.toString());
				textGroup.members[curSelected].text = splitString(keybindsArray[curSelected]);
				textGroup.members[curSelected].y -= 32;

				if (curSelected < mania)
					curSelected++;
			}
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
}
