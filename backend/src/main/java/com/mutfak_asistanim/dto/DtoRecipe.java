package com.mutfak_asistanim.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DtoRecipe extends DtoBase {
	
	private String recipeName;
	
	private String description;
	
	private Integer prepTimeMinutes;
	
	private Integer calorie;
	
	private String recipeImageUrl;
	
}