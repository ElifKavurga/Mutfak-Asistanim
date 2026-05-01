package com.mutfak_asistanim.dto;

import java.util.List;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DtoDashboard {
	
	private String username;
	
	private Long totalInventoryCount;
	
	private Long expiringSoonCount;
	
	private Long unreadNotificationCount;
	
	private List<DtoInventory> expiringProducts;
	
	private List<DtoRecipe> recommendedRecipes;
	
}
