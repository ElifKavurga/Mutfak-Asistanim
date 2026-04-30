package com.mutfak_asistanim.service.impl;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import com.mutfak_asistanim.dto.DtoNotification;
import com.mutfak_asistanim.enums.MessageType;
import com.mutfak_asistanim.exception.BaseException;
import com.mutfak_asistanim.exception.ErrorMessage;
import com.mutfak_asistanim.model.Notification;
import com.mutfak_asistanim.model.User;
import com.mutfak_asistanim.repository.NotificationRepository;
import com.mutfak_asistanim.repository.UserRepository;
import com.mutfak_asistanim.service.INotificationService;

@Service
public class NotificationServiceImpl implements INotificationService {
	
	@Autowired
	private NotificationRepository notificationRepository;
	
	@Autowired
	private UserRepository userRepository;
	
	public User getCurrentUser() {
		Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
		String currentPrincipalName = authentication.getName();
		
		return userRepository.findByUsername(currentPrincipalName)
				.orElseThrow(() -> new BaseException(new ErrorMessage(MessageType.USERNAME_NOT_FOUND, currentPrincipalName)));

	}
	
	@Override
	public List<DtoNotification> getAllNotifications() {
		List<DtoNotification> dtoNotifications = new ArrayList<>();
		User user = getCurrentUser();
		
		List<Notification> listNotifications = notificationRepository.findByUserIdOrderBySendingDateDesc(user.getId());
		
		for (Notification notification : listNotifications) {
			DtoNotification dtoNotification = new DtoNotification();
			BeanUtils.copyProperties(notification, dtoNotification);
			dtoNotification.setInventoryId(notification.getInventory().getId());
			dtoNotification.setProductName(notification.getInventory().getProduct().getProductName());
			dtoNotifications.add(dtoNotification);
		}
		return dtoNotifications;
	}

	@Override
	public Long getUnreadNotifications() {
		User user = getCurrentUser();

		return notificationRepository.countByUserIdAndIsReadFalse(user.getId());
	}

	@Override
	public void markAsRead(Long id) {
		User user =getCurrentUser();
		
		Optional<Notification> optNotification = notificationRepository.findByIdAndUserId(id, user.getId());
		
		if(optNotification.isEmpty()) {
			throw new BaseException(new ErrorMessage(MessageType.NO_RECORD_EXIST, id.toString()));
		}
		
		Notification notification = optNotification.get();
		
		notification.setIsRead(true);
		
		notificationRepository.save(notification);
	}

	@Override
	public void markAllAsRead() {
		
		User user = getCurrentUser();
		
		List<Notification> listNotifications = notificationRepository.findByUserIdAndIsReadFalse(user.getId());
		
		for (Notification notification : listNotifications) {
			notification.setIsRead(true);
		}
		
		notificationRepository.saveAll(listNotifications);	
	}

	@Override
	public void deleteAllNotifications() {
		User user = getCurrentUser();
		
		List<Notification> listNotifications = notificationRepository.findByUserId(user.getId());
		
		notificationRepository.deleteAll(listNotifications);
	}

	@Override
	public void deleteNotification(Long id) {
		User user = getCurrentUser();
		
		Optional<Notification> optNotification = notificationRepository.findByIdAndUserId(id, user.getId());
		
		if(optNotification.isEmpty()) {
			throw new BaseException(new ErrorMessage(MessageType.NO_RECORD_EXIST, id.toString()));
		}
		
		Notification notification = optNotification.get();
		
		notificationRepository.delete(notification);
	}
}
