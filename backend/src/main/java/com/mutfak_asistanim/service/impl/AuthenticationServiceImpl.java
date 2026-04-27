package com.mutfak_asistanim.service.impl;

import java.util.Date;
import java.util.Optional;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.stereotype.Service;

import com.mutfak_asistanim.dto.AuthenticateRequest;
import com.mutfak_asistanim.dto.AuthenticateResponse;
import com.mutfak_asistanim.dto.RefreshTokenRequest;
import com.mutfak_asistanim.enums.MessageType;
import com.mutfak_asistanim.exception.BaseException;
import com.mutfak_asistanim.exception.ErrorMessage;
import com.mutfak_asistanim.jwt.JWTService;
import com.mutfak_asistanim.model.RefreshToken;
import com.mutfak_asistanim.model.User;
import com.mutfak_asistanim.repository.RefreshTokenRepository;
import com.mutfak_asistanim.repository.UserRepository;
import com.mutfak_asistanim.service.IAuthenticationService;

@Service
public class AuthenticationServiceImpl implements IAuthenticationService {
	
	@Autowired
	private UserRepository userRepository;
	
	@Autowired
	private AuthenticationProvider authenticationProvider;
	
	@Autowired
	private JWTService jwtService;
	
	@Autowired
	private RefreshTokenRepository refreshTokenRepository;
	
	
	private RefreshToken createRefreshToken(User user) {
		RefreshToken refreshToken = new RefreshToken();
		refreshToken.setCreatedAt(new Date());
		refreshToken.setExpiredDate(new Date(System.currentTimeMillis() + 1000*60*60*4));
		refreshToken.setRefreshToken(UUID.randomUUID().toString());
		refreshToken.setRevoked(false);
		refreshToken.setUser(user);
		
		return refreshToken;
	}
	
	@Override
	public AuthenticateResponse authenticate(AuthenticateRequest input) {
		try {
			UsernamePasswordAuthenticationToken authenticationToken = 
					new UsernamePasswordAuthenticationToken(input.getUsername(), input.getPassword());
			authenticationProvider.authenticate(authenticationToken);
			
			Optional<User> optUser = userRepository.findByUsername(input.getUsername());
			String accessToken = jwtService.generateToken(optUser.get());
			RefreshToken savedRefreshToken = refreshTokenRepository.save(createRefreshToken(optUser.get()));
			
			return new AuthenticateResponse(accessToken, savedRefreshToken.getRefreshToken());
			
		} catch (Exception e) {
			throw new BaseException(new ErrorMessage(MessageType.USERNAME_OR_PASSWORD_INVALID, e.getMessage()));
		}
	}
	
	public boolean isValidRefreshToken(Date expiredDate) {
		return new Date().before(expiredDate);	
	}
	
	@Override
	public AuthenticateResponse refreshToken(RefreshTokenRequest input) {
		Optional<RefreshToken> optRefreshToken = refreshTokenRepository.findByRefreshToken(input.getRefreshToken());
		if(optRefreshToken.isEmpty()) {
			throw new BaseException(new ErrorMessage(MessageType.REFRESH_TOKEN_NOT_FOUND, input.getRefreshToken()));
		}
		
		if(!isValidRefreshToken(optRefreshToken.get().getExpiredDate())) {
			throw new BaseException(new ErrorMessage(MessageType.REFRESH_TOKEN_IS_EXPIRED, input.getRefreshToken()));
		}
		
		User user = optRefreshToken.get().getUser();
		String accessToken = jwtService.generateToken(user);
		RefreshToken savedRefreshToken = refreshTokenRepository.save(createRefreshToken(user));
		
		return new AuthenticateResponse(accessToken, savedRefreshToken.getRefreshToken());
	}		
	
}
