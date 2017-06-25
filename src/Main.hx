import com.haxepunk.Engine;
import com.haxepunk.HXP;
import com.haxepunk.screen.*;
import scenes.*;

class Main extends Engine
{

	override public function init()
	{
#if debug
		HXP.console.enable();
#end
		HXP.scene = new GameScene();
	}

	public static function main() {
		new Main();
		HXP.screen.scaleMode = new FixedScaleMode();
		HXP.fullscreen = true;
	}

}
