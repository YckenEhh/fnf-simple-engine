package multiplayer;

import networking.sessions.Session;
import networking.utils.NetworkMode;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.ui.FlxUIInputText;
import flixel.FlxSprite;
import multiplayer.SessionData;

using StringTools;

class MultiplayerMenuState extends MusicBeatState
{
	private var curSelected:Int = 0;
	private var curSelected1:Int = 1;
	private var types:Array<String> = ['Join the lobby', 'Create a lobby'];
	private var grpTypes:FlxTypedGroup<Alphabet>;
	private var isTypingIP:Bool = false;
	private var ipText:Alphabet;
	private var connectText:Alphabet;
	private var cancelText:Alphabet;
	private var ipInputText:FlxUIInputText;
	private var currentTypedIP:String = '';
	private var isWaitingForPlayer:Bool = false;

	override function create()
	{
		FlxG.mouse.useSystemCursor = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.visible = true;
		bg.antialiasing = true;
		bg.color = 0xFF58BF;
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

		if (isTypingIP)
		{
			grpTypes.members[0].visible = false;
			grpTypes.members[1].visible = false;
			ipText.screenCenter();
			ipText.y = ipText.height * 1.5;
			connectText.screenCenter(X);
			connectText.y = FlxG.height - connectText.height * 1.5;
			cancelText.screenCenter(X);
			cancelText.y = FlxG.height - (connectText.height * 1.5 + connectText.height * 1.5);
			currentTypedIP = ipInputText.text;
		}

		if (!isTypingIP)
		{
			FlxG.mouse.visible = false;

			if (ipText != null)
				remove(ipText);
			if (connectText != null)
				remove(connectText);
			if (cancelText != null)
				remove(cancelText);
			if (ipInputText != null)
				remove(ipInputText);
			currentTypedIP = '';
		}

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
			if (!isTypingIP)
			{
				FlxG.switchState(new MainMenuState());
				if (SessionData._session != null)
					SessionData._session.disconnectClient();
			}
			else
			{
				grpTypes.members[0].visible = true;
				grpTypes.members[1].visible = true;
				isTypingIP = false;
			}
		}

		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE)
		{
			if (!isTypingIP)
			{
				switch (grpTypes.members[curSelected].text)
				{
					case 'Join the lobby':
						curSelected1 = 1;
						FlxG.mouse.visible = true;

						isTypingIP = true;
						ipText = new Alphabet(0, 0, 'Type lobby IP and port', true, false);
						ipText.isCenterItem = true;
						ipText.screenCenter(X);
						ipText.y = ipText.height * 1.5;
						add(ipText);

						connectText = new Alphabet(0, 0, 'Connect', true, false);
						connectText.isCenterItem = true;
						connectText.screenCenter(X);
						connectText.y = FlxG.height - connectText.height * 1.5;
						add(connectText);

						cancelText = new Alphabet(0, 0, 'Cancel', true, false);
						cancelText.isCenterItem = true;
						cancelText.screenCenter(X);
						cancelText.y = FlxG.height - (connectText.height * 1.5 + connectText.height * 1.5);
						add(cancelText);

						ipInputText = new FlxUIInputText(0, 0, Std.int(ipText.width / 1.25), currentTypedIP, 32);
						ipInputText.screenCenter(X);
						ipInputText.y = ipText.height * 1.5;
						ipInputText.text = currentTypedIP;
						ipInputText.y = ipInputText.y + ipText.height * 1.25;
						add(ipInputText);

						changeSelection(0);
					case 'Create a lobby':
						SessionData.start(NetworkMode.SERVER, {ip: '0.0.0.0', port: 4899, max_connections: 2});
						var statusText = new Alphabet(0, 0, 'Waiting for player...', true, false);
						statusText.isCenterItem = true;
						statusText.screenCenter();
						add(statusText);
						grpTypes.members[0].visible = false;
						grpTypes.members[1].visible = false;
				}
			}

			if (isTypingIP)
			{
				switch (curSelected1)
				{
					case 0: // CANCEL LOL
						isTypingIP = false;
						grpTypes.members[0].visible = true;
						grpTypes.members[1].visible = true;
					case 1: // CONNECT
						var data:Array<String> = currentTypedIP.split(':');
						SessionData.start(NetworkMode.CLIENT, {ip: data[0], port: data[1]});
				}
			}
		}
	}

	function changeSelection(change:Int = 0)
	{
		if (!isTypingIP)
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
		if (isTypingIP)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

			curSelected1 += change;

			if (curSelected1 < 0)
				curSelected1 = 1;
			if (curSelected1 > 1)
				curSelected1 = 0;

			var bullShit:Int = 0;

			if (curSelected1 == 0)
			{
				cancelText.alpha = 1;
			}
			else
			{
				cancelText.alpha = 0.6;
			}

			if (curSelected1 == 1)
			{
				connectText.alpha = 1;
			}
			else
			{
				connectText.alpha = 0.6;
			}
		}
	}
}
