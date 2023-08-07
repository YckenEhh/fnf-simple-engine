package;

import flixel.util.FlxColor;

class NoteType {
    public static var noteTypes:Array<String> = ['default', 'blammed', 'death'];

    public static function getTypeColor(type:String):FlxColor
    {
        var toReturn:FlxColor = 0xffffff;
        switch (type)
        {
            case 'default':
                toReturn = 0xffffff;
            case 'blammed':
                toReturn = 0xe5ff00;
            case 'death':
                toReturn = 0x2b0000;
        }

        return (toReturn);
    }
}