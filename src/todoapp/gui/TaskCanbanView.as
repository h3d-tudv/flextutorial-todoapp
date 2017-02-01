package todoapp.gui
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.controls.Alert;
	import mx.controls.LinkButton;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;
	
	import spark.components.HGroup;
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	
	import net.fproject.utils.StringUtil;
	
	import todoapp.component.DialogBase;
	import todoapp.component.StatusDialog;
	import todoapp.component.TaskDetail;
	import todoapp.event.TaskEvent;
	import todoapp.model.Status;
	import todoapp.model.Task;
	import todoapp.service.StatusService;
	import todoapp.service.TaskService;
	
	public class TaskCanbanView extends TaskModuleView
	{
		[Bindable]
		public var selectedTask:Task;
		
		[Bindable]
		public var doingTasks:ArrayCollection;
		
		[Bindable]
		public var doneTasks:ArrayCollection;
		
		[Bindable]
		public var statusCollection:ArrayCollection;
		
		[Bindable]
		public var doingStatus:Status;
		
		[Bindable]
		public var doneStatus:Status;
		
		protected var statusCount:int = 0;
		
		public var statusDictionary:Dictionary = new Dictionary;
		
		public function TaskCanbanView()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, module_creationComplete);
		}
		
		protected function module_creationComplete(event:FlexEvent):void
		{
			loadViewData();
		}
		
		public function get taskService():TaskService
		{
			return TaskService.getInstance();
		}
		
		public function get statusService():StatusService
		{
			return StatusService.getInstance();
		}
		
		override public function connectView():void
		{
			if (contentGroup)
				loadViewData();
		}
		
		public function loadViewData():void
		{
			while (statusCount)
				contentGroup.removeElementAt(--statusCount);
			statusCollection = new ArrayCollection;
			
			statusService.find(null,
				function(result:ArrayCollection):void
				{
					for each (var status:Status in result)
					{
						createNewColumn(status);
					}
				}
			);
			
			selectedTask = null;
		}
		
		protected override function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if(instance == contentGroup)
				loadViewData();
		}
		
		protected function collection_collectionChangeHandler(event:CollectionEvent):void
		{
			if (event.kind == CollectionEventKind.UPDATE)
			{
				var saveItems:Array = new Array;
				for each (var item:Object in event.items)
				{
					var data:Object = (item is PropertyChangeEvent) ? PropertyChangeEvent(item).source : item;
					if (data is Task && Task(data).status && statusDictionary[String(Task(data).status.id)] != event.target)
					{
						event.target.removeEventListener(CollectionEvent.COLLECTION_CHANGE,
							collection_collectionChangeHandler);
						statusDictionary[String(Task(data).status.id)].removeEventListener(CollectionEvent.COLLECTION_CHANGE,
							collection_collectionChangeHandler);
						
						ArrayCollection(event.target).removeItem(data);
						ArrayCollection(statusDictionary[String(Task(data).status.id)]).addItem(data);
						
						event.target.addEventListener(CollectionEvent.COLLECTION_CHANGE,
							collection_collectionChangeHandler, false, 0, true);
						statusDictionary[String(Task(data).status.id)].addEventListener(CollectionEvent.COLLECTION_CHANGE,
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
				var dataProvider:IList = TaskListComponent(event.target).taskList.dataProvider;
				var newTask:Task = new Task;		
				newTask.name = event.data as String;
				dataProvider.addItem(newTask);
				taskService.save(newTask);
			}
		}
		
		public function createNewColumn(newStatus:Status):void
		{
			statusCollection.addItem(newStatus);
			var newColumn:TaskListComponent = new TaskListComponent;
			newColumn.status = newStatus;
			newColumn.statusField = 'status';
			statusDictionary[newStatus.id] = newColumn.dataProvider = new ArrayCollection;
			newColumn.percentHeight = 100;
			
			//addEvent
			newColumn.addEventListener(IndexChangeEvent.CHANGE, taskList_changeHandler,true);
			newColumn.addEventListener(TaskEvent.ADD_TASK, onAddTaskHandler);
			newColumn.addEventListener(TaskEvent.DELETE_TASK, onDeleteTaskHandler,true);
			
			//load data
			taskService.find({"status.id":newStatus.id},
				function(result:ArrayCollection):void
				{
					statusDictionary[newStatus.id] = result;
					for each (var task:Task in result)
					{
						task.status = newStatus;
					}
					newColumn.dataProvider = result;
					result.addEventListener(CollectionEvent.COLLECTION_CHANGE,
						collection_collectionChangeHandler, false, 0, true);
				}
			);
			
			//work-around vì:
			//nếu chưa có dữ liệu, list sẽ chưa display --> first element index = -1 --> Hàm caculate drop position bị lỗi
			var newTask:Task = new Task;
			newTask.name = "hehe";
			newTask.status = newStatus;
			
			newColumn.dataProvider.addItem(newTask);
			contentGroup.addElementAt(newColumn,statusCount++);
		}
		
		public function createColumnButton_clickHandler(event:MouseEvent):void
		{
			var newStatus:Status = new Status;
			var statusDialog:StatusDialog = DialogBase.getInstance(StatusDialog) as StatusDialog;
			statusDialog.show(newStatus,this,false,
				function():void
				{
					if (!(StringUtil.isBlank(newStatus.name)))
						statusService.save(newStatus,
							function(result:Object):void
							{
								createNewColumn(newStatus);
							}
						);
				}
			);
		}
		
		
		[SkinPart(required="true",type="static")]
		public var contentGroup:HGroup;
			
		[SkinPart(required="true",type="static")]
		[EventHandling(event="click", handler="createColumnButton_clickHandler")]
		public var createColumnButton:LinkButton;
		
		[SkinPart(required="true",type="static")]
		[PropertyBinding(task="selectedTask@")]
		[PropertyBinding(statusCollection="statusCollection@")]
		public var taskDetail:TaskDetail;
	}
}