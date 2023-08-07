package editors;

import flixel.ui.FlxButton;
import haxe.Json;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

class StageEditorState extends MusicBeatState
{
	public static var curStage:String = '';

	var stageGrp:FlxTypedGroup<StagePart>;
	var curPartText:FlxText;

	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	var charsVisible:Bool = false;

	var dadOffsets:Array<Float> = [0, 0];
	var bfOffsets:Array<Float> = [0, 0];
	var gfOffsets:Array<Float> = [0, 0];

	var dad:Character;
	var boyfriend:Character;
	var gf:Character;

	var cameraZoom:Float = 1;
	var curSelectedPart:Int = 1;
	var partsCount:Int = 0;

	var UI_box:FlxUITabMenu;
	var tabs = [
        {name: "Offsets", label: 'Offsets'}
    ];

	override function create()
	{
		FlxG.mouse.visible = true;
		FlxG.mouse.useSystemCursor = true;

		trace('CURSTAGE IS: $curStage');

		camGame = new FlxCamera();
		camHUD = new FlxCamera();

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		stageGrp = new FlxTypedGroup<StagePart>();
		add(stageGrp);

		gf = new Character(400, 130, 'gf', 'gf');
		gf.scrollFactor.set(0.95, 0.95);
		dad = new Character(100, 100, 'dad', 'dad');
		boyfriend = new Boyfriend(770, 450, 'bf', 'bf');
		gf.visible = false;
		dad.visible = false;
		boyfriend.visible = false;
		add(gf);
		add(dad);
		add(boyfriend);

		#if sys
		if (FileSystem.exists('mods/stages/$curStage/config.json'))
		{
			var toParse:String = File.getContent('mods/stages/$curStage/config.json');
			var _json:StageData.StageConfig = cast haxe.Json.parse(toParse);
			cameraZoom = _json.cameraZoom;
			FlxG.camera.zoom = _json.cameraZoom;
			dadOffsets = _json.dadOffsets;
			bfOffsets = _json.bfOffsets;
			gfOffsets = _json.gfOffsets;
		}
		else
		{
			FlxG.camera.zoom = 1;
		}

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
				stageGrp.add(part);
			}
		}
		#end

		curPartText = new FlxText(5, 5, 0, 'Current selected part: $curSelectedPart/$partsCount (Q/E to change)\nHold P to preview mode', 24);
		curPartText.cameras = [camHUD];
		add(curPartText);

		super.create();

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(250, 220);
		UI_box.x = FlxG.width - 280;
		UI_box.y = 30;
		add(UI_box);
        
        addOffsetsUI();

		updateCurPartText();
	}

	var bfOffsetsStprX:FlxUINumericStepper;
    var dadOffsetsStprX:FlxUINumericStepper;
    var gfOffsetsStprX:FlxUINumericStepper;
	var bfOffsetsStprY:FlxUINumericStepper;
    var dadOffsetsStprY:FlxUINumericStepper;
    var gfOffsetsStprY:FlxUINumericStepper;

	function addOffsetsUI():Void
    {
        var uiOptions = new FlxUI(null, UI_box);
		uiOptions.name = "Offsets";

        bfOffsetsStprX = new FlxUINumericStepper(10, 5, 1, bfOffsets[0], -1000, 1000, 3);
        dadOffsetsStprX = new FlxUINumericStepper(10, 35, 1, dadOffsets[0], -1000, 1000, 3);
        gfOffsetsStprX = new FlxUINumericStepper(10, 65, 1, gfOffsets[0], -1000, 1000, 3);

		bfOffsetsStprY = new FlxUINumericStepper(10, 20, 1, bfOffsets[1], -1000, 1000, 3);
        dadOffsetsStprY = new FlxUINumericStepper(10, 50, 1, dadOffsets[1], -1000, 1000, 3);
        gfOffsetsStprY = new FlxUINumericStepper(10, 80, 1, gfOffsets[1], -1000, 1000, 3);

		var charsVisibleCB = new FlxUICheckBox(10, 110, null, null, "Chars visible?", 150);
		charsVisibleCB.checked = charsVisible;
		charsVisibleCB.callback = function()
		{
			charsVisible = !charsVisible;
		};

		var saveButton:FlxButton = new FlxButton(10, 160, "Save", function()
		{
			saveStage();
		});

        // Labels
        var bfOffsetsStprLabelX = new FlxText(bfOffsetsStprX.width + 15, bfOffsetsStprX.y + 1, 'Boyfriend offstet X');
        var dadOffsetsStprLabelX = new FlxText(dadOffsetsStprX.width + 15, dadOffsetsStprX.y + 1, 'Dad offstet X');
        var gfOffsetsStprLabelX = new FlxText(gfOffsetsStprX.width + 15, gfOffsetsStprX.y + 1, 'Girlfriend offstet X');
		var bfOffsetsStprLabelY = new FlxText(bfOffsetsStprY.width + 15, bfOffsetsStprY.y + 1, 'Boyfriend offstet Y');
        var dadOffsetsStprLabelY = new FlxText(dadOffsetsStprY.width + 15, dadOffsetsStprY.y + 1, 'Dad offstet Y');
        var gfOffsetsStprLabelY = new FlxText(gfOffsetsStprY.width + 15, gfOffsetsStprY.y + 1, 'Girlfriend offstet Y');

        uiOptions.add(bfOffsetsStprX);
        uiOptions.add(dadOffsetsStprX);
        uiOptions.add(gfOffsetsStprX);
		uiOptions.add(bfOffsetsStprY);
        uiOptions.add(dadOffsetsStprY);
        uiOptions.add(gfOffsetsStprY);
		uiOptions.add(charsVisibleCB);
		uiOptions.add(saveButton);
        // Labels
        uiOptions.add(bfOffsetsStprLabelX);
        uiOptions.add(dadOffsetsStprLabelX);
        uiOptions.add(gfOffsetsStprLabelX);
		uiOptions.add(bfOffsetsStprLabelY);
        uiOptions.add(dadOffsetsStprLabelY);
        uiOptions.add(gfOffsetsStprLabelY);

        UI_box.addGroup(uiOptions);
    }

	function changeCharsOffstes()
	{
		bfOffsets = [bfOffsetsStprX.value, bfOffsetsStprY.value];
		dadOffsets = [dadOffsetsStprX.value, dadOffsetsStprY.value];
		gfOffsets = [gfOffsetsStprX.value, gfOffsetsStprY.value];
	}

	function saveStage()
	{
		var jsonConfig = {
			"cameraZoom": FlxG.camera.zoom,
			"dadOffsets": dadOffsets,
			"bfOffsets": bfOffsets,
			"gfOffsets": gfOffsets
		};
		var dataConfig:String = Json.stringify(jsonConfig);
		#if sys
		File.saveContent('mods/stages/$curStage/config.json', dataConfig);
		#end

		for (i in 0...partsCount)
		{
			var jsonPart = {
				"positionX": stageGrp.members[i].x,
    			"positionY": stageGrp.members[i].y,
   				"scaleX": stageGrp.members[i].scale.x,
    			"scaleY": stageGrp.members[i].scale.y,
    			"scrollFactor": [stageGrp.members[i].scrollFactor.x, stageGrp.members[i].scrollFactor.y]
			}
			var dataPart:String = Json.stringify(jsonPart);
			#if sys
			File.saveContent('mods/stages/$curStage/$i.json', dataPart);
			#end
		}
	}

	function updateCurPartText()
	{
		curPartText.text = 'Current selected part: $curSelectedPart/$partsCount (Q/E to change)\nHold P to preview mode';
	}

	function moveShit()
	{
		if (FlxG.keys.justPressed.W)
		{
			var shiftThing:Bool = FlxG.keys.pressed.SHIFT;
			if (shiftThing)
				stageGrp.members[curSelectedPart - 1].y -= 1;
			else
				stageGrp.members[curSelectedPart - 1].y -= 10;
		}
		if (FlxG.keys.justPressed.S)
		{
			var shiftThing:Bool = FlxG.keys.pressed.SHIFT;
			if (shiftThing)
				stageGrp.members[curSelectedPart - 1].y += 1;
			else
				stageGrp.members[curSelectedPart - 1].y += 10;
		}
		if (FlxG.keys.justPressed.A)
		{
			var shiftThing:Bool = FlxG.keys.pressed.SHIFT;
			if (shiftThing)
				stageGrp.members[curSelectedPart - 1].x -= 1;
			else
				stageGrp.members[curSelectedPart - 1].x -= 10;
		}
		if (FlxG.keys.justPressed.D)
		{
			var shiftThing:Bool = FlxG.keys.pressed.SHIFT;
			if (shiftThing)
				stageGrp.members[curSelectedPart - 1].x += 1;
			else
				stageGrp.members[curSelectedPart - 1].x += 10;
		}
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.E)
		{
			if (curSelectedPart < partsCount)
				curSelectedPart++;
			updateCurPartText();
		}
		if (FlxG.keys.justPressed.Q)
		{
			if (curSelectedPart > 1)
				curSelectedPart--;
			updateCurPartText();
		}

		if (FlxG.keys.justPressed.Z)
		{
			if (FlxG.camera.zoom > 0.05)
				FlxG.camera.zoom -= 0.05;
		}
		if (FlxG.keys.justPressed.X)
		{
			FlxG.camera.zoom += 0.05;
		}

		moveShit();

		for (i in 0...stageGrp.length)
		{
			if (FlxG.keys.pressed.P)
			{
				stageGrp.members[i].alpha = 1;
			}
			else
			{
				if (i != curSelectedPart - 1)
				{
					stageGrp.members[i].alpha = 0.5;
				}
				else if (i == curSelectedPart - 1)
				{
					stageGrp.members[i].alpha = 1;
				}
			}
		}

		changeCharsOffstes();

		gf.y = 130 - gfOffsets[1];
		gf.x = 400 + gfOffsets[0];
		boyfriend.x = 770 + bfOffsets[0];
		boyfriend.y = 450 - bfOffsets[1];
		dad.y = 100 - dadOffsets[1];
		dad.x = 100 + dadOffsets[0];

		if (charsVisible)
		{
			gf.visible = true;
			dad.visible = true;
			boyfriend.visible = true;
		}
		else
		{
			gf.visible = FlxG.keys.pressed.P;
			dad.visible = FlxG.keys.pressed.P;
			boyfriend.visible = FlxG.keys.pressed.P;
		}
		
		UI_box.visible = !FlxG.keys.pressed.P;

		super.update(elapsed);
	}
}

class StageSelectSubstate extends MusicBeatSubstate
{
	private var curSelected:Int = 0;
	var stages:Array<String> = FNFData.stagesModsArray;
	var grpTxt:FlxTypedGroup<Alphabet>;

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

		for (i in 0...stages.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, stages[i], true, false);
			if (stages.length <= 0)
				songText.text = 'You havent any satges';
			songText.isMenuItem = true;
			songText.targetY = i;
			grpTxt.add(songText);
		}

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, "SELECT STAGE TO EDIT", 20);
		text.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER);
		text.scrollFactor.set();
		add(text);
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
				curSelected = stages.length - 1;
			if (curSelected >= stages.length)
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
				curSelected = stages.length - 1;
			if (curSelected >= stages.length)
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

		if (FlxG.keys.justPressed.ESCAPE)
			close();

		if (accepted)
		{
			var daSelected:String = stages[curSelected];

			editors.StageEditorState.curStage = daSelected.toLowerCase();
			FlxG.switchState(new editors.StageEditorState());
		}
	}
}
