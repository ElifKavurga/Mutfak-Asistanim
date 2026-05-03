package com.mutfak_asistanim.jwt;

import java.security.Key;
import java.util.Date;
import java.util.function.Function;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;

@Service
public class JWTService {

	private final Key signingKey;
	private final long expirationInMilliseconds;

	public JWTService(
			@Value("${app.jwt.secret}") String secretKey,
			@Value("${app.jwt.expiration-ms:7200000}") long expirationInMilliseconds) {
		byte[] bytes = Decoders.BASE64.decode(secretKey);
		this.signingKey = Keys.hmacShaKeyFor(bytes);
		this.expirationInMilliseconds = expirationInMilliseconds;
	}
	
	public String generateToken(UserDetails userDetails) {
		return Jwts.builder()
				.setSubject(userDetails.getUsername())
				.setIssuedAt(new Date())
				.setExpiration(new Date(System.currentTimeMillis() + expirationInMilliseconds))
				.signWith(getKey(), SignatureAlgorithm.HS256)
				.compact();
	}
	
	public <T> T exportToken(String Token, Function<Claims, T> claimsFunc) {
		Claims claims = getClaims(Token);
		return claimsFunc.apply(claims);
	}
	
	public Claims getClaims(String token) {
		Claims claims = Jwts.parserBuilder()
		.setSigningKey(getKey())
		.build()
		.parseClaimsJws(token).getBody();
		
		return claims;
	}
	
	public String getUsernameByToken(String token) {
		return exportToken(token, Claims::getSubject);
	}
	
	public Boolean isTokenValid(String token) {
		Date expireDate = exportToken(token, Claims::getExpiration);
		return new Date().before(expireDate);
	}
	
	public Key getKey() {
		return signingKey;
	}
	
}
