package com.mutfak_asistanim.config;

import java.util.Arrays;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import com.mutfak_asistanim.handler.AuthEntryPoint;
import com.mutfak_asistanim.jwt.JWTAuthenticationFilter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

	public static final String REGISTER = "/register";
	public static final String AUTHENTICATE = "/authenticate";
	public static final String REFRESH_TOKEN = "/refreshToken";
	public static final String HEALTH = "/health";
 	
	@Autowired
	private AuthenticationProvider authenticationProvider;
	
	@Autowired
	private JWTAuthenticationFilter jwtAuthenticationFilter;
	
	@Autowired
	private AuthEntryPoint authEntryPoint;

	@Value("${app.cors.allowed-origin-patterns:http://localhost:*,http://127.0.0.1:*,http://10.0.2.2:*,http://192.168.*.*:*,https://*.up.railway.app,https://*.railway.app}")
	private String allowedOriginPatterns;
	
	@Bean
	public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
		http.csrf(csrf -> csrf.disable())
		.cors(Customizer.withDefaults())
		.exceptionHandling(exception -> exception
				.authenticationEntryPoint(authEntryPoint))
		.authorizeHttpRequests(request -> 
		request.requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
		.requestMatchers(REGISTER, AUTHENTICATE, REFRESH_TOKEN, HEALTH).permitAll()
		.anyRequest()
		.authenticated())
		.sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
		.authenticationProvider(authenticationProvider)
		.addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);
		
		return http.build();
	}
	
	@Bean
	CorsConfigurationSource corsConfigurationSource() {
		CorsConfiguration configuration = new CorsConfiguration();
		configuration.setAllowedOriginPatterns(Arrays.stream(allowedOriginPatterns.split(","))
				.map(String::trim)
				.filter(pattern -> !pattern.isEmpty())
				.toList());
		configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
		configuration.setAllowCredentials(true);
		configuration.setAllowedHeaders(List.of("*"));
		configuration.setExposedHeaders(List.of("Authorization"));
		UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
		source.registerCorsConfiguration("/**", configuration);
		return source;
	}
	
}
