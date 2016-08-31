#!/bin/bash
cd /var/www/openbasiskaart
STDOUT_LOG=update_site_hook_stdout.log
STDERR_LOG=update_site_hook_stderr.log
date > /tmp/$STDOUT_LOG
date > /tmp/$STDERR_LOG
git pull >> /tmp/$STDOUT_LOG 2>> /tmp/$STDERR_LOG
if [ $? -ne 0 ]; then
	echo -e 'Content-Type: text/plain\n'
	echo -e 'Something went wrong executing "git pull":\n' > /tmp/fail_msg
	echo -e 'stdout:\n' >> /tmp/fail_msg
	cat /tmp/$STDOUT_LOG >> /tmp/fail_msg
	echo -e '\nstderr:\n' >> /tmp/fail_msg
	cat /tmp/$STDERR_LOG >> /tmp/fail_msg
	echo -e '\nenvironment:\n' >> /tmp/fail_msg
	/usr/bin/env >> /tmp/fail_msg
	echo -e '\npost data:\n' >> /tmp/fail_msg
	while read line; do
		echo $line >> /tmp/fail_msg
	done
	cat /tmp/fail_msg
	mail -s "openbasiskaart site update web hook failed" support@opengeogroep.nl -a "From: $SERVER_ADMIN" < /tmp/fail_msg
	rm /tmp/fail_msg
else
	echo -e 'Content-Type: text/plain\n\nDone.'
fi
cat /tmp/$STDOUT_LOG >> $STDOUT_LOG
cat /tmp/$STDERR_LOG >> $STDERR_LOG
rm /tmp/$STDOUT_LOG
rm /tmp/$STDERR_LOG

