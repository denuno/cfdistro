/**
 * 
 * Copyright  2000-2002,2004 The Apache Software Foundation
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 * 
 */

package org.mike.Ant;

import org.apache.tools.ant.*;
import org.apache.tools.ant.taskdefs.optional.ssh.*;
import java.util.Vector;
import java.util.Iterator;
import com.jcraft.jsch.*;

/**
 * Creates an SSH tunnel that nested tasks can utilize to perform tasks on
 * remote hosts.
 * 
 * @author Mike Elmsly mike.elmsly@ihug.co.nz
 * @version $Revision: 1.0 $
 * @created July 5, 2004
 * @since Ant 1.6.1
 */

public class SSHTunnel extends SSHBase implements TaskContainer {

	/**
	 * 
	 */
	// Set internal attributes here
	private String rhost, lport, rport;
	private Vector nestedtasks = new Vector();
	private long maxwait = 3000;
	private Session session;

	public SSHTunnel() {
		super();
	}

	public void execute() throws BuildException {
		// Check for valid configuration of task
		if (getHost() == null) {
			throw new BuildException("Host is required.");
		}
		if (getUserInfo().getName() == null) {
			throw new BuildException("Username is required.");
		}
		if (getUserInfo().getKeyfile() == null && getUserInfo().getPassword() == null) {
			throw new BuildException("Password or Keyfile is required.");
		}
		if (getRhost() == null || getLport() == null || getRport() == null) {
			throw new BuildException("Tunnel information is required. \n Either rhost, lport or rport is not set.");
		}

		// Create Connection
		// Create Connection
		try {
			session = openSession();
			session.setTimeout((int) maxwait);
			session.setPortForwardingL(Integer.parseInt(lport), rhost, Integer.parseInt(rport));
			log("SSHTunnel : Connection created successfully.", Project.MSG_INFO);
		} catch (Exception e) {
			e.printStackTrace();
			log("SSHTunnel : Connect Failed", Project.MSG_ERR);
			// throw exception as if connect fails we want to abort nested tasks
			throw new BuildException("SSHTunnel Task Failed: Unable to create tunnel", e);
		}

		// Execute Nested tasks
		try {
			executeNestedTasks();
		} catch (BuildException e) {
			e.printStackTrace();
			log("Nested Tasks Failed!", Project.MSG_ERR);

			// In the event of failure attempt to close the tunnel
			log("Attempting Disconnect", Project.MSG_ERR);
			if (session != null) {
				session.disconnect();
			} else {
				log("Session is null, can't call disconnect", Project.MSG_ERR);
			}
			// Once the tunnel is closed throw a build exception.
			throw new BuildException("Nested Tasks Failed:", e);
		} catch (Exception etwo) {
			log("SSHTunnel Disconnect Failed", Project.MSG_ERR);
			// Tunnel close may have failed but throw build exception for failed
			// tasks
			throw new BuildException("Nested Tasks Failed:", etwo);
		}
		// Lastly, if all has gone well, disconnect
		try {
			log("Attempting Disconnect", Project.MSG_ERR);
			if (session != null) {
				session.disconnect();
			} else {
				log("Session is null", Project.MSG_ERR);
			}
		} catch (Exception e) {
			log("SSHTunnel Disconnect Failed", Project.MSG_ERR);
		}
	}

	/**
	 * 
	 */
	private void executeNestedTasks() throws BuildException {
		Iterator taskiterator = nestedtasks.iterator();
		while (taskiterator.hasNext()) {
			Task thetask = (Task) taskiterator.next();
			if (thetask instanceof UnknownElement) {
				((UnknownElement) thetask).maybeConfigure();
				thetask = ((UnknownElement) thetask).getTask();
				if (thetask == null) {
					continue;
				}
			}
			try {
				thetask.perform();
			} catch (Exception e) {
				throw new BuildException(e);
			}

		}
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * org.apache.tools.ant.TaskContainer#addTask(org.apache.tools.ant.Task)
	 */
	public void addTask(Task task) throws BuildException {
		// TODO Auto-generated method stub
		// System.out.println("In addTask with task:" + task.toString());
		// log("In addTask with task:" + task.toString());
		this.nestedtasks.add(task);
	}

	public void addTask(UnknownElement task) throws BuildException {
		this.nestedtasks.add(task);
	}

	/**
	 * @return
	 */
	public String getLport() {
		return lport;
	}

	/**
	 * @return
	 */
	public long getTimeout() {
		return maxwait;
	}

	/**
	 * @return
	 */
	public String getRhost() {
		return rhost;
	}

	/**
	 * @return
	 */
	public String getRport() {
		return rport;
	}

	/**
	 * @param string
	 */
	public void setLport(String string) {
		lport = string;
	}

	/**
	 * @param l
	 */
	public void setTimeout(long l) {
		maxwait = l;
	}

	/**
	 * @param string
	 */
	public void setRhost(String string) {
		rhost = string;
	}

	/**
	 * @param string
	 */
	public void setRport(String string) {
		rport = string;
	}

}
