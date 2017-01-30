package todoapp.component
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import mx.binding.utils.BindingUtils;
	import mx.managers.PopUpManager;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.TitleWindow;
	
	import net.fproject.di.Injector;
	
	[EventHandling(event="flash.events.KeyboardEvent.KEY_DOWN",handler="_dialog_keyDown")]
	[EventHandling(event="mx.events.CloseEvent.CLOSE",handler="_dialog_close")]
	public class DialogBase extends TitleWindow
	{
		
		
		public function DialogBase()
		{
			super();
			Injector.inject(this);
		}
		
		private static var instances:Object = {};
		public static var openingDialogs:Dictionary = new Dictionary;
		private var _closeFunction:Function;
		
		protected var _dialogCancelled:Boolean;
		
		public function get dialogCancelled():Boolean
		{
			return _dialogCancelled;
		}
		
		protected var closingCancelled:Boolean;
		
		/**
		 * Instance factory method
		 * @param clazz the class that extends this DialogBase class
		 * @return the singleton instance of specified class.
		 * 
		 */
		public static function getInstance(clazz:Class):DialogBase
		{
			var className:String = getQualifiedClassName(clazz);
			if(instances[className] == undefined)
				instances[className] = new clazz();
			return instances[className];
		}
		
		public function showDialog(parent:DisplayObject, modal:Boolean, closeFunction:Function = null):void
		{
			_closeFunction = closeFunction;
			_dialogCancelled = false;
			onInitDialog(parent, modal);
			PopUpManager.removePopUp(this);
			PopUpManager.addPopUp(this, parent, modal);
			PopUpManager.centerPopUp(this);
			openingDialogs[this] = true;
			
			onDialogShowed(parent, modal);
		}
		
		public function _dialog_close(e:Event):void
		{
			cancel();
		}
		
		/**
		 * 
		 * Event handler for dialog keydown event
		 * 
		 */
		public final function _dialog_keyDown(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.ESCAPE)
				cancel();
			else if (event.keyCode == Keyboard.ENTER)
			{
				switch(getFocus())
				{
					case okButton:
					{
						submit();
						break;
					}
					case cancelButton:
					{
						cancel();
						break;
					}
						
					default:
					{
						break;
					}
				}
				
			}
		}
		
		public final function okButton_click(e:MouseEvent):void
		{
			submit();
		}
		
		/**
		 * This method is called before the PopupManager shows this dialog up. 
		 * @param parent
		 * @param modal
		 * 
		 */
		protected function onInitDialog(parent:DisplayObject, modal:Boolean) : void
		{
			//Abstract method
		}
		
		/**
		 * This method is called before the PopupManager shows this dialog up. 
		 * @param parent
		 * @param modal
		 * 
		 */
		protected function onDialogShowed(parent:DisplayObject, modal:Boolean) : void
		{
			//Abstract method
		}
		
		/**
		 * 
		 * This method is called before the PopupManager close this dialog down. 
		 */
		protected function onCloseDialog() : void
		{
			//Abstract method
		}
		
		/**
		 * Apply the business when submitting dialog 
		 * 
		 */
		protected function apply():void
		{
			//Abstract method
		}
		
		/**
		 * Cancel the dialog
		 * 
		 */
		public final function cancel():void
		{
			_dialogCancelled = true;
			closingCancelled = false;
			closeDialog();
		}
		
		protected function closeDialog():void
		{
			if(closingCancelled)
				return;
			if(openingDialogs[this])
			{
				onCloseDialog();
				PopUpManager.removePopUp(this);
				if (_closeFunction != null)
					_closeFunction(this);
			}
			openingDialogs[this] = false;
		}
		
		/**
		 * Submit the dialog 
		 * 
		 */
		public final function submit():void
		{
			_dialogCancelled = false;
			closingCancelled = false;
			apply();
			closeDialog();
		}
		
		protected override function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			if(instance == contentGroup)
				BindingUtils.bindSetter(
					function(g:Group):void
					{
						if(g != null)
							contentGroup.addElement(g);
					}, this, "dialogContent");
		}
		
		[Bindable]
		[SkinPart(required="false", type="static")]
		public var dialogContent:Group;
		
		[Bindable]
		[SkinPart(required="false", type="static")]
		[EventHandling(event="flash.events.MouseEvent.CLICK",handler="okButton_click")]
		public var okButton:Button;
		
		[Bindable]
		[SkinPart(required="false", type="static")]
		[EventHandling(event="flash.events.MouseEvent.CLICK",handler="_dialog_close")]
		public var cancelButton:Button;
	}
}