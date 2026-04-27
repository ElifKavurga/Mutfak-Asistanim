package com.mutfak_asistanim.controller.impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.mutfak_asistanim.controller.IRestRegisterController;
import com.mutfak_asistanim.controller.RestBaseController;
import com.mutfak_asistanim.controller.RootEntity;
import com.mutfak_asistanim.dto.DtoUser;
import com.mutfak_asistanim.dto.RegisterRequest;
import com.mutfak_asistanim.service.IRegisterService;

import jakarta.validation.Valid;

@RestController
public class RestRegisterControllerImpl extends RestBaseController implements IRestRegisterController {
	
	@Autowired
	private IRegisterService registerService;
	
	@PostMapping("/register")
	@Override
	public RootEntity<DtoUser> register(@Valid @RequestBody RegisterRequest input) {
		return ok(registerService.register(input));
	}
}
