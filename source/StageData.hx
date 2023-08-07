package;

typedef StageConfig = {
	cameraZoom:Float,
	dadOffsets:Array<Float>,
	bfOffsets:Array<Float>,
	gfOffsets:Array<Float>
}

class StageData 
{
    public static function getDefaults()
    {
        if (PlayState.SONG.stage == null) 
        {
			switch (PlayState.storyWeek) 
            {
                case 1:
					PlayState.stageCheck = 'stage';
				case 2:
					PlayState.stageCheck = 'spooky';
				case 3:
					PlayState.stageCheck = 'philly';
				case 4:
					PlayState.stageCheck = 'limo';
				case 5:
					if (PlayState.SONG.song == 'Winter-Horrorland')
					{
						PlayState.stageCheck = 'mallEvil';
					}
					else
						PlayState.stageCheck = 'mall';
				case 6:
					if (PlayState.SONG.song == 'Thorns')
					{
						PlayState.stageCheck = 'schoolEvil';
					}
					else
						PlayState.stageCheck = 'school';
				case 7:
					PlayState.stageCheck = 'tank';
				default:
					PlayState.stageCheck = 'stage';
			}
		} 
        else 
        {
			PlayState.stageCheck = PlayState.SONG.stage;
		}
    }
}