package com.mutfak_asistanim.dto;

import java.util.ArrayList;
import java.util.List;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DtoRecipeDetail extends DtoRecipe {

	private List<DtoRecipeIngredient> ingredients = new ArrayList<>();
	
}
