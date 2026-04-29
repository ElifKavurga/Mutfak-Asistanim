package com.mutfak_asistanim.service;

import com.mutfak_asistanim.dto.DtoProduct;
import com.mutfak_asistanim.dto.DtoProductIU;

public interface IProductService {
	
	public DtoProduct saveProduct(DtoProductIU dtoProductIU);
	
}
