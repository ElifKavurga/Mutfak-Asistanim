package com.mutfak_asistanim.model;

import java.util.ArrayList;
import java.util.List;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "recipe")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Recipe extends BaseEntity {
	
	@Column(name = "recipe_name")
	private String recipeName;
	
	@Column(name = "description")
	private String description;
	
	@Column(name = "prep_time_minutes")
	private Integer prepTimeMinutes;
	
	@Column(name = "calorie")
	private Integer calorie;
	
	@Column(name = "recipe_image_url", nullable = true)
	private String recipeImageUrl;
	
	//RecipeIngredient
	@OneToMany(fetch = FetchType.LAZY, mappedBy = "recipe")
	private List<RecipeIngredient> recipeIngredients=new ArrayList<>();
	
}
