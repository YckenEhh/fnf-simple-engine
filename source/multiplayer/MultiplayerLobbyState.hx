package multiplayer;

import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIInputText;
import flixel.ui.FlxButton;
import multiplayer.SessionData;
import multiplayer.MultiplayerSongSelectMenu;

class MultiplayerLobbyState extends MusicBeatState
{
	var readyText:Alphabet;
	var playerListGrp:FlxTypedGroup<Alphabet>;
	var isReady:Bool;

	public static var player0ready:Bool = false;
	public static var player1ready:Bool = false;
	public static var yourPlayerID:Int = 0;

	public static var selectSongText:Alphabet;
    public static var chatBG:FlxSprite;
    public static var chatLine:FlxUIInputText;
	public static var chatMsgsGpr:FlxTypedGroup<FlxText>;

	public static var songName:String = 'tutorial';
	public static var songDifficulty:Int = 1;
	public static var songWeek:Int = 1;

	override function create()
	{
		FlxG.mouse.useSystemCursor = true;
		FlxG.mouse.visible = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.visible = true;
		bg.antialiasing = true;
		bg.color = 0x92FB22;
		add(bg);

        chatBG = new FlxSprite().makeGraphic(450, 500, FlxColor.BLACK);
        chatBG.y = FlxG.height - (chatBG.height + 12);
        chatBG.alpha = 0.65;
        add(chatBG);

		chatMsgsGpr = new FlxTypedGroup<FlxText>();
		add(chatMsgsGpr);

        chatLine = new FlxUIInputText(0, 0, Std.int(chatBG.width - 80), '', 12);
		chatLine.y = FlxG.height - chatLine.height;
		add(chatLine);
        var sendButton:FlxButton = new FlxButton(0, 0, "Send", function()
		{
			sendMessage('You: ' + chatLine.text);
			SessionData._session.send({verb: "message-send", text: 'Player$yourPlayerID: ' + chatLine.text});
			remove(chatLine);
			chatLine = new FlxUIInputText(0, 0, Std.int(chatBG.width - 80), '', 12);
			chatLine.y = FlxG.height - chatLine.height;
			add(chatLine);
		});
		sendButton.height = chatLine.height;
        sendButton.width = 100;
        sendButton.updateHitbox();
        sendButton.x = chatLine.x + chatLine.width;
        sendButton.y = chatLine.y;
        add(sendButton);

		selectSongText = new Alphabet(0, 0, 'Select song', true, false, 0.05, 0.75);
		selectSongText.y = 35;
		selectSongText.x = FlxG.width - (35 + selectSongText.width);
		if (yourPlayerID == 0)
			add(selectSongText);

		playerListGrp = new FlxTypedGroup<Alphabet>();
		add(playerListGrp);

		for (i in 0...2)
		{
			var playerText:Alphabet = new Alphabet(0, 0, 'Player$i', true, false, 0.05, 0.75);
			playerText.x = 35;
			if (i == 0)
				playerText.y = 35;
			else if (i == 1)
				playerText.y = 35 + playerText.height * 1.25;
			playerListGrp.add(playerText);
		}

		readyText = new Alphabet(0, 0, 'Ready', true, false);
		readyText.x = FlxG.width - (readyText.width + 35);
		readyText.y = FlxG.height - (readyText.height + 35);
		add(readyText);
	}

	public static function sendMessage(text:String)
	{
		var msgText:FlxText = new FlxText(0, 0, 0, '', 12);
		msgText.text = text;
		msgText.x = chatBG.x;
		msgText.y = chatBG.y + (msgText.height * chatMsgsGpr.length);
		chatMsgsGpr.add(msgText);
	}

	function startGame()
	{
		var poop:String = Highscore.formatSong(songName, songDifficulty);

		PlayState.SONG = Song.loadFromJson(poop, songName);
		PlayState.isStoryMode = false;
		PlayState.isMultiplayer = true;
		PlayState.storyDifficulty = songDifficulty;

		PlayState.storyWeek = songWeek;
		LoadingState.loadAndSwitchState(new PlayState());
	}

	override function update(elapsed:Float)
	{
		if (FlxG.mouse.overlaps(selectSongText) && FlxG.mouse.justPressed)
		{
			if (yourPlayerID == 0)
				openSubState(new MultiplayerSongSelectMenu());
		}

		if (FlxG.mouse.overlaps(readyText) && FlxG.mouse.justPressed)
		{
			isReady = !isReady;
		}
		if (isReady)
			readyText.color = FlxColor.GREEN;
		else
			readyText.color = FlxColor.WHITE;

		switch (yourPlayerID)
		{
			case 0:
				player0ready = isReady;
				SessionData._session.send({verb: "player0-readyStatus-update", player0ready: player0ready});
			case 1:
				player1ready = isReady;
				SessionData._session.send({verb: "player1-readyStatus-update", player1ready: player1ready});
		}

        if (player0ready)
		    playerListGrp.members[0].color = FlxColor.GREEN;
        else
            playerListGrp.members[0].color = FlxColor.WHITE;
        if (player1ready)
		    playerListGrp.members[1].color = FlxColor.GREEN;
        else
            playerListGrp.members[1].color = FlxColor.WHITE;

		if (player0ready && player1ready)
		{
			isReady = false;
			player0ready = false;
			player1ready = false;
			startGame();
		}

		super.update(elapsed);
	}
}
