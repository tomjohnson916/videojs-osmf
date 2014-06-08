package {
import flash.display.Sprite;
import flash.external.ExternalInterface;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;

import org.osmf.elements.VideoElement;

import org.osmf.media.MediaPlayer;

import org.osmf.media.MediaPlayerSprite;

import org.osmf.utils.Version;


[SWF(backgroundColor="#FF0000", frameRate="60", width="480", height="270")]
public class VideoJSOSMF extends Sprite {
    public static const VERSION:String = 'one';

    public static const OSMF_VERSION:String = Version.version;

    public function VideoJSOSMF() {
      var _ctxVersion:ContextMenuItem = new ContextMenuItem("VideoJS OSMF Component v" + VERSION, false, false);
      var _ctxOsmfVersion:ContextMenuItem = new ContextMenuItem("Built with OSMF v" + OSMF_VERSION);
      var _ctxAbout:ContextMenuItem = new ContextMenuItem("Copyright © 2014 Brightcove, Inc.", false, false);
      var _ctxMenu:ContextMenu = new ContextMenu();
      _ctxMenu.hideBuiltInItems();
      _ctxMenu.customItems.push(_ctxVersion, _ctxOsmfVersion, _ctxAbout);
      this.contextMenu = _ctxMenu;
      if(ExternalInterface.available) {
        ExternalInterface.call('window.console.log', 'hola 99');
      }
    }
}
}
