package com.mutfak_asistanim.service.impl;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import com.mutfak_asistanim.dto.DtoDashboard;
import com.mutfak_asistanim.dto.DtoInventory;
import com.mutfak_asistanim.dto.DtoProduct;
import com.mutfak_asistanim.dto.DtoRecipe;
import com.mutfak_asistanim.enums.MessageType;
import com.mutfak_asistanim.exception.BaseException;
import com.mutfak_asistanim.exception.ErrorMessage;
import com.mutfak_asistanim.model.Inventory;
import com.mutfak_asistanim.model.User;
import com.mutfak_asistanim.repository.InventoryRepository;
import com.mutfak_asistanim.repository.NotificationRepository;
import com.mutfak_asistanim.repository.UserRepository;
import com.mutfak_asistanim.service.IDashboardService;
import com.mutfak_asistanim.service.IRecipeService;

@Service
public class DashboardServiceImpl implements IDashboardService {
	
	@Autowired
	private UserRepository userRepository;
	
	@Autowired
	private InventoryRepository inventoryRepository;
	
	@Autowired
	private NotificationRepository notificationRepository;
	
	@Autowired
	private IRecipeService iRecipeService;
	
	public User getCurrentUser() {
		Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
		String currentPrincipalName = authentication.getName();
		
		return userRepository.findByUsername(currentPrincipalName)
				.orElseThrow(() -> new BaseException(new ErrorMessage(MessageType.USERNAME_NOT_FOUND, currentPrincipalName)));

	}
	
	@Override
	public DtoDashboard getDashboard() {
		DtoDashboard dtoDashboard = new DtoDashboard();
		
		User user = getCurrentUser();
		
		LocalDate startDate = LocalDate.now();
		LocalDate targetDate = startDate.plusDays(7);
		
		List<Inventory> expiringInventories = inventoryRepository.findByUserIdAndExpirationDateBetween(user.getId(), startDate, targetDate);
		
		Long totalInventory = inventoryRepository.countByUserId(user.getId());
		
		Long unreadNotifications = notificationRepository.countByUserIdAndIsReadFalse(user.getId());
		
		List<DtoInventory> expiringProducts = new ArrayList<>(); 
		
		for (Inventory inventory : expiringInventories) {
			DtoInventory dtoInventory = new DtoInventory();
			DtoProduct dtoProduct = new DtoProduct();
			BeanUtils.copyProperties(inventory, dtoInventory);
			BeanUtils.copyProperties(inventory.getProduct(), dtoProduct);
			dtoInventory.setProduct(dtoProduct);
			
			expiringProducts.add(dtoInventory);
		}
		
		List<DtoRecipe> recommendedRecipes = iRecipeService.getRecommendedRecipes();
		
		dtoDashboard.setUsername(user.getUsername());
		dtoDashboard.setTotalInventoryCount(totalInventory);
		dtoDashboard.setExpiringSoonCount((long) expiringInventories.size());
		dtoDashboard.setUnreadNotificationCount(unreadNotifications);
		dtoDashboard.setExpiringProducts(expiringProducts);
		dtoDashboard.setRecommendedRecipes(recommendedRecipes);
		
		return dtoDashboard;
	}

}
