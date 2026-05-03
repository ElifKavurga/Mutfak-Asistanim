package com.mutfak_asistanim.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.mutfak_asistanim.model.Recipe;

@Repository
public interface RecipeRepository extends JpaRepository<Recipe, Long> {
	
	Optional<Recipe> findByRecipeNameIgnoreCase(String recipeName);
	
}
