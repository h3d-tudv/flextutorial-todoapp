package todoapp.gui
{
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.DragEvent;
	import mx.events.PropertyChangeEvent;
	
	import spark.components.Button;
	import spark.components.List;
	import spark.components.TextInput;
	import spark.components.supportClasses.SkinnableComponent;
	
	import net.fproject.di.Injector;
	
	import todoapp.event.TaskEvent;
	
	public class TaskListComponent extends SkinnableComponent
	{
		public function TaskListComponent()
		{
			super();
			Injector.inject(this);
			this.addEventListener(DragEvent.DRAG_DROP, dragDropHandler,true);
		}
		
		/*[Bindable]
		public var dataProvider:ArrayCollection;*/
		
		private var _dataProvider:ArrayCollection;

		[Bindable]
		public function get dataProvider():ArrayCollection
		{
			return _dataProvider;
		}

		public function set dataProvider(value:ArrayCollection):void
		{
			if (_dataProvider)
				_dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onDataProviderChange);
			_dataProvider = value;
			if (_dataProvider)
				_dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, onDataProviderChange);
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
		
		public function addButton_clickHandler(event:MouseEvent):void
		{
			if (taskNameInput && taskNameInput.text && taskNameInput.text.length > 0){
				var data:String = taskNameInput.text;
				dispatchEvent(new TaskEvent(TaskEvent.ADD_TASK,data));
					
				taskNameInput.text = '';
			}
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
		}
			
		[SkinPart(required="true",type="static")]
		public var taskNameInput:TextInput;
		
		[SkinPart(required="true",type="static")]
		[EventHandling(event="click", handler="addButton_clickHandler")]
		public var addButton:Button;
		
		[SkinPart(required="true",type="static")]
		[PropertyBinding (dragEnabled="dragEnabled@")]
		[PropertyBinding (dropEnabled="dropEnabled@")]
		[PropertyBinding (dragMoveEnabled="dragMoveEnabled@")]
		[PropertyBinding (dataProvider="dataProvider@")]
		public var taskList:List;
	}
}