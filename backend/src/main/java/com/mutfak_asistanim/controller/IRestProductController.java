package com.mutfak_asistanim.controller;

import com.mutfak_asistanim.dto.DtoProduct;
import com.mutfak_asistanim.dto.DtoProductIU;

public interface IRestProductController {
	
	public RootEntity<DtoProduct> saveProduct(DtoProductIU dtoProductIU);
	
}
