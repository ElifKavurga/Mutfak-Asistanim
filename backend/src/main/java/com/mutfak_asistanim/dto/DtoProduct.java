package com.mutfak_asistanim.dto;

import com.mutfak_asistanim.enums.CategoryType;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DtoProduct extends DtoBase {
	
	private String productName;
	
	private String barcode;
	
	private String productImageUrl;
	
	private CategoryType categoryType;
}
