package;

import Conductor.BPMChangeEvent;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;

using StringTools;

class ChartingState extends MusicBeatState
{
	var _file:FileReference;

	var UI_box:FlxUITabMenu;
	var Charting_box:FlxUITabMenu;
	var startPos:Float;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	var curSection:Int = 0;

	public static var lastSection:Int = 0;

	var bpmTxt:FlxText;
	var zoomTxt:FlxText;

	var strumLine:FlxSprite;
	var curSong:String = 'Dadbattle';
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;

	var highlight:FlxSprite;

	var GRID_SIZE:Int = 40;

	var dummyArrow:FlxSprite;

	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;

	var gridBG:FlxSprite;

	var _song:SwagSong;

	var typingShit:FlxInputText;
	var typingDiff:FlxInputText;
	var diffInt:Int = PlayState.storyDifficulty;
	var diffString:String;
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;

	var tempBpm:Int = 0;

	var vocals:FlxSound;

	var icon:HealthIcon;

	var gridBlackLine:FlxSprite;

	var tips:String = "
	W/S Mouse Wheel-Change Conductors strum time
	A/D-Go to the previous/next section
	Q/E-Decrease/Increase Note Sustain Length
	Space-Stop/Resume song
	Enter-Exit from Chart Editor";

	var zoomList:Array<Float> = [0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2];
	var curZoom:Int;

	public static var hitsoundsDads:Bool = false;
	public static var hitsoundsBFs:Bool = false;

	var notesThatAlreadyPlayedHitSounds:Array<Dynamic> = [];

	var keyAmmo:Array<Int> = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
	var noteTypes:Array<String> = NoteType.noteTypes;
	var curNoteType:Int = 0;

	var noteTypeText:FlxText;

	override function create()
	{
		curZoom = 3;
		curNoteType = 0;

		var bg = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.antialiasing = true;
		bg.screenCenter();
		bg.scrollFactor.set();
		bg.color = 0x3A3A3A;
		add(bg);

		var tipsBullshit:FlxText = new FlxText(800, FlxG.height - 172, 0, "", 16);
		tipsBullshit.scrollFactor.set();
		tipsBullshit.setFormat(16, FlxColor.WHITE, RIGHT);
		tipsBullshit.text += tips;
		add(tipsBullshit);

		curSection = lastSection;

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE, GRID_SIZE * 16);
		gridBG.x = GRID_SIZE * 7;
		gridBG.y = GRID_SIZE * 1;
		add(gridBG);

		icon = new HealthIcon('face');
		icon.scrollFactor.set(1, 1);
		icon.setGraphicSize(0, 45);
		add(icon);
		icon.setPosition(gridBG.x - GRID_SIZE * 2.5, gridBG.y - GRID_SIZE * 1.25);

		gridBlackLine = new FlxSprite(gridBG.x + gridBG.width / 2, gridBG.y).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();

		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
		{
			_song = {
				song: 'Test',
				notes: [],
				bpm: 150,
				needsVoices: true,
				player1: 'bf',
				player2: 'dad',
				speed: 1,
				mania: 4,
				validScore: false
			};
		}

		FlxG.mouse.visible = true;
		FlxG.mouse.useSystemCursor = true;
		FlxG.save.bind('funkin', 'ninjamuffin99');

		tempBpm = _song.bpm;

		addSection();

		// sections = _song.notes;

		// updateGrid();

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		zoomTxt = new FlxText(2, 2, 0, 'Zoom: ' + zoomList[curZoom] + 'x', 16);
		zoomTxt.scrollFactor.set();
		add(zoomTxt);

		noteTypeText = new FlxText(2, 20, 0, 'Note type: ' + noteTypes[curNoteType] + '(P - next, O - previous)', 16);
		noteTypeText.scrollFactor.set();
		add(noteTypeText);

		strumLine = new FlxSprite(0 + gridBG.x, 50 - gridBG.y).makeGraphic(GRID_SIZE * 8, 4, FlxColor.BLUE);
		add(strumLine);

