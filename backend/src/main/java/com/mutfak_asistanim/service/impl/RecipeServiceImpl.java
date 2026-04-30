package com.mutfak_asistanim.service.impl;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import com.mutfak_asistanim.dto.DtoProduct;
import com.mutfak_asistanim.dto.DtoRecipe;
import com.mutfak_asistanim.dto.DtoRecipeDetail;
import com.mutfak_asistanim.dto.DtoRecipeIngredient;
import com.mutfak_asistanim.enums.MessageType;
import com.mutfak_asistanim.exception.BaseException;
import com.mutfak_asistanim.exception.ErrorMessage;
import com.mutfak_asistanim.model.Inventory;
import com.mutfak_asistanim.model.Recipe;
import com.mutfak_asistanim.model.RecipeIngredient;
import com.mutfak_asistanim.model.User;
import com.mutfak_asistanim.repository.InventoryRepository;
import com.mutfak_asistanim.repository.RecipeRepository;
import com.mutfak_asistanim.repository.UserRepository;
import com.mutfak_asistanim.service.IRecipeService;

@Service
public class RecipeServiceImpl implements IRecipeService {

	@Autowired
	private UserRepository userRepository;
	
	@Autowired
	private RecipeRepository recipeRepository;
	
	@Autowired
	private InventoryRepository inventoryRepository;
	
	public User getCurrentUser() {
		Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
		String currentPrincipalName = authentication.getName();
		
		return userRepository.findByUsername(currentPrincipalName)
				.orElseThrow(() -> new BaseException(new ErrorMessage(MessageType.USERNAME_NOT_FOUND, currentPrincipalName)));
	
	}

	@Override
	public List<DtoRecipe> getAllRecipes() {
		List<DtoRecipe> dtoRecipes=new ArrayList<>();
		
		List<Recipe> recipeList = recipeRepository.findAll();
		for (Recipe recipe : recipeList) {
			DtoRecipe dtoRecipe = new DtoRecipe();
			BeanUtils.copyProperties(recipe, dtoRecipe);
			dtoRecipes.add(dtoRecipe);
		}
		
		return dtoRecipes;
	}

	@Override
	public DtoRecipeDetail getRecipeById(Long id) {
		
		Optional<Recipe> optRecipe = recipeRepository.findById(id);
		if(optRecipe.isEmpty()) {
			throw new BaseException(new ErrorMessage(MessageType.NO_RECORD_EXIST, id.toString()));
		}
		
		Recipe recipe = optRecipe.get();
		
		DtoRecipeDetail dtoRecipeDetail = new DtoRecipeDetail();
		BeanUtils.copyProperties(recipe, dtoRecipeDetail);
		
		List<DtoRecipeIngredient> ingredients = new ArrayList<>();
		
		for (RecipeIngredient recipeIngredient : recipe.getRecipeIngredients()) {
			DtoRecipeIngredient dtoRecipeIngredient = new DtoRecipeIngredient();
			DtoProduct dtoProduct = new DtoProduct();
			
			BeanUtils.copyProperties(recipeIngredient, dtoRecipeIngredient);
			BeanUtils.copyProperties(recipeIngredient.getProduct(), dtoProduct);
			
			dtoRecipeIngredient.setProduct(dtoProduct);
			ingredients.add(dtoRecipeIngredient);
		}
		
		dtoRecipeDetail.setIngredients(ingredients);
		
		return dtoRecipeDetail;
	}

	@Override
	public List<DtoRecipe> getRecommendedRecipes() {
		List<DtoRecipe> recipes = new ArrayList<>();
		User user = getCurrentUser();
		
		List<Inventory> inventories = inventoryRepository.findByUserId(user.getId());
		
		Set<Long> userProductsId = new HashSet<>();
		
		for (Inventory inventory : inventories) {
			userProductsId.add(inventory.getProduct().getId());
		}
		
		List<Recipe> allRecipes = recipeRepository.findAll();
		List<Recipe> recommendedRecipes = new ArrayList<>();
		
		
		for (Recipe recipe : allRecipes) {
			boolean canMake = true;
			
			for (RecipeIngredient ingredient : recipe.getRecipeIngredients()) {
				if(Boolean.TRUE.equals(ingredient.getRequired())) {
					Long productId = ingredient.getProduct().getId();
					
					if(!userProductsId.contains(productId)) {
						canMake= false;
						break;
					}
				}
			}
			
			if(canMake) {
				recommendedRecipes.add(recipe);
			}
		}
		
		for (Recipe recipe : recommendedRecipes) {
			DtoRecipe dtoRecipe = new DtoRecipe();
			BeanUtils.copyProperties(recipe, dtoRecipe);
			recipes.add(dtoRecipe);
		}
		
		return recipes;
	}
}
