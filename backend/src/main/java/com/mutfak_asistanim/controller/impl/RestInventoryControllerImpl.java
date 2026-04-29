package com.mutfak_asistanim.controller.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.mutfak_asistanim.controller.IRestInventoryController;
import com.mutfak_asistanim.controller.RestBaseController;
import com.mutfak_asistanim.controller.RootEntity;
import com.mutfak_asistanim.dto.DtoInventory;
import com.mutfak_asistanim.dto.DtoInventoryIU;
import com.mutfak_asistanim.dto.DtoInventoryUpdate;
import com.mutfak_asistanim.service.IInventoryService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/rest/api/inventory")
public class RestInventoryControllerImpl extends RestBaseController implements IRestInventoryController {
	
	@Autowired
	private IInventoryService iInventoryService;
	
	@PostMapping("/save")
	@Override
	public RootEntity<DtoInventory> saveInventory(@Valid @RequestBody DtoInventoryIU dtoInventoryIU) {
		return ok(iInventoryService.saveInventory(dtoInventoryIU));
	}
	
	@GetMapping("/list")
	@Override
	public RootEntity<List<DtoInventory>> getAllInventories() {
		return ok(iInventoryService.getAllInventories());
	}
	
	@GetMapping("/expiring")
	@Override
	public RootEntity<List<DtoInventory>> getExpiringInventories(@RequestParam(defaultValue = "7") Integer day) {
		return ok(iInventoryService.getExpiringInventories(day));
	}
	
	@PutMapping("/update/{id}")
	@Override
	public RootEntity<DtoInventory> updateInventory(@Valid @PathVariable(name = "id") Long inventoryId, 
			@RequestBody DtoInventoryUpdate dtoInventoryUpdate) {
		return ok(iInventoryService.updateInventory(inventoryId, dtoInventoryUpdate));
	}
	
	@DeleteMapping("/delete/{id}")
	@Override
	public void deleteInventory(@PathVariable(name = "id") Long id) {
		iInventoryService.deleteInventory(id);
	}
}
