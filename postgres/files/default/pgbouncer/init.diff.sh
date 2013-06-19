@@ -28,6 +28,12 @@
 
 . /lib/lsb/init-functions
 
+# create socket directory
+if [ -d /var/run/postgresql ]; then
+  chmod 2775 /var/run/postgresql
+else
+  install -d -m 2775 -o postgres -g postgres /var/run/postgresql
+fi
 
 is_running() {
 	pidofproc -p $PIDFILE $DAEMON >/dev/null
@@ -39,7 +45,7 @@
 		if is_running; then
 			:
 		else
-			su -c "$DAEMON $OPTS 2> /dev/null &" - postgres
+			su -c "$DAEMON $OPTS &" - postgres
 		fi
 	else
 		log_warning_msg "pgbouncer daemon disabled in /etc/default/pgbouncer"
