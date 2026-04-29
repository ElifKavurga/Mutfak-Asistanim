package com.mutfak_asistanim.service.impl;

import java.util.Date;

import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.mutfak_asistanim.dto.DtoProduct;
import com.mutfak_asistanim.dto.DtoProductIU;
import com.mutfak_asistanim.model.Product;
import com.mutfak_asistanim.repository.ProductRepository;
import com.mutfak_asistanim.service.IProductService;

@Service
public class ProductServiceImpl implements IProductService {
	
	@Autowired
	private ProductRepository productRepository;
	
	public Product createProduct(DtoProductIU dtoProductIU) {
		Product product = new Product();
		
		product.setCreatedAt(new Date());
		BeanUtils.copyProperties(dtoProductIU, product);
		
		return product;
	}
	
	@Override
	public DtoProduct saveProduct(DtoProductIU dtoProductIU) {
		DtoProduct dtoProduct = new DtoProduct();
		Product savedProduct = productRepository.save(createProduct(dtoProductIU));
		
		BeanUtils.copyProperties(savedProduct, dtoProduct);
		
		return dtoProduct;
	}
}
