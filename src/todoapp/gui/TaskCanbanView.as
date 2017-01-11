package todoapp.gui
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;
	
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	
	import todoapp.component.TaskDetail;
	import todoapp.event.TaskEvent;
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
		
		public var statusCollection:Dictionary = new Dictionary;
		
		public function TaskCanbanView()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, module_creationComplete);
		}
		
		protected function module_creationComplete(event:FlexEvent):void
		{
			if (doingTaskList)
			{
				doingTaskList.addEventListener(IndexChangeEvent.CHANGE, taskList_changeHandler,true);
				doingTaskList.addEventListener(TaskEvent.ADD_TASK, onAddTaskHandler);
				doingTaskList.addEventListener(TaskEvent.DELETE_TASK, onDeleteTaskHandler,true);
			}
			if (doneTaskList)
			{
				doneTaskList.addEventListener(IndexChangeEvent.CHANGE, taskList_changeHandler,true);
				doneTaskList.addEventListener(TaskEvent.ADD_TASK, onAddTaskHandler);
				doneTaskList.addEventListener(TaskEvent.DELETE_TASK, onDeleteTaskHandler,true);
			}
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
					statusCollection['false'] = doingTasks = result;
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
					statusCollection['true'] = doneTasks = result;
					doneTasks.addEventListener(CollectionEvent.COLLECTION_CHANGE,
						collection_collectionChangeHandler, false, 0, true);
				}
			);
			
			selectedTask = null;
		}
		
		protected function collection_collectionChangeHandler(event:CollectionEvent):void
		{
			if (event.kind == CollectionEventKind.UPDATE)
			{
				var saveItems:Array = new Array;
				for each (var item:Object in event.items)
				{
					var data:Object = (item is PropertyChangeEvent) ? PropertyChangeEvent(item).source : item;
					if (data is Task && statusCollection[String(Task(data).done)] != event.target)
					{
						event.target.removeEventListener(CollectionEvent.COLLECTION_CHANGE,
							collection_collectionChangeHandler);
						
						ArrayCollection(event.target).removeItem(data);
						ArrayCollection(statusCollection[String(Task(data).done)]).addItem(data);
						
						event.target.addEventListener(CollectionEvent.COLLECTION_CHANGE,
							collection_collectionChangeHandler, false, 0, true);
					}
					saveItems.push(data);
				}
				taskService.batchSave(saveItems);
			}
		}
		
		protected function taskList_changeHandler(event:Event):void
		{
			if (event is IndexChangeEvent && IndexChangeEvent(event).target is List && List(IndexChangeEvent(event).target).selectedItem is Task)
				selectedTask = List(event.target).selectedItem;
		}
		
		public function onDeleteTaskHandler(event:TaskEvent):void
		{
			if (event.data is Task && event.target is List)
			{
				Alert.show("Are you sure you want to delete this task", "Delete Task confirm", Alert.OK | Alert.CANCEL,
					FlexGlobals.topLevelApplication as Sprite,
					function(e:CloseEvent):void
					{
						if((e.detail & Alert.OK) == Alert.OK)
						{
							ArrayCollection(List(event.target).dataProvider).removeItem(event.data);
							taskService.remove(event.data);
						}
					});	
			}
		}
		
		public function onAddTaskHandler(event:TaskEvent):void
		{
			if (event.data && event.target is TaskListComponent)
			{
				var dataProvider:ArrayCollection;
				switch (event.target) {
					case doingTaskList:
						dataProvider = doingTasks;
						break;
					case doneTaskList:
						dataProvider = doneTasks;
						break;
				}
				var newTask:Task = new Task;		
				newTask.name = event.data as String;
				dataProvider.addItem(newTask);
				taskService.save(newTask);
			}
		}
		
		[SkinPart(required="true",type="static")]
		[PropertyBinding(dataProvider="doingTasks@")]
		[PropertyBinding(statusField="'done'")]
		[PropertyBinding(status="false")]
		public var doingTaskList:TaskListComponent;
		
		[SkinPart(required="true",type="static")]
		[PropertyBinding(dataProvider="doneTasks@")]
		[PropertyBinding(statusField="'done'")]
		[PropertyBinding(status="true")]
		public var doneTaskList:TaskListComponent;
		
		[SkinPart(required="true",type="static")]
		[PropertyBinding(task="selectedTask@")]
		public var taskDetail:TaskDetail;
	}
}