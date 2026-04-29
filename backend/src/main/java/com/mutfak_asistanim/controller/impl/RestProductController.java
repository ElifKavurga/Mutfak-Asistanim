package com.mutfak_asistanim.controller.impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.mutfak_asistanim.controller.IRestProductController;
import com.mutfak_asistanim.controller.RestBaseController;
import com.mutfak_asistanim.controller.RootEntity;
import com.mutfak_asistanim.dto.DtoProduct;
import com.mutfak_asistanim.dto.DtoProductIU;
import com.mutfak_asistanim.service.IProductService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/rest/api/product")
public class RestProductController extends RestBaseController implements IRestProductController {
	
	@Autowired
	private IProductService iProductService;
	
	@PostMapping("/save")
	@Override
	public RootEntity<DtoProduct> saveProduct(@Valid @RequestBody DtoProductIU dtoProductIU) {
		return ok(iProductService.saveProduct(dtoProductIU));
	}

}
