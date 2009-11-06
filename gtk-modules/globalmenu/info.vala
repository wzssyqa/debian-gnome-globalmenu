public class MenuBarInfo {
	public enum QuirkType {
		/* usual thing */
		NONE = 0,
		/* There is already a global menu on the window */
		NOT_A_GLOBAL = 1,
		/* for GtkMenuBar in a bonobo plug */
		HIDE_PARENT = 2,
		/* for wxGTK 2.8.10 programs */
		CHANGE_STYLE = 4,
	}
	public QuirkType quirks;

	private weak Gtk.MenuBar _menubar;
	public Gtk.MenuBar menubar {
		get { return _menubar; }
		private set { _menubar = value; }
	
	}
	private bool dirty = false;
	private Gdk.Window? event_window {
		get {
			if(menubar == null) return null;
			var toplevel = menubar.get_toplevel();
			if(toplevel == null) return null;
			return toplevel.window;
		}
	}

	private static void menubar_disposed(void* data, Object? object) {
		/*
		 * the only reference to MenuBarInfo is held by the menubar.
		 * when menubar is disposed, the weak_ref_notify is invoked before
		 * its reference on MenuBarInfo is released.
		 *
		 * When this callback is invoked, we are 100% sure that
		 * the menubar is already invalid, and Gtk will take care of all
		 * the signal removal stuff. Therefore we simply detach the info
		 * from the menubar.
		 *
		 */
		((MenuBarInfo*)data)->menubar = null;
	}


	public MenuBarInfo (Gtk.MenuBar menubar) {
		this.menubar = menubar;
		menubar.weak_ref(menubar_disposed, this);
	}

	~MenuBarInfo() {
		message("dispose MenuBarInfo");
		release_menubar();
	}

	private void release_menubar() {
		if(menubar == null) return;
		menubar.weak_unref(menubar_disposed, this);
	}

	public void queue_changed() {
		if(dirty == false) {
			dirty = true;
			Timeout.add(300, send_globalmenu_message);
		}
	}

	[CCode (cname = "gdk_window_set_menu_context")]
	protected extern void gdk_window_set_menu_context (Gdk.Window window, string? context);
	private bool send_globalmenu_message() {
		dirty = false;
		// send the message
		/*
		gdk_window_set_menu_context(event_window, 
				Serializer.to_string(menubar)
				);*/
		return true;
	}

}
