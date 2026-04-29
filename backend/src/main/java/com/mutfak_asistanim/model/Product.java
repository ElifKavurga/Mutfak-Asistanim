package com.mutfak_asistanim.model;

import java.util.ArrayList;
import java.util.List;

import com.mutfak_asistanim.enums.CategoryType;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "product")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Product extends BaseEntity {
	
	@Column(name = "product_name")
	private String productName;
	
	@Column(name = "barcode", nullable = true)
	private String barcode;
	
	@Column(name = "product_image_url", nullable = true)
	private String productImageUrl;
	
	@Column(name = "category_type")
	@Enumerated(EnumType.STRING)
	private CategoryType categoryType;
	
	@OneToMany(fetch = FetchType.LAZY, mappedBy = "product")
	private List<Inventory> inventories = new ArrayList<>();
	
	@OneToMany(fetch = FetchType.LAZY, mappedBy = "product")
	private List<RecipeIngredient> recipeIngredients= new ArrayList<>();
	
}
