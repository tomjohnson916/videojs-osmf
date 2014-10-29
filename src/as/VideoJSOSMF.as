package {
import com.videojs.utils.Console;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.external.ExternalInterface;
import flash.system.Security;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;

import org.osmf.containers.MediaContainer;
import org.osmf.events.AudioEvent;
import org.osmf.events.BufferEvent;
import org.osmf.events.DRMEvent;
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
import org.osmf.media.MediaPlayerState;
import org.osmf.net.StreamType;
import org.osmf.net.StreamingURLResource;
import org.osmf.traits.DisplayObjectTrait;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.TimeTrait;
import org.osmf.utils.TimeUtil;
import org.osmf.utils.Version;

CONFIG::DASH
import com.castlabs.dash.DashPluginInfo;

/*
  TODO: Player should be first on this one.
  [Player]

 1. Create Resource
 2. Create Factory
 3. Create Layout Metadata
 4. Create Player
 5. Create Container
 6. Create Element
 */


[SWF(backgroundColor="#FF0000", frameRate="60", width="480", height="270")]
public class VideoJSOSMF extends Sprite {

  public static const VERSION:String = (CONFIG::VERSION) ? CONFIG::VERSION.toString() : ' unknown';
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
    createMediaPlayer();
    ready();
  }

  private function initializeStage():void {
    if (this.stage) {
      this.stage.scaleMode = StageScaleMode.NO_SCALE;
      this.stage.align = StageAlign.TOP_LEFT;
      this.stage.addEventListener(Event.RESIZE, onStageResize);
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
    Console.log('Register External Methods');

    ExternalInterface.addCallback('streamStatus', streamStatus);
    ExternalInterface.addCallback('vjs_echo', onEchoCalled);
    ExternalInterface.addCallback('vjs_endOfStream', onEndOfStreamCalled);
    ExternalInterface.addCallback('vjs_abort', onAbortCalled);
    ExternalInterface.addCallback('vjs_getProperty', onGetPropertyCalled);
    ExternalInterface.addCallback('vjs_setProperty', onSetPropertyCalled);
    ExternalInterface.addCallback('vjs_autoplay', onAutoplayCalled);
    ExternalInterface.addCallback('vjs_src', onSrcCalled);
    ExternalInterface.addCallback('vjs_load', onLoadCalled);
    ExternalInterface.addCallback('vjs_play', onPlayCalled);
    ExternalInterface.addCallback('vjs_pause', onPauseCalled);
    ExternalInterface.addCallback('vjs_resume', onResumeCalled);
    ExternalInterface.addCallback('vjs_stop', onStopCalled);

    ExternalInterface.addCallback('vjs_paused', onPausedCalled);
 }

  private function registerExternalModel():void {
    Console.log('Register External Model');
    for (var i:* in loaderInfo.parameters) {
      Console.log('name:', i, loaderInfo.parameters[i]);
    }
  }

  private function ready():void {
    if (loaderInfo.parameters['readyFunction']) {
      ExternalInterface.call(loaderInfo.parameters['readyFunction'], ExternalInterface.objectID);
    }
  }

  private function createMediaPlayer():void {
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
    _mediaPlayer.addEventListener(DRMEvent.DRM_STATE_CHANGE, onDRMEvent);
  }

  private function createMediaElement():void {
    Console.log('Create Media Element');
    _contentMediaElement = _mediaFactory.createMediaElement(_resource);

    if (_contentMediaElement) {
      _contentMediaElement.addEventListener(MediaElementEvent.TRAIT_ADD, onMediaElementEvent);
      _contentMediaElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onMediaElementEvent);
      _contentMediaElement.addEventListener(MediaElementEvent.METADATA_ADD, onMediaElementEvent);
      _contentMediaElement.addEventListener(MediaElementEvent.METADATA_REMOVE, onMediaElementEvent);
      _contentMediaElement.addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaErrorEvent);
      _contentMediaElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, _layoutMetadata);
      _mediaContainer.addMediaElement(_contentMediaElement);
    } else {
      Console.log("ERROR CREATING MEDIA");
    }

  }

  private function createLayoutMetadata():void {
    Console.log('Create LayoutMetadata');
    _layoutMetadata = new LayoutMetadata();
    _layoutMetadata.scaleMode = ScaleMode.LETTERBOX;
    _layoutMetadata.percentWidth = 100;
    _layoutMetadata.percentHeight = 100;
    _layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
    _layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
  }

  private function createMediaContainer():void {
    Console.log('Create MediaContainer');
    _mediaContainer = new MediaContainer();
    _mediaContainer.mouseEnabled = true;
    _mediaContainer.clipChildren = true;
    _mediaContainer.addEventListener(LayoutTargetEvent.ADD_CHILD_AT, onLayoutTargetEvent);
    _mediaContainer.width = stage.stageWidth;
    _mediaContainer.height = stage.stageHeight;

    addChild(_mediaContainer);
  }

  public function streamStatus():String {
    var returnValue = "";
    if (_mediaPlayer && _mediaPlayer.isDynamicStream) {
      returnValue = "==== Stream Status ====" +
      "\nAuto Switching Mode: " + _mediaPlayer.autoDynamicStreamSwitch +
      "\nPlaylist Current Index: " + _mediaPlayer.currentDynamicStreamIndex +
      "\nPlaylist Max Index: " + _mediaPlayer.maxAllowedDynamicStreamIndex +
      "\nCurrent Resolution: " + _mediaPlayer.mediaWidth + "x" + _mediaPlayer.mediaHeight +
      "\nCurrent Bitrate: " + _mediaPlayer.getBitrateForDynamicStreamIndex(_mediaPlayer.currentDynamicStreamIndex) +
      "\n==== End Status ====";
    } else if (!_mediaPlayer) {
      returnValue = "MediaPlayer Not Loaded";
    } else {
      returnValue = "DST Not Loaded";
    }

    return returnValue;
  }

  private function createResource(url:String):void {
    Console.log('Create Resource');
    _resource = new StreamingURLResource(url, StreamType.LIVE_OR_RECORDED);
  }

  private function createMediaFactory():void {
    Console.log('Create MediaFactory');
    _mediaFactory = new DefaultMediaFactory();
    _mediaFactory.addEventListener(MediaFactoryEvent.MEDIA_ELEMENT_CREATE, onMediaFactoryEvent);
    _mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, onMediaFactoryEvent);
    _mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, onMediaFactoryEvent);

    if(CONFIG::DASH && CONFIG::DASH == true) _mediaFactory.addItem(new DashPluginInfo().getMediaFactoryItemAt(0));

  }

  private function onMediaFactoryEvent(event:MediaFactoryEvent):void {
    Console.log('onMediaFactoryEvent', event.toString());
    switch (event.type) {
      case MediaFactoryEvent.PLUGIN_LOAD:
        Console.log("--- Plugin Loaded");
        break;

      case MediaFactoryEvent.PLUGIN_LOAD_ERROR:
        Console.log("--- Plugin Error");
        break;

      case MediaFactoryEvent.MEDIA_ELEMENT_CREATE:
        break;

      default:

    }

  }

  private function onAudioEvent(event:AudioEvent):void {
    Console.log('onAudioEvent', event.toString());
    switch (event.type) {
      case AudioEvent.MUTED_CHANGE:
      case AudioEvent.VOLUME_CHANGE:
        dispatchExternalEvent('volumechange');
        break;
    }
  }

  private function onBufferEvent(event:BufferEvent):void {
    Console.log('onBufferEvent', event.toString());
  }

  private function onMediaPlayerStateChangeEvent(event:MediaPlayerStateChangeEvent):void {
    Console.log('onMediaPlayerStateChangeEvent', event.toString());
    switch (event.state) {
      case MediaPlayerState.PLAYING:
      case MediaPlayerState.PAUSED:
      case MediaPlayerState.BUFFERING:
      case MediaPlayerState.PLAYBACK_ERROR:
      case MediaPlayerState.LOADING:
      case MediaPlayerState.UNINITIALIZED:
        dispatchExternalEvent(event.state);
        break;
    }
  }

  private function onMediaPlayerCapabilityChangeEvent(event:MediaPlayerCapabilityChangeEvent):void {
    Console.log('onMediaPlayerCapabilityChangeEvent', event.toString());
  }

  private function onSeekEvent(event:SeekEvent):void {
    Console.log('onSeekEvent', event.toString());
    if(event.seeking) {
      dispatchExternalEvent('seek');
    } else {
      dispatchExternalEvent('seeked');
    }
  }

  private function onTimeEvent(event:TimeEvent):void {
    switch(event.type) {
      case TimeEvent.COMPLETE:
        dispatchExternalEvent('ended');
        break;

      case TimeEvent.CURRENT_TIME_CHANGE:
        dispatchExternalEvent('timeupdate');
        break;

      case TimeEvent.DURATION_CHANGE:
        dispatchExternalEvent('durationchange');
        break;
    }
  }

  private function onLoadEvent(event:LoadEvent):void {
    Console.log('onLoadEvent', event.toString());
    switch(event.type) {
      case LoadEvent.LOAD_STATE_CHANGE:
        dispatchExternalEvent(event.loadState);
        break;
    }
  }

  private function onPlayEvent(event:PlayEvent):void {
    Console.log('onPlayEvent', event.toString());
    switch(event.type) {
      case PlayEvent.PLAY_STATE_CHANGE:
        dispatchExternalEvent(event.playState);
        break;
    }
  }

  private function onDisplayObjectEvent(event:DisplayObjectEvent):void {
    Console.log('onDisplayObjectEvent', event.toString());
    switch(event.type){
      case DisplayObjectEvent.MEDIA_SIZE_CHANGE:
        Console.log('*', 'new:', event.newWidth, event.newHeight, 'old', event.oldWidth, event.oldHeight);
        break;
    }
  }

  private function onDynamicStreamEvent(event:DynamicStreamEvent):void {
    Console.log('onDynamicStreamEvent', event.toString());
    dispatchExternalEvent(event.type);
  }

  private function onMediaErrorEvent(event:MediaErrorEvent):void {
    Console.log('onMediaErrorEvent', event.error.name, event.error.detail, event.error.errorID, event.error.message);
    dispatchExternalErrorEvent(event.type, event.error);
  }

  private function onDRMEvent(event:DRMEvent):void {
    Console.log('onDRMEvent', event.drmState);
    Console.log(event.toString());
  }

  private function onLayoutTargetEvent(event:LayoutTargetEvent):void {
    Console.log('onLayoutTargetEvent', event.toString());
  }

  protected function onMediaElementEvent(event:MediaElementEvent):void {
    Console.log('onMediaElementEvent', event.toString());
    switch (event.type) {
      case MediaElementEvent.METADATA_ADD:
        Console.log('MetaData Add', event.metadata);
        dispatchExternalEvent('loadedmetadata');
        break;

      case MediaElementEvent.METADATA_REMOVE:
        Console.log('MetaData Remove');
        break;

      case MediaElementEvent.TRAIT_ADD:
        Console.log('Trait Add', event.type, event.traitType);
        switch (event.traitType) {
          case MediaTraitType.TIME:
          if (_mediaPlayer.media.getTrait(MediaTraitType.TIME) != null) {
            var tt:TimeTrait = _mediaPlayer.media.getTrait(MediaTraitType.TIME) as TimeTrait;
            Console.log("time:", tt.currentTime, TimeUtil.formatAsTimeCode(tt.duration));
          }
          break;

          case MediaTraitType.DISPLAY_OBJECT:
          if (_mediaPlayer.media.getTrait(MediaTraitType.DISPLAY_OBJECT) != null) {
            var dt:DisplayObjectTrait = _mediaPlayer.media.getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
            Console.log("media size:", dt.mediaWidth, 'x', dt.mediaHeight);
          }
          break;
        }
        break;

      case MediaElementEvent.TRAIT_REMOVE:
        Console.log('Trait Removed', event.type, event.traitType);
        break;
    }
  }

  /* External API Methods */
  private function onSrcCalled(src:String):void {
    /*
     1. Create Resource
     2. Create Factory
     3. Create Layout Metadata
     4. Create Player
     5. Create Container
     6. Create Element
     */
    //dispose();
    createResource(src);
    createMediaFactory();
    createLayoutMetadata();
    createMediaContainer();
    createMediaElement();

    _mediaPlayer.media = _contentMediaElement;
  }

  /* Not sure if I want this here or in the tech
  private function dispose():void {
    if(_mediaPlayer && _mediaPlayer.media) {
      _mediaPlayer.media = null;
    }
    if(_resource) _resource = null;
    if(_contentMediaElement) _contentMediaElement = null;
    if(_mediaFactory) _mediaFactory = null;
    if(_layoutMetadata) _layoutMetadata = null;
    if(_mediaContainer) _mediaContainer = null;
  }
  */

  private function onAbortCalled(src:String):void {

  }

  private function onAutoplayCalled(src:String):void {

  }

  private function onEchoCalled(src:String):void {

  }

  private function onEndOfStreamCalled(src:String):void {

  }

  private function onGetPropertyCalled(pPropertyName:String):* {
    //Console.log('Get Prop Called', pPropertyName);
    switch (pPropertyName) {
      case 'seeking':
        return (_mediaPlayer) ? _mediaPlayer.seeking : false;
        break;

      case 'muted':
        return (_mediaPlayer) ? _mediaPlayer.muted : false;
        break;

      case 'volume':
        return (_mediaPlayer) ? _mediaPlayer.volume : 0;
        break;

      case 'currentTime':
        return (_mediaPlayer) ? _mediaPlayer.currentTime : 0;
        break;

      case 'duration':
        return (_mediaPlayer) ? _mediaPlayer.duration : 0;
        break;

      case 'buffered':
        return (_mediaPlayer) ? +_mediaPlayer.currentTime + _mediaPlayer.bufferTime : 0;
        break;

      default:
        Console.log('');
        Console.log('Get Prop Called', pPropertyName);
        break;
    }
  }

  private function onSetPropertyCalled(pPropertyName:String = "", pValue:* = null):void {
    Console.log('');
    Console.log('Set Prop Called', pPropertyName, pValue.toString() );
    Console.log('');
    var _app:Object = {model: {}};

    switch (pPropertyName) {
      case "duration":
        _app.model.duration = Number(pValue);
        break;
      case "mode":
        _app.model.mode = String(pValue);
        break;
      case "loop":
        _app.model.loop = _app.model.humanToBoolean(pValue);
        break;
      case "background":
        _app.model.backgroundColor = _app.model.hexToNumber(String(pValue));
        _app.model.backgroundAlpha = 1;
        break;
      case "eventProxyFunction":
        _app.model.jsEventProxyName = String(pValue);
        break;
      case "errorEventProxyFunction":
        _app.model.jsErrorEventProxyName = String(pValue);
        break;
      case "preload":
        _app.model.preload = _app.model.humanToBoolean(pValue);
        break;
      case "poster":
        _app.model.poster = String(pValue);
        break;
      case "src":
        // same as when vjs_src() is called directly
        onSrcCalled(pValue);
        break;
      case "currentTime":
        _mediaPlayer.seek(Number(pValue));
        break;
      case "currentPercent":
        _app.model.seekByPercent(Number(pValue));
        break;
      case "muted":
        _mediaPlayer.muted = (pValue.toString() === 'true');
        break;
      case "volume":
        _mediaPlayer.volume = pValue as Number;
        break;
      case "rtmpConnection":
        _app.model.rtmpConnectionURL = String(pValue);
        break;
      case "rtmpStream":
        _app.model.rtmpStream = String(pValue);
        break;
      default:
        Console.log('Prop not found');
        //_app.model.broadcastErrorEventExternally(ExternalErrorEventName.PROPERTY_NOT_FOUND, pPropertyName);
        break;
    }
  }

  private function onLoadCalled():void {
    Console.log('Load called on OSMF');
  }

  private function onPlayCalled():void {
    Console.log('Play called on OSMF');
    if (_mediaPlayer.canPlay){
      dispatchExternalEvent('play');
      _mediaPlayer.play();
    } else {
      Console.log('Can\'t play!');
    }
  }

  private function onPauseCalled():void {
    Console.log('Pause called on OSMF');
    if (_mediaPlayer.canPause) {
      dispatchExternalEvent('pause');
      _mediaPlayer.pause();
    } else {
      Console.log('Can\'t pause!');
    }
  }

  private function onPausedCalled():Boolean {
    Console.log('Paused called on OSMF');
    return _mediaPlayer.paused;
  }

  private function onResumeCalled():void {
    Console.log('Resume called on OSMF');
  }

  private function onStopCalled():void {

  }

  private function onStageResize(event:Event):void {
    if(_mediaContainer && stage) {
      _mediaContainer.width = stage.stageWidth;
      _mediaContainer.height = stage.stageHeight;
    }
  }

  // VideoJS Notifications
  private function dispatchExternalEvent(type:String, data:Object = null):void {
    if (loaderInfo.parameters['eventProxyFunction']) {
      ExternalInterface.call(loaderInfo.parameters['eventProxyFunction'], ExternalInterface.objectID, type.toLowerCase());
    }
  }
  private function dispatchExternalErrorEvent(type:String, error:Object):void {
    if(loaderInfo.parameters['errorEventProxyFunction']) {
      ExternalInterface.call(loaderInfo.parameters['errorEventProxyFunction'], ExternalInterface.objectID, type.toLowerCase(), error);
    }
  }

}
}
