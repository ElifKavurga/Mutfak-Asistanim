package com.mutfak_asistanim.service.impl;

import java.util.Date;

import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import com.mutfak_asistanim.dto.DtoUser;
import com.mutfak_asistanim.dto.RegisterRequest;
import com.mutfak_asistanim.model.User;
import com.mutfak_asistanim.repository.UserRepository;
import com.mutfak_asistanim.service.IRegisterService;

@Service
public class RegisterServiceImpl implements IRegisterService {
	
	@Autowired
	private UserRepository userRepository;
	
	@Autowired
	private BCryptPasswordEncoder passwordEncoder;
	
	private User createUser(RegisterRequest input) {
		User user=new User();
		user.setCreatedAt(new Date());
		user.setFirstName(input.getFirstName());
		user.setLastName(input.getLastName());
		user.setUsername(input.getUsername());
		user.setPassword(passwordEncoder.encode(input.getPassword()));
		user.setEmail(input.getEmail());
		
		return user;
	}
	
	@Override
	public DtoUser register(RegisterRequest input) {
		DtoUser dtoUser = new DtoUser();
		
		User savedUser = userRepository.save(createUser(input));
		
		BeanUtils.copyProperties(savedUser, dtoUser);
		
		return dtoUser;
	}

}
