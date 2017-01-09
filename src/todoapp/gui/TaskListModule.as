package todoapp.gui
{
	import mx.events.FlexEvent;
	
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.IndexChangeEvent;
	
	import net.fproject.di.Injector;
	
	import todoapp.component.TaskDetail;
	import todoapp.model.Task;
	
	public class TaskListModule extends SkinnableComponent
	{
		[Bindable]
		public var selectedTask:Task;
		
		public function TaskListModule()
		{
			super();
			Injector.inject(this);
			addEventListener(FlexEvent.CREATION_COMPLETE, module_creationComplete);
		}
		
		protected function module_creationComplete(event:FlexEvent):void
		{
			if (taskListView && taskListView.taskList)
				taskListView.taskList.addEventListener(IndexChangeEvent.CHANGE, taskList_changeHandler);
		}
		
		protected function taskList_changeHandler(event:IndexChangeEvent):void
		{
			if (taskListView.taskList)
				selectedTask = taskListView.taskList.selectedItem;
		}
		
		[SkinPart(required="true",type="static")]
		public var taskListView:TaskListView;
		
		[SkinPart(required="true",type="static")]
		[PropertyBinding(task="selectedTask@")]
		public var taskDetail:TaskDetail;
	}
}