		dummyArrow = new FlxSprite(-FlxG.width * 10, FlxG.width * 10).makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		var tabs = [
			{name: "Song", label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Note", label: 'Note'},
			{name: "Assets", label: 'Assets'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = FlxG.width / 2 + GRID_SIZE * 4;
		UI_box.y = 20;
		add(UI_box);

		bpmTxt = new FlxText(UI_box.x + UI_box.width, 50, 0, '', 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		getDiff();

		addSongUI();
		addSectionUI();
		addNoteUI();
		addAssetsUI();

		updateHeads(); // nothing

		// hehe
		add(curRenderedSustains);
		add(curRenderedNotes);

		super.create();

		changeMania();
	}

	var stepperSusLength:FlxUINumericStepper;
	var stepperManiaCount:FlxUINumericStepper;

	function getDiff()
	{
		if (diffInt == 0)
			diffString = 'easy';
		else if (diffInt == 1)
			diffString = 'normal';
		else if (diffInt == 2)
			diffString = 'hard';

		FlxG.log.add('DiffInt: ' + diffInt);
	}

	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		stepperSusLength = new FlxUINumericStepper(10, 10, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 16);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';

		stepperManiaCount = new FlxUINumericStepper(10, 35, 1, 4, 1, 9);
		stepperManiaCount.value = PlayState.SONG.mania;
		stepperManiaCount.name = 'mania_count';

		var hitSoundsDad = new FlxUICheckBox(10, 60, null, null, "Opponents hitsounds", 150);
		hitSoundsDad.checked = ChartingState.hitsoundsDads;
		hitSoundsDad.callback = function()
		{
			ChartingState.hitsoundsDads = hitSoundsDad.checked;
		};
		var hitSoundsBF = new FlxUICheckBox(10, 75, null, null, "Players hitsounds", 150);
		hitSoundsBF.checked = ChartingState.hitsoundsBFs;
		hitSoundsBF.callback = function()
		{
			ChartingState.hitsoundsBFs = hitSoundsBF.checked;
		};

		var applyLength:FlxButton = new FlxButton(100, 10, 'Apply');

		tab_group_note.add(stepperSusLength);
		tab_group_note.add(applyLength);
		tab_group_note.add(stepperManiaCount);
		tab_group_note.add(hitSoundsDad);
		tab_group_note.add(hitSoundsBF);

		UI_box.addGroup(tab_group_note);
	}

	function addSongUI():Void
	{
		var UI_songTitle = new FlxUIInputText(10, 10, 70, _song.song, 8);
		typingShit = UI_songTitle;

		var UI_diffTitle = new FlxUIInputText(10, 30, 70, diffString, 8);
		typingDiff = UI_diffTitle;

		var songTitleLabel = new FlxText(80, 10, 64, 'Song name');
		var diffTitleLabel = new FlxText(80, 30, 128, 'Song Difficulty');

		var check_voices = new FlxUICheckBox(10, 180, null, null, "Has voice track", 100);
		check_voices.checked = _song.needsVoices;
		// _song.needsVoices = check_voices.checked;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
			trace('CHECKED!');
		};

		var check_mute_inst = new FlxUICheckBox(10, 200, null, null, "Mute Instrumental (in editor)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			FlxG.sound.music.volume = vol;
		};

		var saveButton:FlxButton = new FlxButton(210, 8, "Save", function()
		{
			saveLevel();
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x, 38, "Reload Audio", function()
		{
			loadSong(_song.song);
		});

		var reloadSongJson:FlxButton = new FlxButton(saveButton.x, 68, "Reload JSON", function()
		{
			loadJson(_song.song.toLowerCase());
		});

		var loadAutosaveBtn:FlxButton = new FlxButton(saveButton.x, 96, 'load autosave', loadAutosave);

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 80, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 65, 1, 1, 1, 339, 0);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		var speedLabel = new FlxText(70, 80, 64, 'Song speed');
		var bpmLabel = new FlxText(70, 65, 64, 'BPM');

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);
		tab_group_song.add(UI_diffTitle);

		tab_group_song.add(check_voices);
		tab_group_song.add(check_mute_inst);
		tab_group_song.add(saveButton);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(songTitleLabel);
		tab_group_song.add(diffTitleLabel);
		tab_group_song.add(speedLabel);
		tab_group_song.add(bpmLabel);

		UI_box.addGroup(tab_group_song);
		UI_box.scrollFactor.set();

		// FlxG.camera.follow(strumLine);
	}

