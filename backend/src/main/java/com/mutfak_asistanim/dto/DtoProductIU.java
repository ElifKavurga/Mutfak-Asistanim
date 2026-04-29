package com.mutfak_asistanim.dto;

import com.mutfak_asistanim.enums.CategoryType;

import jakarta.validation.constraints.NotEmpty;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DtoProductIU {
	
	@NotEmpty
	private String productName;
	
	@NotEmpty
	private String barcode;
	
	private String productImageUrl;
	
	private CategoryType categoryType;
	
}
