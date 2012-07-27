package servlet;

import java.util.Date;

public class FileServerUser {
 private String id;
 private int threadsCount;
 private String sessionId;
 private String file;
 private Date access = new Date();

 public String getId() {
  return id;
 }

 public void setId(String id) {
  this.id = id;
 }

 public int getThreadsCount() {
  return threadsCount;
 }

 public void setThreadsCount(int threadsCount) {
  this.threadsCount = threadsCount;
 }

 public String getSessionId() {
  return sessionId;
 }

 public void setSessionId(String sessionId) {
  this.sessionId = sessionId;
 }

 public String getFile() {
  return file;
 }

 public void setFile(String file) {
  this.file = file;
 }

 public String toString() {
  return id + " " + sessionId + " count: " + threadsCount + " " + file;
 }

 public void incrementThreads() {
  threadsCount++;
 }

 public void decrementThreads() {
  threadsCount--;
 }

 public Date getAccess() {
  return access;
 }
}