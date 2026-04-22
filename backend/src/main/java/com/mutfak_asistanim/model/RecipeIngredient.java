package com.mutfak_asistanim.model;

import java.math.BigDecimal;

import com.mutfak_asistanim.enums.UnitType;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "recipe_ingredient")
public class RecipeIngredient extends BaseEntity {
	
	@Column(name = "quantity")
	private BigDecimal quantity;
	
	@Column(name = "unit_type")
	@Enumerated(EnumType.STRING)
	private UnitType unitType;
	
	@Column(name = "required")
	private Boolean required;
	
	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "product_id")
	private Product product;
	
	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "recipe_id")
	private Recipe recipe;
	
}
