package todoapp.gui
{
	import spark.components.supportClasses.SkinnableComponent;
	
	import net.fproject.di.Injector;

	public class TaskModuleView extends SkinnableComponent implements ITaskModuleView
	{
		public function TaskModuleView()
		{
			Injector.inject(this);
		}
		
		public function connectView():void
		{
		}
		
		public function disconnectView():void
		{
		}
	}
}