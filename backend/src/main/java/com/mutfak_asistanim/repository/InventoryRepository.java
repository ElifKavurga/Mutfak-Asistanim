package com.mutfak_asistanim.repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.mutfak_asistanim.model.Inventory;

@Repository
public interface InventoryRepository extends JpaRepository<Inventory, Long> {
	
	List<Inventory> findByUserId(Long userId);
	
	List<Inventory> findByUserIdAndExpirationDateBetween(Long userId, LocalDate startDate, LocalDate targetDate); 
	
	Optional<Inventory> findByIdAndUserId(Long id, Long userId);
}
