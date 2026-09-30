#ifndef FLUTTER_MY_APPLICATION_H_
#define FLUTTER_MY_APPLICATION_H_

#if defined(__has_include)
  #if __has_include(<gtk/gtk.h>)
    #define HAVE_GTK 1
    #include <gtk/gtk.h>
  #endif
#else
  #define HAVE_GTK 1
  #include <gtk/gtk.h>
#endif

#ifndef HAVE_GTK
// Fallback stub declarations for IDE language servers on non-Linux platforms (e.g. Windows)
typedef struct _MyApplication MyApplication;
#else
G_DECLARE_FINAL_TYPE(MyApplication,
                     my_application,
                     MY,
                     APPLICATION,
                     GtkApplication)
#endif

/**
 * my_application_new:
 *
 * Creates a new Flutter-based application.
 *
 * Returns: a new #MyApplication.
 */
MyApplication* my_application_new();

#endif  // FLUTTER_MY_APPLICATION_H_
