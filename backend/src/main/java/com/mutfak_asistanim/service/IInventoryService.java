package com.mutfak_asistanim.service;

import java.util.List;

import com.mutfak_asistanim.dto.DtoInventory;
import com.mutfak_asistanim.dto.DtoInventoryIU;
import com.mutfak_asistanim.dto.DtoInventoryUpdate;

public interface IInventoryService {

	public DtoInventory saveInventory(DtoInventoryIU dtoInventoryIU);
	
	public List<DtoInventory> getAllInventories();
	
	public List<DtoInventory> getExpiringInventories(Integer day);
	
	public DtoInventory updateInventory(Long inventoryId, DtoInventoryUpdate dtoInventoryUpdate);
	
	public void deleteInventory(Long id);
}	
