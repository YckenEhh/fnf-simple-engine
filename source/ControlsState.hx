package;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;


class ControlsState extends MusicBeatState
{
	var list:Array<Int> = [1, 2, 3, 4, 5, 6, 7, 8, 9];
	var kbList:Array<Array<String>> = [
		FNFData.kb1,
		FNFData.kb2,
		FNFData.kb3,
		FNFData.kb4,
		FNFData.kb5,
		FNFData.kb6,
		FNFData.kb7,
		FNFData.kb8,
		FNFData.kb9
	];

	public static var curSelected:Int = 0;

	var grpTxt:FlxTypedGroup<Alphabet>;

	var maniaText:FlxText;
	var kbText:FlxText;
	var infoBG:FlxSprite;

	override function create()
	{
		FNFData.loadSave(); // lmao

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.visible = true;
		bg.antialiasing = true;
		bg.color = 0xFF58BF;
		add(bg);

		grpTxt = new FlxTypedGroup<Alphabet>();
		add(grpTxt);

		for (i in 0...list.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, 'Keybinds for ' + list[i] + ' keys', true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpTxt.add(songText);
		}

		maniaText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		maniaText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		kbText = new FlxText(maniaText.x, maniaText.y + 36, 0, "", 24);
		kbText.font = maniaText.font;

		infoBG = new FlxSprite(maniaText.x - 6, 0).makeGraphic(1280, 66, 0xFF000000);
		infoBG.alpha = 0.6;

		add(infoBG);
		add(maniaText);
		add(kbText);

		changeItem(0);

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		FNFData.loadSave();
		kbList = [
			FNFData.kb1,
			FNFData.kb2,
			FNFData.kb3,
			FNFData.kb4,
			FNFData.kb5,
			FNFData.kb6,
			FNFData.kb7,
			FNFData.kb8,
			FNFData.kb9
		];
		updateText();

		var upP = FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP;
		var downP = FlxG.keys.justPressed.S || FlxG.keys.justPressed.DOWN;
		var accepted = FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE;

		if (upP)
		{
			changeItem(-1);
		}
		if (downP)
		{
			changeItem(1);
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.switchState(new OptionsMenuState());
		}

		if (accepted)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			SetKeybindsState.mania = list[curSelected];
			FlxG.switchState(new SetKeybindsState());
		}
	}

	function changeItem(i:Int)
	{
		curSelected += i;

		if (curSelected < 0)
			curSelected = list.length - 1;
		if (curSelected >= list.length)
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

		updateText();
	}

	function updateText()
	{
		// Text
		maniaText.text = 'MANIA: ${list[curSelected]}';
		kbText.text = 'KEYBINDS: ${generateKeyBindsText(kbList[curSelected])}';

		// Positions n' scales
		kbText.x = FlxG.width - (kbText.width);
		maniaText.x = kbText.x;
		infoBG.x = kbText.x;
	}

	function generateKeyBindsText(array:Array<String>)
	{
		var str:String = '';

		for (i in 0...array.length)
		{
			str += array[i] ;
			if (i < array.length - 1)
				str += ' ';
		}

		return(str);
	}
}
