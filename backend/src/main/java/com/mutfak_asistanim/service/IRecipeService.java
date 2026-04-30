package com.mutfak_asistanim.service;

import java.util.List;

import com.mutfak_asistanim.dto.DtoRecipe;
import com.mutfak_asistanim.dto.DtoRecipeDetail;

public interface IRecipeService {
	
	public List<DtoRecipe> getAllRecipes();
	
	public DtoRecipeDetail getRecipeById(Long id);
	
	public List<DtoRecipe> getRecommendedRecipes();
	
}
