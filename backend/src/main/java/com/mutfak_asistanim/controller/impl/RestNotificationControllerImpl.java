package com.mutfak_asistanim.controller.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.mutfak_asistanim.controller.IRestNotificationController;
import com.mutfak_asistanim.controller.RestBaseController;
import com.mutfak_asistanim.controller.RootEntity;
import com.mutfak_asistanim.dto.DtoNotification;
import com.mutfak_asistanim.service.INotificationService;

@RestController
@RequestMapping("/rest/api/notifications")
public class RestNotificationControllerImpl extends RestBaseController implements IRestNotificationController {
	
	@Autowired
	private INotificationService iNotificationService;
	
	@GetMapping("/list")
	@Override
	public RootEntity<List<DtoNotification>> getAllNotifications() {
		return ok(iNotificationService.getAllNotifications());
	}
	
	@GetMapping("/unread-count")
	@Override
	public RootEntity<Long> getUnreadNotifications() {
		return ok(iNotificationService.getUnreadNotifications());
	}

	@PatchMapping("/{id}/read")
	@Override
	public void markAsRead(@PathVariable(name = "id") Long id) {
		iNotificationService.markAsRead(id);
	}

	@PatchMapping("/read-all")
	@Override
	public void markAllAsRead() {
		iNotificationService.markAllAsRead();
	}
	
	@DeleteMapping("/delete-all")
	@Override
	public void deleteAllNotifications() {
		iNotificationService.deleteAllNotifications();
	}
	
	@DeleteMapping("/delete/{id}")
	@Override
	public void deleteNotification(@PathVariable(name = "id") Long id) {
		iNotificationService.deleteNotification(id);
	}
}
