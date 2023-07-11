package;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;

import editors.CharacterEditor;

class DebugState extends MusicBeatSubstate
{
	var listArray:Array<String> = ['Character editor'];
	var grpTxt:FlxTypedGroup<Alphabet>;
	var curSelected:Int = 0;

	public function new()
	{
		super();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.set();
		bg.color = 0xFF464646;
		bg.scale.set(1.1, 1.1);
		add(bg);

		grpTxt = new FlxTypedGroup<Alphabet>();
		add(grpTxt);

		for (i in 0...listArray.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, listArray[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpTxt.add(songText);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var upP = FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP;
		var downP = FlxG.keys.justPressed.S || FlxG.keys.justPressed.DOWN;
		var accepted = FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE;

		if (upP)
		{
            curSelected += -1;

			if (curSelected < 0)
				curSelected = listArray.length - 1;
			if (curSelected >= listArray.length)
				curSelected = 0;

			var bullShit:Int = 0;

			for (item in grpTxt.members)
			{
				item.targetY = bullShit - curSelected;
				bullShit++;

				item.alpha = 0.6;

				if (item.targetY == 0)
				{
					item.alpha = 1;
				}
			}
		}
		if (downP)
		{
			curSelected += 1;

			if (curSelected < 0)
				curSelected = listArray.length - 1;
			if (curSelected >= listArray.length)
				curSelected = 0;

			var bullShit:Int = 0;

			for (item in grpTxt.members)
			{
				item.targetY = bullShit - curSelected;
				bullShit++;

				item.alpha = 0.6;

				if (item.targetY == 0)
				{
					item.alpha = 1;
				}
			}
		}

		if (accepted)
		{
			var daSelected:String = listArray[curSelected];

			switch (daSelected)
			{
				case 'Character editor':
					FlxG.switchState(new CharacterEditor());
			}

			if (FlxG.keys.justPressed.ESCAPE)
			{
				close();
			}
		}
	}
}
