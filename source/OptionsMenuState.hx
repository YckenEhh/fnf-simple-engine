package;

import GameJolt.GameJoltLogin;
import openfl.Lib;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import lime.app.Application;

class OptionsMenuState extends MusicBeatState
{
	var selector:FlxText;
	var curSelected:Int = 0;

	var options:Array<OptionCatagory> = [
		new OptionCatagory("Gameplay", [
			new DownscrollOption('lazy'),
			new MiddlescrollOption('lazy'),
			new GhostTappingOption('lazy'),
			new ScrollSpeedOption('lazy'),
			new LaneUnderlayOption('lazy'),
			new JudgmentsOption('lazy')
		]),
		new OptionCatagory("Controls", []),
		new OptionCatagory("Other", [new FpsCapOption('lazy')]),
		new OptionCatagory("GameJolt", [])
	];

	private var currentDescription:String = "";
	private var grpControls:FlxTypedGroup<Alphabet>;

	var bg:FlxSprite;

	var currentSelectedCat:OptionCatagory;
	var isCat:Bool = false;

	override function create()
	{
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat"));

		bg = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.visible = true;
		bg.antialiasing = true;
		bg.color = 0xFF58BF;
		add(bg);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...options.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true, false);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE && !isCat)
			FlxG.switchState(new MainMenuState());
		else if (FlxG.keys.justPressed.ESCAPE)
		{
			isCat = false;
			grpControls.clear();
			for (i in 0...options.length)
			{
				var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true, false);
				controlLabel.isMenuItem = true;
				controlLabel.targetY = i;
				grpControls.add(controlLabel);
				// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			}
			curSelected = 0;
		}
		if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S)
			changeSelection(1);

		if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP)
			changeSelection(-1);

		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE)
		{
			if (isCat)
			{
			}
			else
			{
				if (options[curSelected].getName() == "Controls")
				{
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					FlxG.switchState(new ControlsState());
				}
				else if (options[curSelected].getName() == "GameJolt")
				{
					FlxG.switchState(new GameJoltLogin());
				}
			}
		}

		if (FlxG.keys.justPressed.D || FlxG.keys.justPressed.RIGHT && isCat)
		{
			if (currentSelectedCat.getOptions()[curSelected].right())
			{
				grpControls.remove(grpControls.members[curSelected]);
				var ctrl:Alphabet = new Alphabet(0, (70 * curSelected) + 30, currentSelectedCat.getOptions()[curSelected].getDisplay(), true, false);
				ctrl.isMenuItem = true;
				grpControls.add(ctrl);
			}
		}

		if (FlxG.keys.justPressed.A || FlxG.keys.justPressed.LEFT && isCat)
		{
			if (currentSelectedCat.getOptions()[curSelected].left())
			{
				grpControls.remove(grpControls.members[curSelected]);
				var ctrl:Alphabet = new Alphabet(0, (70 * curSelected) + 30, currentSelectedCat.getOptions()[curSelected].getDisplay(), true, false);
				ctrl.isMenuItem = true;
				grpControls.add(ctrl);
			}
		}

		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE)
		{
			if (isCat)
			{
				if (currentSelectedCat.getOptions()[curSelected].press())
				{
					grpControls.remove(grpControls.members[curSelected]);
					var ctrl:Alphabet = new Alphabet(0, (70 * curSelected) + 30, currentSelectedCat.getOptions()[curSelected].getDisplay(), true, false);
					ctrl.isMenuItem = true;
					grpControls.add(ctrl);
				}
			}
			else
			{
				currentSelectedCat = options[curSelected];
				isCat = true;
				grpControls.clear();
				for (i in 0...currentSelectedCat.getOptions().length)
				{
					var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, currentSelectedCat.getOptions()[i].getDisplay(), true, false);
					controlLabel.isMenuItem = true;
					controlLabel.targetY = i;
					grpControls.add(controlLabel);
					// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
				}
				curSelected = 0;
			}
		}
		FlxG.save.flush();
	}

	var isSettingControl:Bool = false;

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		if (isCat)
			currentDescription = currentSelectedCat.getOptions()[curSelected].getDescription();
		else
			currentDescription = "Please select a category";

		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}

