package multiplayer;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;

class MultiplayerResultsSubstate extends MusicBeatSubstate
{
    var statusText:Alphabet;
    var pressEscapeText:Alphabet;

    public function new(status:String)
    {
        super();

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		add(bg);

        statusText = new Alphabet(0, 15, status, true, false);
        statusText.isCenterItem = true;
        statusText.screenCenter(X);
        add(statusText);

        pressEscapeText = new Alphabet(0, 0, 'Press ESCAPE to exit the lobby', true, false, 0.05, 0.65);
        pressEscapeText.isCenterItem = true;
        pressEscapeText.y = FlxG.height - (pressEscapeText.height + 15);
        pressEscapeText.screenCenter(X);
        add(pressEscapeText);

        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
    }

    override function update(elapsed:Float)
	{
		super.update(elapsed);

        statusText.y = 15;
        statusText.screenCenter(X);
        pressEscapeText.y = FlxG.height - (pressEscapeText.height + 15);
        pressEscapeText.screenCenter(X);

        if (FlxG.keys.justPressed.ESCAPE)
        {
            FlxG.switchState(new MultiplayerLobbyState());
        }
    }
}