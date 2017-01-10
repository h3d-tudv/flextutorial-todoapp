package todoapp.gui
{
	import mx.events.FlexEvent;
	
	import spark.events.IndexChangeEvent;
	
	import todoapp.component.TaskDetail;
	import todoapp.model.Task;
	
	public class TaskListView extends TaskModuleView
	{
		[Bindable]
		public var selectedTask:Task;
		
		public function TaskListView()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, module_creationComplete);
		}
		
		protected function module_creationComplete(event:FlexEvent):void
		{
			if (taskListComponent && taskListComponent.taskList)
				taskListComponent.taskList.addEventListener(IndexChangeEvent.CHANGE, taskList_changeHandler);
			loadViewData();
		}
		
		override public function connectView():void
		{
			loadViewData();
		}
		
		public function loadViewData():void
		{
			if (taskListComponent)
				taskListComponent.loadViewData();
			selectedTask = null;
		}
		
		protected function taskList_changeHandler(event:IndexChangeEvent):void
		{
			if (taskListComponent.taskList)
				selectedTask = taskListComponent.taskList.selectedItem;
		}
		
		[SkinPart(required="true",type="static")]
		public var taskListComponent:TaskListComponent;
		
		[SkinPart(required="true",type="static")]
		[PropertyBinding(task="selectedTask@")]
		public var taskDetail:TaskDetail;
	}
}