package com.mutfak_asistanim.service.impl;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import com.mutfak_asistanim.dto.DtoInventory;
import com.mutfak_asistanim.dto.DtoInventoryIU;
import com.mutfak_asistanim.dto.DtoInventoryUpdate;
import com.mutfak_asistanim.dto.DtoProduct;
import com.mutfak_asistanim.enums.MessageType;
import com.mutfak_asistanim.exception.BaseException;
import com.mutfak_asistanim.exception.ErrorMessage;
import com.mutfak_asistanim.model.Inventory;
import com.mutfak_asistanim.model.Product;
import com.mutfak_asistanim.model.User;
import com.mutfak_asistanim.repository.InventoryRepository;
import com.mutfak_asistanim.repository.ProductRepository;
import com.mutfak_asistanim.repository.UserRepository;
import com.mutfak_asistanim.service.IInventoryService;

@Service
public class InventoryServiceImpl implements IInventoryService {

	@Autowired
	private InventoryRepository inventoryRepository;
	
	@Autowired
	private UserRepository userRepository;
	
	@Autowired
	private ProductRepository productRepository;
    
	public User getCurrentUser() {
		Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
		String currentPrincipalName = authentication.getName();
		
		return userRepository.findByUsername(currentPrincipalName)
				.orElseThrow(() -> new BaseException(new ErrorMessage(MessageType.USERNAME_NOT_FOUND, currentPrincipalName)));

	}
	
	public Inventory createInventory(DtoInventoryIU dtoInventoryIU) {
		User user = getCurrentUser();
		
		Optional<Product> optProduct = productRepository.findById(dtoInventoryIU.getProductId());
		if(optProduct.isEmpty()) {
			throw new BaseException(new ErrorMessage(MessageType.NO_RECORD_EXIST, dtoInventoryIU.getProductId().toString()));
		}
		
		Inventory inventory = new Inventory();
		inventory.setCreatedAt(new Date());
		
		BeanUtils.copyProperties(dtoInventoryIU, inventory);
		
		inventory.setProduct(optProduct.get());
		inventory.setUser(user);
		
		return inventory;
	}
	
	@Override
	public DtoInventory saveInventory(DtoInventoryIU dtoInventoryIU) {
		DtoInventory dtoInventory = new DtoInventory();
		DtoProduct dtoProduct = new DtoProduct();
		
		Inventory savedInventory = inventoryRepository.save(createInventory(dtoInventoryIU));
		
		BeanUtils.copyProperties(savedInventory, dtoInventory);
		BeanUtils.copyProperties(savedInventory.getProduct(), dtoProduct);
		
		dtoInventory.setProduct(dtoProduct);
		
		return dtoInventory;
	}

	@Override
	public List<DtoInventory> getAllInventories() {
		User user = getCurrentUser();
		
		List<DtoInventory> dtoInventories = new ArrayList<>();
		List<Inventory> inventoryList = inventoryRepository.findByUserId(user.getId());
		
		for (Inventory inventory : inventoryList) {
			DtoInventory dtoInventory = new DtoInventory();
			DtoProduct dtoProduct = new DtoProduct();
			BeanUtils.copyProperties(inventory, dtoInventory);
			BeanUtils.copyProperties(inventory.getProduct(), dtoProduct);
			dtoInventory.setProduct(dtoProduct);
			dtoInventories.add(dtoInventory);
		}
		
		return dtoInventories;
	}

	@Override
	public List<DtoInventory> getExpiringInventories(Integer day) {
		List<DtoInventory> dtoList = new ArrayList<>();
		
		User user = getCurrentUser();
		
		LocalDate startDate = LocalDate.now();
		LocalDate targetDate = startDate.plusDays(day);
		
		List<Inventory> expiringList = inventoryRepository.findByUserIdAndExpirationDateBetween(user.getId(), startDate, targetDate);
		
		for (Inventory inventory : expiringList) {
			DtoInventory dtoInventory = new DtoInventory();
			DtoProduct dtoProduct = new DtoProduct();
			BeanUtils.copyProperties(inventory, dtoInventory);
			BeanUtils.copyProperties(inventory.getProduct(), dtoProduct);
			
			dtoInventory.setProduct(dtoProduct);
			
			dtoList.add(dtoInventory);		
		}
		
		return dtoList;
	}

	@Override
	public DtoInventory updateInventory(Long inventoryId, DtoInventoryUpdate dtoInventoryUpdate) {
		DtoInventory dtoInventory=new DtoInventory();
		DtoProduct dtoProduct = new DtoProduct();
		User user = getCurrentUser();
		
		Optional<Inventory> optInventory = inventoryRepository.findByIdAndUserId(inventoryId, user.getId());
		if(optInventory.isEmpty()) {
			throw new BaseException(new ErrorMessage(MessageType.NO_RECORD_EXIST, inventoryId.toString()));
		}
		
		Inventory inventory = optInventory.get();
		
		inventory.setQuantity(dtoInventoryUpdate.getQuantity());
		inventory.setUnitType(dtoInventoryUpdate.getUnitType());
		inventory.setExpirationDate(dtoInventoryUpdate.getExpirationDate());
		
		Inventory updatedInventory = inventoryRepository.save(inventory);
		BeanUtils.copyProperties(updatedInventory, dtoInventory);
		BeanUtils.copyProperties(updatedInventory.getProduct(), dtoProduct);
		dtoInventory.setProduct(dtoProduct);
		
		return dtoInventory;
	}

	@Override
	public void deleteInventory(Long id) {
		User user =getCurrentUser();
		Optional<Inventory> optInventory = inventoryRepository.findByIdAndUserId(id, user.getId());
		
		if(optInventory.isEmpty()) {
			throw new BaseException(new ErrorMessage(MessageType.NO_RECORD_EXIST, id.toString()));
		}
		Inventory inventory = optInventory.get();

		inventoryRepository.delete(inventory);
	}
}
