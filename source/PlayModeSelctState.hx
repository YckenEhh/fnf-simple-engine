package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

class PlayModeSelctState extends MusicBeatState
{
	private var curSelected:Int = 0;
	private var types:Array<String> = ['Singleplayer', 'Multiplayer'];
	private var grpTypes:FlxTypedGroup<Alphabet>;

	override function create()
	{
		FlxG.mouse.useSystemCursor = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.visible = true;
		bg.antialiasing = true;
		bg.color = 0xB84FFF;
		add(bg);

		grpTypes = new FlxTypedGroup<Alphabet>();
		add(grpTypes);

		for (i in 0...types.length)
		{
			var typeText:Alphabet = new Alphabet(0, 0, types[i], true, false);
			typeText.isCenterItem = true;
			typeText.screenCenter(Y);
			if (i == 0)
				typeText.y -= typeText.height / 1.5;
			if (i == 1)
				typeText.y += typeText.height / 1.5;
			grpTypes.add(typeText);
		}

		changeSelection(0);

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		grpTypes.members[0].screenCenter(Y);
		grpTypes.members[0].y -= grpTypes.members[0].height / 1.5;
		grpTypes.members[1].screenCenter(Y);
		grpTypes.members[1].y += grpTypes.members[1].height / 1.5;

		if (FlxG.keys.justPressed.ESCAPE)
			FlxG.switchState(new MainMenuState());

		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE)
		{
			switch (grpTypes.members[curSelected].text)
			{
				case 'Singleplayer':
					FlxG.switchState(new FreeplayState());
				case 'Multiplayer':
					FlxG.switchState(new multiplayer.MultiplayerMenuState());
			}
		}

		if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP)
		{
			changeSelection(-1);
		}
		if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S)
		{
			changeSelection(1);
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpTypes.length - 1;
		if (curSelected >= grpTypes.length)
			curSelected = 0;

		var bullShit:Int = 0;

		if (curSelected == 0)
		{
			grpTypes.members[0].alpha = 1;
		}
		else
		{
			grpTypes.members[0].alpha = 0.6;
		}

		if (curSelected == 1)
		{
			grpTypes.members[1].alpha = 1;
		}
		else
		{
			grpTypes.members[1].alpha = 0.6;
		}
	}
}
