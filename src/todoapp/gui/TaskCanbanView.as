package todoapp.gui
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;
	
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	
	import todoapp.component.TaskDetail;
	import todoapp.model.Task;
	import todoapp.service.TaskService;
	
	public class TaskCanbanView extends TaskModuleView
	{
		[Bindable]
		public var selectedTask:Task;
		
		[Bindable]
		public var doingTasks:ArrayCollection;
		
		[Bindable]
		public var doneTasks:ArrayCollection;
		
		public function TaskCanbanView()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, module_creationComplete);
		}
		
		protected function module_creationComplete(event:FlexEvent):void
		{
			if (doingTaskList)
				doingTaskList.addEventListener(IndexChangeEvent.CHANGE, taskList_changeHandler,true);
			if (doneTaskList)
				doneTaskList.addEventListener(IndexChangeEvent.CHANGE, taskList_changeHandler,true);
			loadViewData();
		}
		
		public function get taskService():TaskService
		{
			return TaskService.getInstance();
		}
		
		override public function connectView():void
		{
			loadViewData();
		}
		
		public function loadViewData():void
		{
			taskService.find({done:false},
				function(result:ArrayCollection):void
				{
					if (doingTasks)
						doingTasks.removeEventListener(CollectionEvent.COLLECTION_CHANGE,
							collection_collectionChangeHandler);
					 doingTasks = result;
					 doingTasks.addEventListener(CollectionEvent.COLLECTION_CHANGE,
						collection_collectionChangeHandler, false, 0, true);
				}
			);
			
			taskService.find({done:true},
				function(result:ArrayCollection):void
				{
					if (doneTasks)
					 doneTasks.removeEventListener(CollectionEvent.COLLECTION_CHANGE,
					collection_collectionChangeHandler);
					 doneTasks = result;
					 doneTasks.addEventListener(CollectionEvent.COLLECTION_CHANGE,
					collection_collectionChangeHandler, false, 0, true);
				}
			);
			
			
			/*if (doneTaskList)
				doneTaskList.loadViewData();
			if (doingTaskList)
				doingTaskList.loadViewData();*/
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
		
		protected function taskList_changeHandler(event:Event):void
		{
			if (event is IndexChangeEvent && IndexChangeEvent(event).target is List && List(IndexChangeEvent(event).target).selectedItem is Task)
				selectedTask = List(event.target).selectedItem;
		}
		
		[SkinPart(required="true",type="static")]
		[PropertyBinding(dataProvider="doingTasks@")]
		public var doingTaskList:TaskListComponent;
		
		[SkinPart(required="true",type="static")]
		[PropertyBinding(dataProvider="doneTasks@")]
		public var doneTaskList:TaskListComponent;
		
		[SkinPart(required="true",type="static")]
		[PropertyBinding(task="selectedTask@")]
		public var taskDetail:TaskDetail;
	}
}