class OptionCatagory
{
	private var _options:Array<Option> = new Array<Option>();

	public final function getOptions():Array<Option>
	{
		return _options;
	}

	public final function addOption(opt:Option)
	{
		_options.push(opt);
	}

	public final function removeOption(opt:Option)
	{
		_options.remove(opt);
	}

	private var _name:String = "New Catagory";

	public final function getName()
	{
		return _name;
	}

	public function new(catName:String, options:Array<Option>)
	{
		_name = catName;
		_options = options;
	}
}

class Option
{
	public function new()
	{
		display = updateDisplay();
	}

	private var description:String = "";
	private var display:String;

	public final function getDisplay():String
	{
		return display;
	}

	public final function getDescription():String
	{
		return description;
	}

	// Returns whether the label is to be updated.
	public function press():Bool
	{
		return throw "stub!";
	}

	private function updateDisplay():String
	{
		return throw "stub!";
	}

	public function left():Bool
	{
		return false;
	}

	public function right():Bool
	{
		return false;
	}
}

class DownscrollOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.downscroll = !FlxG.save.data.downscroll;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return FlxG.save.data.downscroll ? "Downscroll" : "Upscroll";
	}
}

class MiddlescrollOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.middlescroll = !FlxG.save.data.middlescroll;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return 'Middle scroll ' + (FlxG.save.data.middlescroll ? "on" : "off");
	}
}

class JudgmentsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.judgementCounter = !FlxG.save.data.judgementCounter;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return 'Judgments counter ' + (FlxG.save.data.judgementCounter ? "on" : "off");
	}
}

class GhostTappingOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.ghosttaps = !FlxG.save.data.ghosttaps;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return 'Ghsot tapping ' + (FlxG.save.data.ghosttaps ? "on" : "off");
	}
}

class FpsCapOption extends Option
{
	var max:Int = 720;
	var min:Int = 60;

	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		return true;
	}

	public override function left():Bool
	{
		if (FlxG.save.data.fpslimit > min)
			FlxG.save.data.fpslimit -= 10;
		if (FlxG.save.data.framerateDraw <= min)
			FlxG.save.data.framerateDraw == min;
		FlxG.drawFramerate = FlxG.save.data.fpslimit;
		FlxG.updateFramerate = FlxG.save.data.fpslimit;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		if (FlxG.save.data.fpslimit < max)
			FlxG.save.data.fpslimit += 10;
		if (FlxG.save.data.framerateDraw >= max)
			FlxG.save.data.framerateDraw == max;
		FlxG.drawFramerate = FlxG.save.data.fpslimit;
		FlxG.updateFramerate = FlxG.save.data.fpslimit;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "FPS Limit " + FlxG.save.data.fpslimit;
	}
}

class LaneUnderlayOption extends Option
{
	var max:Float = 1.0;
	var min:Float = 0.0;

	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		return true;
	}

	public override function left():Bool
	{
		if (FlxG.save.data.laneUnderlay > min)
			FlxG.save.data.laneUnderlay -= 0.1;

		FlxG.save.data.laneUnderlay = FlxMath.roundDecimal(FlxG.save.data.laneUnderlay, 2);
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		if (FlxG.save.data.laneUnderlay < max)
			FlxG.save.data.laneUnderlay += 0.1;

		FlxG.save.data.laneUnderlay = FlxMath.roundDecimal(FlxG.save.data.laneUnderlay, 2);
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Lane alpha " + FlxG.save.data.laneUnderlay;
	}
}

class ScrollSpeedOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		return true;
	}

	public override function left():Bool
	{
		if (FlxG.save.data.scrollSpeed > 1)
		{
			FlxG.save.data.scrollSpeed -= 0.1;
		}
		FlxG.save.data.scrollSpeed = FlxMath.roundDecimal(FlxG.save.data.scrollSpeed, 2);
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		if (FlxG.save.data.scrollSpeed < 9.9)
			FlxG.save.data.scrollSpeed += 0.1;
		FlxG.save.data.scrollSpeed = FlxMath.roundDecimal(FlxG.save.data.scrollSpeed, 2);
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Scroll Speed " + FlxG.save.data.scrollSpeed;
	}
}
