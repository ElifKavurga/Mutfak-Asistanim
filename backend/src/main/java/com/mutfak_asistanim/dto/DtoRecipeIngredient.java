package com.mutfak_asistanim.dto;

import java.math.BigDecimal;

import com.mutfak_asistanim.enums.UnitType;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DtoRecipeIngredient extends DtoBase {
	
	private BigDecimal quantity;
	
	private UnitType unitType;
	
	private Boolean required;
	
	private DtoProduct product;
}
