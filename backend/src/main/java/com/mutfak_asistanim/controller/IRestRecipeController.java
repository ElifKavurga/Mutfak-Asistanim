package com.mutfak_asistanim.controller;

import java.util.List;

import com.mutfak_asistanim.dto.DtoRecipe;
import com.mutfak_asistanim.dto.DtoRecipeDetail;

public interface IRestRecipeController {

	public RootEntity<List<DtoRecipe>> getAllRecipes();
	
	public RootEntity<DtoRecipeDetail> getRecipeById(Long id);
	
	public RootEntity<List<DtoRecipe>> getRecommendedRecipes();
	
}
