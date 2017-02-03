package todoapp.gui
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.LinkButton;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.DragEvent;
	import mx.events.PropertyChangeEvent;
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.List;
	import spark.components.TextInput;
	import spark.components.VGroup;
	import spark.components.supportClasses.SkinnableComponent;
	
	import net.fproject.di.Injector;
	
	import todoapp.component.DialogBase;
	import todoapp.component.EditColumnComponent;
	import todoapp.component.StatusDialog;
	import todoapp.event.TaskEvent;
	import todoapp.service.StatusService;
	
	public class TaskListComponent extends SkinnableComponent
	{
		[Bindable]
		public var taskCount:int;
		
		public static const DELETE_COLUMN:String = "deleteColumn";
		
		public function TaskListComponent()
		{
			super();
			Injector.inject(this);
			this.addEventListener(DragEvent.DRAG_DROP, dragDropHandler,true);
		}
		
		private var _dataProvider:ArrayCollection;
		
		[Bindable]
		public function get dataProvider():ArrayCollection
		{
			return _dataProvider;
		}
		
		public function set dataProvider(value:ArrayCollection):void
		{
			taskCount = 0;
			if (_dataProvider)
				_dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onDataProviderChange);
			_dataProvider = value;
			if (_dataProvider)
			{
				_dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, onDataProviderChange);
				taskCount = _dataProvider.length;
			}
		}
		
		
		[Bindable]
		public var dragEnabled:Boolean = true;
		
		[Bindable]
		public var dropEnabled:Boolean = true;
		
		[Bindable]
		public var dragMoveEnabled:Boolean = true;
		
		[Bindable]
		public var status:Object;
		
		[Bindable]
		public var statusField:String = 'status';
		
		public function get statusService():StatusService
		{
			return StatusService.getInstance();
		}
		
		public function addButton_clickHandler(event:MouseEvent):void
		{
			if (taskNameInput && taskNameInput.text && taskNameInput.text.length > 0){
				var data:String = taskNameInput.text;
				dispatchEvent(new TaskEvent(TaskEvent.ADD_TASK,data));
				
				taskNameInput.text = '';
			}
		}
		
		public function editColumnButton_clickHandler(event:MouseEvent):void
		{
			var statusDialog:StatusDialog = DialogBase.getInstance(StatusDialog) as StatusDialog;
			statusDialog.show(status,this,false,
				function():void
				{
					statusService.save(status);
				}
			);
		}
		
		public function removeColumnButton_clickHandler(event:MouseEvent=null):void
		{
			dispatchRemoveColumnEvent();
		}
		
		public function dispatchRemoveColumnEvent():void
		{
			this.dispatchEvent(new Event(DELETE_COLUMN));
		}
		
		public function quickAddLinkButton_clickHandler(event:MouseEvent):void
		{
			if (quickAddGroup)
				quickAddGroup.visible = quickAddGroup.includeInLayout = true;
		}
		
		public function cancelLinkButton_clickHandler(event:MouseEvent):void
		{
			if (quickAddGroup)
				quickAddGroup.visible = quickAddGroup.includeInLayout = false;
		}
		
		public function dragDropHandler(event:DragEvent):void
		{
			var itemsArray:Vector.<Object>=
				event.dragSource.dataForFormat("itemsByIndex") as Vector.<Object>;
			for each (var item:Object in itemsArray)
			{
				if (item.hasOwnProperty(statusField))
					item[statusField] = status;
			}
		}
		
		public function onDataProviderChange(event:CollectionEvent):void
		{
			if (event.kind == CollectionEventKind.ADD)
			{
				var saveItems:Array = new Array;
				for each (var item:Object in event.items)
				{
					var data:Object = (item is PropertyChangeEvent) ? PropertyChangeEvent(item).source : item;
					if (data.hasOwnProperty(statusField))
						data[statusField] = status;
				}
			}
			taskCount = dataProvider.length;
		}
		
		[SkinPart(required="true",type="static")]
		[PropertyBinding (text="status.name@")]
		public var statusNameLabel:Label;
		
		[SkinPart(required="true",type="static")]
		[EventHandling(event="click", handler="quickAddLinkButton_clickHandler")]
		public var quickAddLinkButton:LinkButton;
		
		[SkinPart(required="true",type="static")]
		[EventHandling(event="click", handler="cancelLinkButton_clickHandler")]
		public var cancelLinkButton:LinkButton;
		
		[SkinPart(required="true",type="static")]
		public var quickAddGroup:VGroup;
		
		[SkinPart(required="true",type="static")]
		public var taskNameInput:TextInput;
		
		[SkinPart(required="true",type="static")]
		[EventHandling(event="click", handler="addButton_clickHandler")]
		public var addButton:Button;
		
		[SkinPart(required="true",type="static")]
		[EventHandling(event="click", handler="editColumnButton_clickHandler")]
		public var editColumnButton:Button;
		
		[SkinPart(required="true",type="static")]
		[EventHandling(event="click", handler="removeColumnButton_clickHandler")]
		public var removeColumnButton:Button;
		
		[SkinPart(required="true",type="static")]
		[PropertyBinding (label="taskCount@")]
		public var editColumnComponent:EditColumnComponent;
		
		[SkinPart(required="true",type="static")]
		[PropertyBinding (dragEnabled="dragEnabled@")]
		[PropertyBinding (dropEnabled="dropEnabled@")]
		[PropertyBinding (dragMoveEnabled="dragMoveEnabled@")]
		[PropertyBinding (dataProvider="dataProvider@")]
		public var taskList:List;
	}
}