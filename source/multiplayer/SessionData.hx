package multiplayer;

import flixel.FlxG;
import networking.sessions.Session;
import networking.Network;
import networking.utils.NetworkEvent;
import networking.utils.NetworkMode;
import multiplayer.MultiplayerLobbyState;

import lime.app.Application;

class SessionData {
    public static var _session:Session;

	public static function start(mode:NetworkMode, params:Dynamic)
	{
		_session = Network.registerSession(mode, params);

		_session.addEventListener(NetworkEvent.CONNECTED, onConnected);
		_session.addEventListener(NetworkEvent.MESSAGE_RECEIVED, onMessageRecieved);

		_session.start();
	}

	public static function onMessageRecieved(e:NetworkEvent)
	{
		switch (_session.mode)
		{
			case SERVER:
				switch (e.verb)
				{
					case 'player1-readyStatus-update':
						MultiplayerLobbyState.player1ready = e.data.player1ready;
					case 'message-send':
						MultiplayerLobbyState.sendMessage(e.data.text);
					case 'opponent-score-change':
						PlayState.opponentAccuracy = e.data.accuracy;
						PlayState.opponentScore = e.data.score;
					case 'opponent-juds-change':
						PlayState.opponentDaRatings = e.data.daRatings;
						PlayState.opponentMisses = e.data.misses;
					case 'opponent-ready-playstate':
						PlayState.isOpponentReady = true;
					case 'opponent-char-anim':
						PlayState.opponentCharAnim = e.data.name;
					case 'opponent-arrows-anim':
						PlayState.opponentArrowsAnimations = e.data.anims;
				}
			case CLIENT:
				switch (e.verb)
				{
					case 'player0-readyStatus-update':
						MultiplayerLobbyState.player0ready = e.data.player0ready;
					case 'message-send':
						MultiplayerLobbyState.sendMessage(e.data.text);
					case 'song-changed':
						MultiplayerLobbyState.songName = e.data.name;
						MultiplayerLobbyState.songDifficulty = e.data.diff;
						MultiplayerLobbyState.songWeek = e.data.week;
					case 'opponent-score-change':
						PlayState.opponentAccuracy = e.data.accuracy;
						PlayState.opponentScore = e.data.score;
					case 'opponent-juds-change':
						PlayState.opponentDaRatings = e.data.daRatings;
						PlayState.opponentMisses = e.data.misses;
					case 'opponent-ready-playstate':
						PlayState.isOpponentReady = true;
					case 'opponent-char-anim':
						PlayState.opponentCharAnim = e.data.name;
					case 'opponent-arrows-anim':
						PlayState.opponentArrowsAnimations = e.data.anims;
				}
		}
	}

	public static function onConnected(e:NetworkEvent)
	{
		switch (_session.mode)
		{
			case SERVER:
                trace ('Server connected!');
				FlxG.switchState(new MultiplayerLobbyState());
				MultiplayerLobbyState.yourPlayerID = 0;
			case CLIENT:
                trace ('Client connected!');
				FlxG.switchState(new MultiplayerLobbyState());
				MultiplayerLobbyState.yourPlayerID = 1;
		}
    }
}