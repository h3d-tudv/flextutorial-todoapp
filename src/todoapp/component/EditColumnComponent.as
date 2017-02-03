package todoapp.component
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import spark.components.PopUpAnchor;
	import spark.components.SkinnableContainer;
	
	import net.fproject.di.Injector;

	public class EditColumnComponent extends SkinnableContainer
	{
		[Bindable]
		public var label:String;
		
		private var _headerRectangle:Rectangle;
		private var _contentGroupRectangle:Rectangle;
		
		public function EditColumnComponent()
		{
			super();
			Injector.inject(this);
		}
		
		public function open():void
		{
			popUpAnchor.displayPopUp = true;
			callLater(observeMouse);
			headerButton.currentState="open";
		}
		
		public function close():void
		{
			stopMouseObserve();
			popUpAnchor.displayPopUp = false;	
			headerButton.currentState="close";
		}
		
		private function observeMouse():void
		{
			if (contentGroup == null)
				return;
			
			var point:Point=localToGlobal(new Point());
			_headerRectangle = new Rectangle(point.x,point.y,headerButton.width,headerButton.height);
			_contentGroupRectangle = new Rectangle(point.x, point.y + headerButton.height, contentGroup.width, contentGroup.height);
			stage.addEventListener(MouseEvent.MOUSE_MOVE,checkMouseOut);
		}
		
		private function checkMouseOut(event:MouseEvent):void
		{
			if(stage != null && !_headerRectangle.contains(stage.mouseX,stage.mouseY) && !_contentGroupRectangle.contains(stage.mouseX,stage.mouseY))
				close();
		}
		
		private function stopMouseObserve():void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,checkMouseOut);			
		}
		
		public function headerButton_mouseOverHandler(event:MouseEvent):void
		{
			if (!popUpAnchor.displayPopUp)
				open();
		}
		
		[SkinPart(required="true",type="static")]
		[EventHandling(event="mouseOver",handler="headerButton_mouseOverHandler")]
		[PropertyBinding(label="label@")]
		public var headerButton:DropDownGroupHeader;
		
		[SkinPart(required="true",type="static")]
		public var popUpAnchor:PopUpAnchor;
	}
}