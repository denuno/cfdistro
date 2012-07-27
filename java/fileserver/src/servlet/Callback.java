package servlet;

import java.util.Properties;

/**
 * Date: 07.05.2008
 * Time: 18:59:43
 */
public interface Callback {
 /**
  * set properties for callback, it can be db props, url and etc
  * @param props
  */
 public void setProperties(Properties props);
 /**
  * this function invoked after request incoming
  * @param user - user
  * @param remouteAddress - user remoute address
  * @param sessionId - http sessionId
  * @param requestPath - full path in request except server name
  * @throws CanDownloadException thrown if user can't download file
  */
 public void requestIncoming(FileServerUser user, String remouteAddress, String sessionId, String requestPath) throws CanDownloadException;

 /**
  * function invoked after download complete
  * @param user
  * @param remouteAddress
  * @param sessionId
  * @param requestPath
  */
 public void downloadDone(FileServerUser user, String remouteAddress, String sessionId, String requestPath);

 /**
  * function invoked if file not found
  * @param user
  * @param property
  * @param filename
  */
 public void fileNotFound(FileServerUser user, String property, String filename);

 /**
  * handle error
  * @param user
  * @param e
  */
 public void errorHandle(FileServerUser user, Exception e);
}