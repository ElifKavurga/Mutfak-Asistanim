package com.mutfak_asistanim.controller;

import java.util.List;

import com.mutfak_asistanim.dto.DtoNotification;

public interface IRestNotificationController {
	
	public RootEntity<List<DtoNotification>> getAllNotifications();
	
	public RootEntity<Long> getUnreadNotifications();
	
	public void markAsRead(Long id);
	
	public void markAllAsRead();
	
	public void deleteAllNotifications();
	
	public void deleteNotification(Long id);
}
