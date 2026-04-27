package com.mutfak_asistanim.controller.impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.mutfak_asistanim.controller.IRestAuthenticationController;
import com.mutfak_asistanim.controller.RestBaseController;
import com.mutfak_asistanim.controller.RootEntity;
import com.mutfak_asistanim.dto.AuthenticateRequest;
import com.mutfak_asistanim.dto.AuthenticateResponse;
import com.mutfak_asistanim.dto.RefreshTokenRequest;
import com.mutfak_asistanim.service.IAuthenticationService;

import jakarta.validation.Valid;

@RestController
public class RestAuthenticationControllerImpl extends RestBaseController implements IRestAuthenticationController {
	
	@Autowired
	private IAuthenticationService authenticationService;
	
	@PostMapping("/authenticate")
	@Override
	public RootEntity<AuthenticateResponse> authenticate(@Valid @RequestBody AuthenticateRequest input) {
		return ok(authenticationService.authenticate(input));
	}
	
	@PostMapping("/refreshToken")
	@Override
	public RootEntity<AuthenticateResponse> refreshToken(@Valid @RequestBody RefreshTokenRequest input) {
		return ok(authenticationService.refreshToken(input));
	}
	

}
