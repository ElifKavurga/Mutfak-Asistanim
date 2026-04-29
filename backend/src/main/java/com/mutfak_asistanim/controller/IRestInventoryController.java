package com.mutfak_asistanim.controller;

import java.util.List;

import com.mutfak_asistanim.dto.DtoInventory;
import com.mutfak_asistanim.dto.DtoInventoryIU;
import com.mutfak_asistanim.dto.DtoInventoryUpdate;

public interface IRestInventoryController {
	
	public RootEntity<DtoInventory> saveInventory(DtoInventoryIU dtoInventoryIU);
	
	public RootEntity<List<DtoInventory>> getAllInventories();
	
	public RootEntity<List<DtoInventory>> getExpiringInventories(Integer day);
	
	public RootEntity<DtoInventory> updateInventory(Long inventoryId, DtoInventoryUpdate dtoInventoryUpdate);
	
	public void deleteInventory(Long id);
}