	function addAssetsUI()
	{
		var tab_group_assets = new FlxUI(null, UI_box);
		tab_group_assets.name = "Assets";

		var characters:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));

		var player1DropDown = new FlxUIDropDownMenu(10, 30, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player1 = characters[Std.parseInt(character)];
		});
		player1DropDown.selectedLabel = _song.player1;

		var player2DropDown = new FlxUIDropDownMenu(140, 30, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player2 = characters[Std.parseInt(character)];
		});
		player2DropDown.selectedLabel = _song.player2;


		var player1Label = new FlxText(10, 10, 64, 'Player');
		var player2Label = new FlxText(140, 10, 64, 'Opponent');

		tab_group_assets.add(player1DropDown);
		tab_group_assets.add(player2DropDown);

		tab_group_assets.add(player1Label);
		tab_group_assets.add(player2Label);

		UI_box.addGroup(tab_group_assets);
	}

	var stepperLength:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 0, 999, 0);
		stepperLength.value = _song.notes[curSection].lengthInSteps;
		stepperLength.name = "section_length";

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 130, 1, 1, -999, 999, 0);

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", function()
		{
			copySection(Std.int(stepperCopy.value));
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear", clearSection);

		var swapSection:FlxButton = new FlxButton(10, 170, "Swap section", function()
		{
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				var note = _song.notes[curSection].sectionNotes[i];
				note[1] = (note[1] + 4) % 8;
				_song.notes[curSection].sectionNotes[i] = note;
				updateGrid();
			}
		});

		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Must hit section", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;
		// _song.needsVoices = check_mustHit.checked;

		check_altAnim = new FlxUICheckBox(10, 360, null, null, "Alt Animation", 100);
		check_altAnim.name = 'check_altAnim';

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

		tab_group_section.add(stepperLength);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_altAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(swapSection);

		UI_box.addGroup(tab_group_section);
	}

	function loadSong(daSong:String):Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			// vocals.stop();
		}

		FlxG.sound.playMusic(Paths.inst(daSong), 0.6);

		// WONT WORK FOR TUTORIAL OR TEST SONG!!! REDO LATER
		vocals = new FlxSound().loadEmbedded(Paths.voices(daSong));
		FlxG.sound.list.add(vocals);

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.onComplete = function()
		{
			vocals.pause();
			vocals.time = 0;
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		};
	}

	function generateUI():Void
	{
		while (bullshitUI.members.length > 0)
		{
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		// general shit
		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);
		/* 
			var loopCheck = new FlxUICheckBox(UI_box.x + 10, UI_box.y + 50, null, null, "Loops", 100, ['loop check']);
			loopCheck.checked = curNoteSelected.doesLoop;
			tooltips.add(loopCheck, {title: 'Section looping', body: "Whether or not it's a simon says style section", style: tooltipType});
			bullshitUI.add(loopCheck);

		 */
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Must hit section':
					_song.notes[curSection].mustHitSection = check.checked;
					updateHeads();
				case 'Change BPM':
					_song.notes[curSection].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
				case "Alt Animation":
					_song.notes[curSection].altAnim = check.checked;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			if (wname == 'section_length')
			{
				_song.notes[curSection].lengthInSteps = Std.int(nums.value);
				updateGrid();
			}
			else if (wname == 'song_speed')
			{
				_song.speed = nums.value;
			}
			else if (wname == 'song_bpm')
			{
				tempBpm = Std.int(nums.value);
				Conductor.mapBPMChanges(_song);
				Conductor.changeBPM(Std.int(nums.value));
			}
			else if (wname == 'note_susLength')
			{
				if (curSelectedNote != null)
					curSelectedNote[2] = nums.value;
				else
					trace("PICK NOTE!!!!!!!!");
				updateGrid();
			}
			else if (wname == 'mania_count')
			{
				_song.mania = Std.int(stepperManiaCount.value);
				changeMania();
				trace('key ammo: ' + PlayState.SONG.mania);
			}
			else if (wname == 'section_bpm')
			{
				_song.notes[curSection].bpm = Std.int(nums.value);
				updateGrid();
			}
		}

		// FlxG.log.add(id + " WEED " + sender + " WEED " + data + " WEED " + params);
	}

	var updatedSection:Bool = false;

	/* this function got owned LOL
		function lengthBpmBullshit():Float
		{
			if (_song.notes[curSection].changeBPM)
				return _song.notes[curSection].lengthInSteps * (_song.notes[curSection].bpm / _song.bpm);
			else
				return _song.notes[curSection].lengthInSteps;
	}*/
	function sectionStartTime():Float
	{
		var daBPM:Int = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection)
		{
			if (_song.notes[i].changeBPM)
			{
				daBPM = _song.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	override function update(elapsed:Float)
	{
		curStep = recalculateSteps();

		Conductor.songPosition = Std.int(FlxG.sound.music.time);

		_song.song = typingShit.text;
		diffString = typingDiff.text;

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));

		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
		{
			trace(curStep);
			trace((_song.notes[curSection].lengthInSteps) * (curSection + 1));
			trace('DUMBSHIT');

			if (_song.notes[curSection + 1] == null)
			{
				addSection();
			}

			changeSection(curSection + 1, false);
		}
		else if (strumLine.y < -10)
		{
			if (_song.notes[curSection - 1] == null)
			{
				FlxG.sound.music.time = 0;
				vocals.time = FlxG.sound.music.time;
			}

			changeSection(curSection - 1, false);
		}

		if (ChartingState.hitsoundsDads)
		{
			for (note in _song.notes[curSection].sectionNotes)
			{
				var gottaHitNote:Bool = _song.notes[curSection].mustHitSection;

				if (note[1] > PlayState.SONG.mania - 1)
				{
					gottaHitNote = !_song.notes[curSection].mustHitSection;
				}
				if (note[0] <= Conductor.songPosition
					&& FlxG.sound.music.playing
					&& !notesThatAlreadyPlayedHitSounds.contains(note)
					&& !gottaHitNote)
				{
					notesThatAlreadyPlayedHitSounds.push(note);
					FlxG.sound.play(Paths.sound("hitsound"), 0.8);
				}
			}
		}
		if (ChartingState.hitsoundsBFs)
		{
			for (note in _song.notes[curSection].sectionNotes)
			{
				var gottaHitNote:Bool = _song.notes[curSection].mustHitSection;

				if (note[1] > PlayState.SONG.mania - 1)
				{
					gottaHitNote = !_song.notes[curSection].mustHitSection;
				}
				if (note[0] <= Conductor.songPosition
					&& FlxG.sound.music.playing
					&& !notesThatAlreadyPlayedHitSounds.contains(note)
					&& gottaHitNote)
				{
					notesThatAlreadyPlayedHitSounds.push(note);
					FlxG.sound.play(Paths.sound("hitsound"), 0.8);
				}
			}
		}

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEach(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
					{
						if (FlxG.keys.pressed.CONTROL)
						{
							selectNote(note);
						}
						else
						{
							trace('tryin to delete note...');
							deleteNote(note);
						}
					}
				});
			}
			else
			{
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
				{
					FlxG.log.add('added note');
					addNote();
				}
			}
		}

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
		{
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			lastSection = curSection;

			PlayState.SONG = _song;
			FlxG.sound.music.stop();
			vocals.stop();
			FlxG.switchState(new PlayState());
		}

		if (FlxG.keys.justPressed.O)
		{
			if (curNoteType > -1)
			{
				curNoteType -= 1;

				if (curNoteType == -1)
				{
					curNoteType = 0;
					noteTypeText.text = 'Note type: ' + noteTypes[curNoteType] + '(P - next, O - previous)';
				}
				else
				{
					noteTypeText.text = 'Note type: ' + noteTypes[curNoteType] + '(P - next, O - previous)';
				}
			}
		}
		if (FlxG.keys.justPressed.P)
		{
			if (curNoteType < noteTypes.length - 1)
			{
				curNoteType += 1;
				noteTypeText.text = 'Note type: ' + noteTypes[curNoteType] + '(P - next, O - previous)';
			}
			else if (curNoteType > noteTypes.length - 1)
			{
				curNoteType = noteTypes.length;
				noteTypeText.text = 'Note type: ' + noteTypes[curNoteType] + '(P - next, O - previous)';
			}
		}

		if (FlxG.keys.justPressed.E)
		{
			changeNoteSustain(Conductor.stepCrochet);
		}
		if (FlxG.keys.justPressed.Q)
		{
			changeNoteSustain(-Conductor.stepCrochet);
		}

		if (FlxG.keys.justPressed.TAB)
		{
			if (FlxG.keys.pressed.SHIFT)
			{
				UI_box.selected_tab -= 1;
				if (UI_box.selected_tab < 0)
					UI_box.selected_tab = 2;
			}
			else
			{
				UI_box.selected_tab += 1;
				if (UI_box.selected_tab >= 3)
					UI_box.selected_tab = 0;
			}
		}

		if (FlxG.keys.justPressed.M)
		{
			gridBG.x += GRID_SIZE;
			trace('grids x: ' + gridBG.x);
		}

		if (FlxG.keys.justPressed.N)
		{
			gridBG.x -= GRID_SIZE;
			trace('grids x: ' + gridBG.x);
		}

		if (!typingShit.hasFocus || !typingDiff.hasFocus)
		{
			if (FlxG.keys.justPressed.SPACE)
			{
				if (FlxG.sound.music.playing)
				{
					notesThatAlreadyPlayedHitSounds = [];
					FlxG.sound.music.pause();
					vocals.pause();
				}
				else
				{
					vocals.play();
					FlxG.sound.music.play();
				}
			}

			if (FlxG.keys.justPressed.R)
			{
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else
					resetSection();
			}

			if (FlxG.mouse.wheel != 0)
			{
				FlxG.sound.music.pause();
				vocals.pause();

				FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
				vocals.time = FlxG.sound.music.time;

				notesThatAlreadyPlayedHitSounds = [];
			}

			if (!FlxG.keys.pressed.SHIFT)
			{
				if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
				{
					FlxG.sound.music.pause();
					vocals.pause();

					var daTime:Float = 700 * FlxG.elapsed;

					if (FlxG.keys.pressed.W)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;

					notesThatAlreadyPlayedHitSounds.splice(0, notesThatAlreadyPlayedHitSounds.length);
				}
			}
			else
			{
				if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP || FlxG.keys.justPressed.S || FlxG.keys.justPressed.DOWN)
				{
					FlxG.sound.music.pause();
					vocals.pause();

					var daTime:Float = Conductor.stepCrochet * 2;

					if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;

					notesThatAlreadyPlayedHitSounds.splice(0, notesThatAlreadyPlayedHitSounds.length);
				}
			}
		}

		_song.bpm = tempBpm;

		/* if (FlxG.keys.justPressed.UP)
				Conductor.changeBPM(Conductor.bpm + 1);
			if (FlxG.keys.justPressed.D || FlxG.keys.justPressed.RIGHTOWN)
				Conductor.changeBPM(Conductor.bpm - 1); */

		var shiftThing:Int = 1;
		if (FlxG.keys.pressed.SHIFT)
			shiftThing = 4;
		if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D || FlxG.keys.justPressed.RIGHT)
			changeSection(curSection + shiftThing);
		if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A || FlxG.keys.justPressed.LEFT)
			changeSection(curSection - shiftThing);

		if (FlxG.keys.justPressed.Z)
		{
			if (curZoom > -1)
			{
				curZoom -= 1;

				if (curZoom == -1)
				{
					curZoom = 0;
					changeZoom();
				}
				else
				{
					changeZoom();
				}
			}
		}
		if (FlxG.keys.justPressed.X)
		{
			if (curZoom < zoomList.length - 1)
			{
				curZoom += 1;
				changeZoom();
			}
			else if (curZoom > zoomList.length - 1)
			{
				curZoom = zoomList.length;
				changeZoom();
			}
		}

		bpmTxt.text = bpmTxt.text = 'Song: '
			+ _song.song
			+ '\nDifficulty: '
			+ diffString
			+ "\n\nPos:"
			+ FlxMath.roundDecimal(Conductor.songPosition / 1000, 2)
			+ " / "
			+ FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2)
			+ "\nSong BPM: "
			+ tempBpm
			+ "\nSection: "
			+ curSection
			+ "\nCurbeat: "
			+ curBeat
			+ "\nCurstep: "
			+ curStep;
		super.update(elapsed);
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	function recalculateSteps():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		FlxG.sound.music.pause();
		vocals.pause();

		// Basically old shit from changeSection???
		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSection = 0;
		}

		vocals.time = FlxG.sound.music.time;
		updateCurStep();

		updateGrid();
		updateSectionUI();
	}

	function updateHeads()
	{
		if (check_mustHitSection.checked)
		{
			remove(icon);
			icon = new HealthIcon(PlayState.SONG.player1);
			icon.scrollFactor.set(1, 1);
			icon.setGraphicSize(0, 45);
			add(icon);
			icon.setPosition(gridBG.x - GRID_SIZE * 2.5, gridBG.y - GRID_SIZE * 1.25);
		}
		else if (!check_mustHitSection.checked)
		{
			remove(icon);
			icon = new HealthIcon(PlayState.SONG.player2);
			icon.scrollFactor.set(1, 1);
			icon.setGraphicSize(0, 45);
			add(icon);
			icon.setPosition(gridBG.x - GRID_SIZE * 2.5, gridBG.y - GRID_SIZE * 1.25);
		}
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		trace('changing section' + sec);

		if (_song.notes[sec] != null)
		{
			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.pause();
				vocals.pause();

				/*var daNum:Int = 0;
					var daLength:Float = 0;
					while (daNum <= sec)
					{
						daLength += lengthBpmBullshit();
						daNum++;
				}*/

				FlxG.sound.music.time = sectionStartTime();
				vocals.time = FlxG.sound.music.time;
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
			updateHeads();
		}
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function changeZoom()
	{
		zoomTxt.text = 'Zoom: ' + zoomList[curZoom] + 'x';
	}

	function changeMania()
	{
		var mn = PlayState.SONG.mania;

		remove(gridBG);
		remove(icon);
		remove(gridBlackLine);
		remove(strumLine);

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * (mn * 2), GRID_SIZE * 16);
		gridBG.x = GRID_SIZE * 7;
		gridBG.y = GRID_SIZE * 1;
		switch (mn)
		{
			case 1:
				gridBG.x = 720;
			case 2:
				gridBG.x = 640;
			case 3:
				gridBG.x = 560;
			case 4:
				gridBG.x = 480;
			case 5:
				gridBG.x = 400;
			case 6:
				gridBG.x = 320;
			case 7:
				gridBG.x = 240;
			case 8:
				gridBG.x = 160;
			case 9:
				gridBG.x = 80;
		}
		add(gridBG);

		icon = new HealthIcon('face');
		icon.scrollFactor.set(1, 1);
		icon.setGraphicSize(0, 45);
		add(icon);
		icon.setPosition(gridBG.x - GRID_SIZE * 2.5, gridBG.y - GRID_SIZE * 1.25);

		gridBlackLine = new FlxSprite(gridBG.x + gridBG.width / 2, gridBG.y).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);

		strumLine = new FlxSprite(0 + gridBG.x, 50 - gridBG.y).makeGraphic(GRID_SIZE * (mn * 2), 4, FlxColor.BLUE);
		add(strumLine);

		changeSection(curSection);
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];

		stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection;
		check_altAnim.checked = sec.altAnim;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null)
			stepperSusLength.value = curSelectedNote[2];
	}

	function updateGrid():Void
	{
		while (curRenderedNotes.members.length > 0)
		{
			curRenderedNotes.remove(curRenderedNotes.members[0], true);
		}

		while (curRenderedSustains.members.length > 0)
		{
			curRenderedSustains.remove(curRenderedSustains.members[0], true);
		}

		var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;

		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0)
		{
			Conductor.changeBPM(_song.notes[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		}
		else
		{
			// get last bpm
			var daBPM:Int = _song.bpm;
			for (i in 0...curSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		/* // PORT BULLSHIT, INCASE THERE'S NO SUSTAIN DATA FOR A NOTE
			for (sec in 0..._song.notes.length)
			{
				for (notesse in 0..._song.notes[sec].sectionNotes.length)
				{
					if (_song.notes[sec].sectionNotes[notesse][2] == null)
					{
						trace('SUS NULL');
						_song.notes[sec].sectionNotes[notesse][2] = 0;
					}
				}
			}
		 */

		for (i in sectionInfo)
		{
			var daNoteInfo = i[1];
			var daStrumTime = i[0];
			var daSus = i[2];
			var noteType:String = i[3];

			var note:Note = new Note(daStrumTime, daNoteInfo % PlayState.SONG.mania, noteType);
			note.sustainLength = daSus;
			note.noteType = noteType;
			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
			note.updateHitbox();
			note.x = Math.floor(daNoteInfo * GRID_SIZE) + gridBG.x;
			note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));

			curRenderedNotes.add(note);

			if (daSus > 0)
			{
				var sustainVis:FlxSprite = new FlxSprite(note.x - 3 + (GRID_SIZE / 2),
					note.y - 4 + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, gridBG.height)));

				// Trails colors shit :)

				if (note.noteData == 0)
					sustainVis.color = 0xd64cd6;
				else if (note.noteData == 1)
					sustainVis.color = 0x00fff2;
				else if (note.noteData == 2)
					sustainVis.color = 0x28f000;
				else if (note.noteData == 3)
					sustainVis.color = 0xff3d3d;
				else
					sustainVis.color = 0xffffff;

				curRenderedSustains.add(sustainVis);
			}
		}
	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false
		};

		_song.notes.push(sec);
	}

	function selectNote(note:Note):Void
	{
		var swagNum:Int = 0;

		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i.strumTime == note.strumTime && i.noteData % PlayState.SONG.mania == note.noteData)
			{
				curSelectedNote = _song.notes[curSection].sectionNotes[swagNum];
			}

			swagNum += 1;
		}

		updateGrid();
		updateNoteUI();
	}

	function deleteNote(note:Note):Void
	{
		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i[0] == note.strumTime && i[1] % PlayState.SONG.mania == note.noteData)
			{
				FlxG.log.add('FOUND EVIL NUMBER');
				_song.notes[curSection].sectionNotes.remove(i);
			}
		}

		updateGrid();
	}

	function clearSection():Void
	{
		_song.notes[curSection].sectionNotes = [];

		updateGrid();
	}

	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}

	private function addNote():Void
	{
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData = Math.floor((FlxG.mouse.x - gridBG.x) / GRID_SIZE);
		var noteSus = 0;

		_song.notes[curSection].sectionNotes.push([noteStrum, noteData, noteSus, noteTypes[curNoteType]]);

		curSelectedNote = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];

		if (FlxG.keys.pressed.CONTROL)
		{
			_song.notes[curSection].sectionNotes.push([
				noteStrum,
				(noteData + PlayState.SONG.mania) % (PlayState.SONG.mania * 2),
				noteSus
			]);
		}

		trace(noteStrum);
		trace(curSection);

		updateGrid();
		updateNoteUI();

		autosaveSong();
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}
	/*
		function calculateSectionLengths(?sec:SwagSection):Int
		{
			var daLength:Int = 0;

			for (i in _song.notes)
			{
				var swagLength = i.lengthInSteps;

				if (i.typeOfSection == Section.COPYCAT)
					swagLength * 2;

				daLength += swagLength;

				if (sec != null && sec == i)
				{
					trace('swag loop??');
					break;
				}
			}

			return daLength;
	}*/
	private var daSpacing:Float = 0.3;

	function loadLevel():Void
	{
		trace(_song.notes);
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function loadJson(song:String):Void
	{
		if (diffString == 'normal')
		{
			FlxG.log.add('Normal');
			PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
			PlayState.storyDifficulty = 1;
		}
		else if (diffString == 'hard' || diffString == 'easy' || diffString == 'normal')
		{
			FlxG.log.add('Loading chart...');
			if (diffString == 'normal')
				PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
			else
				PlayState.SONG = Song.loadFromJson(song.toLowerCase() + '-' + diffString, song.toLowerCase());
			if (diffString == 'easy')
				PlayState.storyDifficulty = 0;
			else if (diffString == 'normal')
				PlayState.storyDifficulty = 1;
			else if (diffString == 'hard')
				PlayState.storyDifficulty = 2;
		}
		else if (diffString != 'hard' || diffString != 'easy' || diffString != 'normal')
		{
			FlxG.log.add('Unknown difficulty');
			PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
			PlayState.storyDifficulty = 1;
		}
		FlxG.resetState();
	}

	function loadAutosave():Void
	{
		PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
		FlxG.resetState();
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}

	private function saveLevel()
	{
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json);

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			if (diffString == 'normal')
				_file.save(data.trim(), _song.song.toLowerCase() + ".json");
			else
				_file.save(data.trim(), _song.song.toLowerCase() + "-" + diffString + ".json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}
}
