package;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.system.FlxSound;
#if desktop
import Discord.DiscordClient;
#end

class CreditsMenuState extends MusicBeatState
{
	private var curSelected:Int = 0;
	private var grpCredits:FlxTypedGroup<Alphabet>;
	private var bg:FlxSprite;
	private var descTxt:FlxText;

	private var bgColors = [0xFFFF3F39, 0xFF633253, 0xFFFFD900, 0xFF65FF29, 0xFF419FF7];

	public static var credit:Array<SaveData> = [
		new SaveData("OldFlag", "Programmer of FNF Simple Engine"),
		new SaveData("ninjamuffin99", "Programmer of Friday Night Funkin'"),
		new SaveData("PhantomArcade", "Animator of Friday Night Funkin'"),
		new SaveData("evilsk8r", "Artist of Friday Night Funkin'"),
		new SaveData("kawaisprite", "Composer of Friday Night Funkin'")
	];

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("In Credits menu", null);
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xffffff;
		add(bg);

		grpCredits = new FlxTypedGroup<Alphabet>();
		add(grpCredits);

		for (i in 0...credit.length)
		{
			var creditText:Alphabet = new Alphabet(0, (70 * i) + 30, credit[i].nm, true, false);
			creditText.isCenterItem = true;
			creditText.targetY = i;
			grpCredits.add(creditText);
		}

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);
		descTxt = new FlxText(textBG.x, textBG.y + 4, FlxG.width, "", 20);
		descTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER);
		descTxt.scrollFactor.set();
		add(descTxt);

		changeSelection();

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		bg.color = FlxColor.interpolate(bg.color, bgColors[curSelected], CoolUtil.camLerp(0.045));
		descTxt.text = credit[curSelected].desc;

		if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP)
		{
			changeSelection(-1);
		}
		if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S)
		{
			changeSelection(1);
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(new MainMenuState());
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpCredits.length - 1;
		if (curSelected >= grpCredits.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpCredits.members)
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
}

class SaveData
{
	public var nm:String;
	public var desc:String;

	public function new(name:String, description:String)
	{
		this.nm = name;
		this.desc = description;
	}
}
