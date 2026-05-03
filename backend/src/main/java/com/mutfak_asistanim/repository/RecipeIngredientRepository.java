package com.mutfak_asistanim.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.mutfak_asistanim.model.RecipeIngredient;

@Repository
public interface RecipeIngredientRepository extends JpaRepository<RecipeIngredient, Long> {
	
	Long countByRecipeId(Long recipeId);
	
}
