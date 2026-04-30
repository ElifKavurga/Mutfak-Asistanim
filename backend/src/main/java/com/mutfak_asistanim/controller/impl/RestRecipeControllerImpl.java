package com.mutfak_asistanim.controller.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.mutfak_asistanim.controller.IRestRecipeController;
import com.mutfak_asistanim.controller.RestBaseController;
import com.mutfak_asistanim.controller.RootEntity;
import com.mutfak_asistanim.dto.DtoRecipe;
import com.mutfak_asistanim.dto.DtoRecipeDetail;
import com.mutfak_asistanim.service.IRecipeService;

@RestController
@RequestMapping("/rest/api/recipe")
public class RestRecipeControllerImpl extends RestBaseController implements IRestRecipeController {

	@Autowired
	private IRecipeService iRecipeService;
	
	@GetMapping("/list")
	@Override
	public RootEntity<List<DtoRecipe>> getAllRecipes() {
		return ok(iRecipeService.getAllRecipes());
	}
	
	@GetMapping("/{id}")
	@Override
	public RootEntity<DtoRecipeDetail> getRecipeById(@PathVariable Long id) {
		return ok(iRecipeService.getRecipeById(id));
	}

	@GetMapping("/recommended")
	@Override
	public RootEntity<List<DtoRecipe>> getRecommendedRecipes() {
		return ok(iRecipeService.getRecommendedRecipes());
	}

}