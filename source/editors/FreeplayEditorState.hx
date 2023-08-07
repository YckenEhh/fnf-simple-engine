package editors;

import haxe.Json;
import openfl.net.FileReference;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.input.gamepad.lists.FlxBaseGamepadList;
import flixel.addons.ui.FlxInputText;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.FlxSprite;
import flixel.FlxG;

class FreeplayEditorState extends MusicBeatState
{
    var UI_box:FlxUITabMenu;
    var bg:FlxSprite;

    var tabs = [
        {name: "Options", label: 'Options'}
    ];

    var weekStpr:FlxUINumericStepper;
    var rStpr:FlxUINumericStepper;
    var gStpr:FlxUINumericStepper;
    var bStpr:FlxUINumericStepper;

    var songText:Alphabet;
    var icon:HealthIcon;
    var iconArray:Array<HealthIcon> = [];

    // Data
    var songName:String = 'Tutorial';
    var songCharacter:String = 'gf';
    var bgR:Int = 121;
    var bgG:Int = 1;
    var bgB:Int = 53;
    var week:Int = 1;
    var songsArray:Array<String> = [];
    var iconsArray:Array<String> = [];
    var colorArray:Array<Int> = [];
    // Input data
    var typingName:FlxInputText;
    var typingIcon:FlxInputText;

    public function new()
    {
        super();

        FlxG.mouse.visible = true;

        bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        bg.color = FlxColor.fromRGB(bgR, bgG, bgB, 255);
		add(bg);

        songText = new Alphabet(0, 0, songName, true, false);
        songText.screenCenter(Y);
        songText.x += 30;
		add(songText);

        icon = new HealthIcon(songCharacter);
		icon.sprTracker = songText;
		iconArray.push(icon);
		add(icon);

        UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(250, 220);
		UI_box.x = FlxG.width - 400;
		UI_box.y = FlxG.height - 600;
		add(UI_box);
        
        addOptionsUI();
    }

    function addOptionsUI():Void
    {
        var uiOptions = new FlxUI(null, UI_box);
		uiOptions.name = "Options";

        var songTitle = new FlxUIInputText(10, 10, 70, songName, 8);
		typingName = songTitle;

        var iconTitle = new FlxUIInputText(10, 30, 70, songCharacter, 8);
		typingIcon = iconTitle;

        var apply1:FlxButton = new FlxButton(0, songTitle.y + 1, "Apply", function()
        {
            applyFunc();
        });
        apply1.x = 250 - (apply1.width + 10);

        var saveWeek:FlxButton = new FlxButton(0, 50 + 1, "Save to week", function()
        {
            addSongToWeek();
        });
        saveWeek.x = 250 - (apply1.width + 10);

        var saveJson:FlxButton = new FlxButton(10, 170, "Save JSON", function()
        {
            saveLevel();
        });

        weekStpr = new FlxUINumericStepper(10, 50, 1, week, 0, 999, 3);

        rStpr = new FlxUINumericStepper(10, 80, 1, bgR, 0, 255, 3);
        gStpr = new FlxUINumericStepper(10, 95, 1, bgG, 0, 255, 3);
        bStpr = new FlxUINumericStepper(10, 110, 1, bgB, 0, 255, 3);

        // Labels
        var weekStprLabel = new FlxText(weekStpr.width + 15, weekStpr.y + 1, 'Week');
        var rStprLabel = new FlxText(rStpr.width + 15, rStpr.y + 1, 'RED');
        var gStprLabel = new FlxText(gStpr.width + 15, gStpr.y + 1, 'GREEN');
        var bStprLabel = new FlxText(bStpr.width + 15, bStpr.y + 1, 'BLUE');
        var songTitleLabel = new FlxText(songTitle.x + songTitle.width + 5, songTitle.y + 1, 'Song name');
        var iconTitleLabel = new FlxText(iconTitle.x + iconTitle.width + 5, iconTitle.y + 1, 'Icon name');

        uiOptions.add(songTitle);
        uiOptions.add(iconTitle);
        uiOptions.add(apply1);
        uiOptions.add(saveWeek);
        uiOptions.add(saveJson);
        uiOptions.add(weekStpr);
        uiOptions.add(rStpr);
        uiOptions.add(gStpr);
        uiOptions.add(bStpr);
        uiOptions.add(weekStpr);
        // Labels
        uiOptions.add(weekStprLabel);
        uiOptions.add(rStprLabel);
        uiOptions.add(gStprLabel);
        uiOptions.add(bStprLabel);
        uiOptions.add(songTitleLabel);
        uiOptions.add(iconTitleLabel);

        UI_box.addGroup(uiOptions);
    }

    function applyFunc()
    {
        songName = typingName.text;
        songCharacter = typingIcon.text;
        
        remove(songText);
        songText = new Alphabet(0, 0, songName, true, false);
        songText.screenCenter(Y);
        songText.x += 30;
		add(songText);

        remove(icon);
        icon = new HealthIcon(songCharacter);
		icon.sprTracker = songText;
		iconArray.push(icon);
		add(icon);
    }

    function addSongToWeek()
    {
        songName = typingName.text;
        songCharacter = typingIcon.text;
        // Song data
        songsArray.push(songName);
        iconsArray.push(songCharacter);

        trace('\nCurrent songsArray is: ${songsArray}\nCurrent iconsArray is: ${iconsArray}');

        setDefaultSongData();
    }

    function setDefaultSongData() 
    {
        songName = 'Tutorial';
        songCharacter = 'gf';

        typingName.text = songName;
        typingIcon.text = songCharacter;
    }

    override function update(elapsed:Float)
    {
        if(FlxG.keys.justPressed.ESCAPE)
        {
            FlxG.switchState(new DebugState());
        }

        bgR = Std.int(rStpr.value);
        bgG = Std.int(gStpr.value);
        bgB = Std.int(bStpr.value);
        week = Std.int(weekStpr.value);

        bg.color = FlxColor.fromRGB(bgR, bgG, bgB, 255);

        super.update(elapsed);
    }

    var _file:FileReference;

    function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved file.");
	}
	
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}
	
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving file");
	}
	
	function saveLevel() 
    {
        bgR = Std.int(rStpr.value);
        bgG = Std.int(gStpr.value);
        bgB = Std.int(bStpr.value);

        colorArray.push(bgR);
        colorArray.push(bgG);
        colorArray.push(bgB);

		var json = {
			"songs": songsArray,
	        "icons": iconsArray,
	        "weekNum": week,
	        "bgColor": colorArray
		};
	
		var data:String = Json.stringify(json, "\t");
	
		if (data.length > 0)
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data, 'week' + ".json");
		}
	}
}