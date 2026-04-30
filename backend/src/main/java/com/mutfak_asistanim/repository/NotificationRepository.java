package com.mutfak_asistanim.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.mutfak_asistanim.model.Notification;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {
	
	List<Notification> findByUserIdOrderBySendingDateDesc(Long userId);
	
	Long countByUserIdAndIsReadFalse(Long userId);
	
	Optional<Notification> findByIdAndUserId(Long id, Long userId);
	
	List<Notification> findByUserIdAndIsReadFalse(Long userId);
	
	List<Notification> findByUserId(Long userId);
}
