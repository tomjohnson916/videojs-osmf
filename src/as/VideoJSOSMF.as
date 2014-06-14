package {
import com.videojs.utils.Console;

import flash.display.Sprite;
import flash.display.StageScaleMode;
import flash.external.ExternalInterface;
import flash.system.Security;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;

import org.osmf.containers.MediaContainer;
import org.osmf.elements.VideoElement;
import org.osmf.events.AudioEvent;
import org.osmf.events.BufferEvent;
import org.osmf.events.DisplayObjectEvent;
import org.osmf.events.DynamicStreamEvent;
import org.osmf.events.LoadEvent;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.MediaErrorEvent;
import org.osmf.events.MediaFactoryEvent;
import org.osmf.events.MediaPlayerCapabilityChangeEvent;
import org.osmf.events.MediaPlayerStateChangeEvent;
import org.osmf.events.PlayEvent;
import org.osmf.events.SeekEvent;
import org.osmf.events.TimeEvent;
import org.osmf.layout.HorizontalAlign;
import org.osmf.layout.LayoutMetadata;
import org.osmf.layout.LayoutTargetEvent;
import org.osmf.layout.ScaleMode;
import org.osmf.layout.VerticalAlign;
import org.osmf.media.DefaultMediaFactory;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactory;
import org.osmf.media.MediaPlayer;
import org.osmf.net.StreamType;
import org.osmf.net.StreamingURLResource;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.TimeTrait;
import org.osmf.utils.TimeUtil;
import org.osmf.utils.Version;


  [SWF(backgroundColor="#FF0000", frameRate="60", width="480", height="270")]
  public class VideoJSOSMF extends Sprite {
    public static const VERSION:String = 'unknown';

    public static const OSMF_VERSION:String = Version.version;
    public static const ALLOWED_DOMAINS:Array = ['*'];
    public static const ALLOWED_INSECURE_DOMAINS:Array = ALLOWED_DOMAINS;

    private var _layoutMetadata:LayoutMetadata;
    private var _contentMediaElement:MediaElement;
    private var _mediaPlayer:MediaPlayer;
    private var _mediaContainer:MediaContainer;
    private var _mediaFactory:MediaFactory;
    private var _resource:StreamingURLResource;

    public function VideoJSOSMF() {
      initializeContextMenu();
      initializeStage();
      initializeSecurity();
      registerExternalMethods();
      registerExternalModel();
      createMediaFactory();
      createLayoutMetadata();
      createMediaPlayer();
      createMediaContainer();
      ready();
    }

    private function initializeStage():void {
      if(this.stage) {
        this.stage.scaleMode = StageScaleMode.NO_SCALE;

      }
    }

    private function initializeSecurity():void {
      Security.allowDomain(ALLOWED_DOMAINS);
      Security.allowInsecureDomain(ALLOWED_INSECURE_DOMAINS);
    }

    private function initializeContextMenu():void {
      var _ctxVersion:ContextMenuItem = new ContextMenuItem("VideoJS OSMF Component v" + VERSION, false, false);
      var _ctxOsmfVersion:ContextMenuItem = new ContextMenuItem("Built with OSMF v" + OSMF_VERSION, false, false);
      var _ctxAbout:ContextMenuItem = new ContextMenuItem("Copyright © 2014 Brightcove, Inc.", false, false);
      var _ctxMenu:ContextMenu = new ContextMenu();
      _ctxMenu.hideBuiltInItems();
      _ctxMenu.customItems.push(_ctxVersion, _ctxOsmfVersion, _ctxAbout);
      this.contextMenu = _ctxMenu;
    }

    private function registerExternalMethods():void {

    }

    private function registerExternalModel():void {
      for (var i:* in loaderInfo.parameters) {
        ExternalInterface.call('window.console.log', 'name:', i, loaderInfo.parameters[i]);
      }
    }

    private function ready():void {
      Console.log('notify ready');
      if (loaderInfo.parameters['readyFunction']) {
        ExternalInterface.call(loaderInfo.parameters['readyFunction']);
      }
    }

    private function dispatchExternalEvent( type:String, data:Object = null):void {

    }

    private function createMediaPlayer():void
    {
      Console.log('Create MediaPlayer');
      _mediaPlayer = new MediaPlayer();
      _mediaPlayer.autoPlay = false;
      _mediaPlayer.autoRewind = false;
      _mediaPlayer.loop = false;
      _mediaPlayer.currentTimeUpdateInterval = 100;
      _mediaPlayer.addEventListener(AudioEvent.MUTED_CHANGE, onAudioEvent);
      _mediaPlayer.addEventListener(AudioEvent.VOLUME_CHANGE, onAudioEvent);
      _mediaPlayer.addEventListener(BufferEvent.BUFFER_TIME_CHANGE, onBufferEvent);
      _mediaPlayer.addEventListener(BufferEvent.BUFFERING_CHANGE, onBufferEvent);
      _mediaPlayer.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onMediaPlayerStateChangeEvent);
      _mediaPlayer.addEventListener(MediaPlayerCapabilityChangeEvent.CAN_BUFFER_CHANGE, onMediaPlayerCapabilityChangeEvent);
      _mediaPlayer.addEventListener(MediaPlayerCapabilityChangeEvent.CAN_LOAD_CHANGE, onMediaPlayerCapabilityChangeEvent);
      _mediaPlayer.addEventListener(MediaPlayerCapabilityChangeEvent.CAN_PLAY_CHANGE, onMediaPlayerCapabilityChangeEvent);
      _mediaPlayer.addEventListener(MediaPlayerCapabilityChangeEvent.CAN_SEEK_CHANGE, onMediaPlayerCapabilityChangeEvent);
      _mediaPlayer.addEventListener(MediaPlayerCapabilityChangeEvent.HAS_ALTERNATIVE_AUDIO_CHANGE, onMediaPlayerCapabilityChangeEvent);
      _mediaPlayer.addEventListener(MediaPlayerCapabilityChangeEvent.HAS_AUDIO_CHANGE, onMediaPlayerCapabilityChangeEvent);
      _mediaPlayer.addEventListener(MediaPlayerCapabilityChangeEvent.HAS_DISPLAY_OBJECT_CHANGE, onMediaPlayerCapabilityChangeEvent);
      _mediaPlayer.addEventListener(MediaPlayerCapabilityChangeEvent.HAS_DRM_CHANGE, onMediaPlayerCapabilityChangeEvent);
      _mediaPlayer.addEventListener(MediaPlayerCapabilityChangeEvent.IS_DYNAMIC_STREAM_CHANGE, onMediaPlayerCapabilityChangeEvent);
      _mediaPlayer.addEventListener(MediaPlayerCapabilityChangeEvent.TEMPORAL_CHANGE, onMediaPlayerCapabilityChangeEvent);
      _mediaPlayer.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekEvent);
      _mediaPlayer.addEventListener(TimeEvent.COMPLETE, onTimeEvent);
      _mediaPlayer.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, onTimeEvent);
      _mediaPlayer.addEventListener(TimeEvent.DURATION_CHANGE, onTimeEvent);
      _mediaPlayer.addEventListener(LoadEvent.BYTES_LOADED_CHANGE, onLoadEvent);
      _mediaPlayer.addEventListener(LoadEvent.BYTES_TOTAL_CHANGE, onLoadEvent);
      _mediaPlayer.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadEvent);
      _mediaPlayer.addEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, onDisplayObjectEvent);
      _mediaPlayer.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onDisplayObjectEvent);
      _mediaPlayer.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayEvent);
      _mediaPlayer.addEventListener(PlayEvent.CAN_PAUSE_CHANGE, onPlayEvent);
      _mediaPlayer.addEventListener(DynamicStreamEvent.AUTO_SWITCH_CHANGE, onDynamicStreamEvent);
      _mediaPlayer.addEventListener(DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE, onDynamicStreamEvent);
      _mediaPlayer.addEventListener(DynamicStreamEvent.SWITCHING_CHANGE, onDynamicStreamEvent);
      _mediaPlayer.addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaErrorEvent);
    }

    private function createMediaElement():void
    {
      Console.log('Create Media Element');
      _contentMediaElement = _mediaFactory.createMediaElement(_resource);

      if( _contentMediaElement )
      {

        _contentMediaElement.addEventListener(MediaElementEvent.TRAIT_ADD, onMediaElementEvent);
        _contentMediaElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onMediaElementEvent);
        _contentMediaElement.addEventListener(MediaElementEvent.METADATA_ADD, onMediaElementEvent);
        _contentMediaElement.addEventListener(MediaElementEvent.METADATA_REMOVE, onMediaElementEvent);
        _contentMediaElement.addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaErrorEvent);
        _contentMediaElement.addMetadata( LayoutMetadata.LAYOUT_NAMESPACE, _layoutMetadata );

        _mediaContainer.addMediaElement( _contentMediaElement );

      } else {
        Console.log("ERROR CREATING MEDIA");
      }

    }

    private function createLayoutMetadata():void
    {
      _layoutMetadata = new LayoutMetadata();
      _layoutMetadata.scaleMode = ScaleMode.LETTERBOX;
      _layoutMetadata.percentWidth = 100;
      _layoutMetadata.percentHeight = 100;
      _layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
      _layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
    }

    private function createMediaContainer():void
    {
      Console.log('Create MediaContainer');
      _mediaContainer = new MediaContainer();
      _mediaContainer.mouseEnabled = true;
      _mediaContainer.clipChildren = true;
      _mediaContainer.addEventListener(LayoutTargetEvent.ADD_CHILD_AT, onLayoutTargetEvent);
      _mediaContainer.width = 400;
      _mediaContainer.height = 300;
    }

    public function streamStatus():void
    {
      if(_mediaPlayer && _mediaPlayer.isDynamicStream )
      {
        Console.log("==== Stream Status ====");
        Console.log("Auto Mode", _mediaPlayer.autoDynamicStreamSwitch);
        Console.log("MP Current Index" , _mediaPlayer.currentDynamicStreamIndex );
        Console.log("MP Max Index" , _mediaPlayer.maxAllowedDynamicStreamIndex );
        Console.log("MP Resolution", _mediaPlayer.mediaHeight + "p" );
        Console.log("==== End Status ====");
      } else {
        Console.log("DST Not Loaded");
      }
    }

    private function createResource(url:String):void {
      Console.log('Create Resource');
      _resource = new StreamingURLResource(url, StreamType.LIVE_OR_RECORDED);
    }

    private function createMediaFactory():void
    {
      Console.log('Create MediaFactory');
      _mediaFactory = new DefaultMediaFactory();
      _mediaFactory.addEventListener( MediaFactoryEvent.MEDIA_ELEMENT_CREATE, onMediaFactoryEvent );
      _mediaFactory.addEventListener( MediaFactoryEvent.PLUGIN_LOAD, onMediaFactoryEvent );
      _mediaFactory.addEventListener( MediaFactoryEvent.PLUGIN_LOAD_ERROR, onMediaFactoryEvent );
    }

    private function onMediaFactoryEvent(event:MediaFactoryEvent):void {

    }

    private function onAudioEvent(event:AudioEvent):void {

    }

    private function onBufferEvent(event:BufferEvent):void {

    }

    private function onMediaPlayerStateChangeEvent(event:MediaPlayerStateChangeEvent):void {

    }

    private function onMediaPlayerCapabilityChangeEvent(event:MediaPlayerCapabilityChangeEvent):void {

    }

    private function onSeekEvent(event:SeekEvent):void {

    }

    private function onTimeEvent(event:TimeEvent):void {

    }

    private function onLoadEvent(event:LoadEvent):void {

    }

    private function onPlayEvent(event:PlayEvent):void {

    }

    private function onDisplayObjectEvent(event:DisplayObjectEvent):void {

    }

    private function onDynamicStreamEvent(event:DynamicStreamEvent):void {

    }

    private function onMediaErrorEvent(event:MediaErrorEvent):void {

    }

    private function onLayoutTargetEvent(event:LayoutTargetEvent):void {

    }

    protected function onMediaElementEvent(event:MediaElementEvent):void
    {
      switch(event.type)
      {
        case MediaElementEvent.METADATA_ADD:
          Console.log('MetaData Add');
          break;

        case MediaElementEvent.METADATA_REMOVE:
          Console.log('MetaData Remove');
          break;

        case MediaElementEvent.TRAIT_ADD:
          Console.log('Trait Add', event.type, event.traitType);
          if( event.traitType == MediaTraitType.TIME)
          {
            var tt:TimeTrait = _mediaPlayer.media.getTrait(MediaTraitType.TIME) as TimeTrait;
            Console.log(tt.currentTime, TimeUtil.formatAsTimeCode(tt.duration) );
          }
          break;

        case MediaElementEvent.TRAIT_REMOVE:
          Console.log('Trait Removed', event.type, event.traitType);
          break;
      }
    }
  }
}
