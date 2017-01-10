package todoapp.gui
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.AdvancedDataGrid;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	import mx.events.PropertyChangeEvent;
	
	import spark.components.Button;
	import spark.components.TextInput;
	import spark.events.IndexChangeEvent;
	
	import todoapp.component.TaskDetail;
	import todoapp.event.TaskEvent;
	import todoapp.model.Task;
	import todoapp.service.TaskService;
	
	public class TaskGridView extends TaskModuleView
	{
		[Bindable]
		public var selectedTask:Task;
		
		[Bindable]
		public var tasks:ArrayCollection;
		
		public function TaskGridView()
		{
			super();
			addEventListener(FlexEvent.INITIALIZE, module_initializeHandler);
			addEventListener(FlexEvent.CREATION_COMPLETE, module_creationComplete);
		}
		
		public function get taskService():TaskService
		{
			return TaskService.getInstance();
		}
		
		protected function module_initializeHandler(event:FlexEvent):void
		{
			loadViewData();
		}
		
		
		protected function module_creationComplete(event:FlexEvent):void
		{
			if (taskGrid)
				taskGrid.addEventListener(IndexChangeEvent.CHANGE, taskGrid_changeHandler);
		}
		
		override public function connectView():void
		{
			loadViewData();
		}
		
		public function loadViewData():void
		{
			taskService.find(
				function(result:ArrayCollection):void
				{
					if (tasks)
						tasks.removeEventListener(CollectionEvent.COLLECTION_CHANGE,
							collection_collectionChangeHandler);
					tasks = result;
					tasks.addEventListener(CollectionEvent.COLLECTION_CHANGE,
						collection_collectionChangeHandler, false, 0, true);
				}
			);
			selectedTask = null;
		}
		
		protected function collection_collectionChangeHandler(event:CollectionEvent):void
		{
			if (event.kind == CollectionEventKind.ADD || event.kind == CollectionEventKind.UPDATE)
			{
				var saveItems:Array = new Array;
				for each (var item:Object in event.items)
				{
					var data:Object = (item is PropertyChangeEvent) ? PropertyChangeEvent(item).source : item;
					saveItems.push(data);
				}
				taskService.batchSave(saveItems);
			}
			else if (event.kind == CollectionEventKind.REMOVE)
			{
				var deleteItems:Array = new Array;
				for each (item in event.items)
				{
					data = (item is PropertyChangeEvent) ? PropertyChangeEvent(item).source : item;
					deleteItems.push(data);
				}
				taskService.batchRemove(deleteItems);
			}
		}
		
		public function addButton_clickHandler(event:MouseEvent):void
		{
			if (taskNameInput && taskNameInput.text && taskNameInput.text.length > 0){
				var newTask:Task = new Task;		
				newTask.name = taskNameInput.text;
				tasks.addItem(newTask);
				taskNameInput.text = '';
			}
		}
		
		public function onDeleteTaskHandler(event:TaskEvent):void
		{
			if (event.data is Task && tasks)
				Alert.show("Are you sure you want to delete this task", "Delete Task confirm", Alert.OK | Alert.CANCEL,
					FlexGlobals.topLevelApplication as Sprite,
					function(e:CloseEvent):void
					{
						if((e.detail & Alert.OK) == Alert.OK)
						{
							tasks.removeItem(event.data);
						}
					});	
		}
		
		protected function taskGrid_changeHandler(event:ListEvent):void
		{
			if (taskGrid)
				selectedTask = taskGrid.selectedItem as Task;
		}
		
		[SkinPart(required="true",type="static")]
		[EventHandling(event="click", handler="addButton_clickHandler")]
		public var addButton:Button;
		
		[SkinPart(required="true",type="static")]
		public var taskNameInput:TextInput;
		
		[SkinPart(required="true",type="static")]
		[PropertyBinding (dataProvider="tasks@")]
		[EventHandling(event="deleteTask", handler="onDeleteTaskHandler")]
		public var taskGrid:AdvancedDataGrid;
		
		[SkinPart(required="true",type="static")]
		[PropertyBinding(task="selectedTask@")]
		public var taskDetail:TaskDetail;
	}
}