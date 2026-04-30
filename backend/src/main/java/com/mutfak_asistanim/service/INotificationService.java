package com.mutfak_asistanim.service;

import java.util.List;

import com.mutfak_asistanim.dto.DtoNotification;

public interface INotificationService {
	
	public List<DtoNotification> getAllNotifications();
	
	public Long getUnreadNotifications();
	
	public void markAsRead(Long id);
	
	public void markAllAsRead();
	
	public void deleteAllNotifications();
	
	public void deleteNotification(Long id);
}
